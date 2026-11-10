import os
from datetime import datetime, timedelta, timezone
from typing import Any, Dict, Optional, Tuple
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
from jose import jwt, JWTError
from passlib.context import CryptContext

from app.core.config import settings

# Password hashing context using Argon2id
pwd_context = CryptContext(
    schemes=["argon2"],
    argon2__memory_cost=65536,
    argon2__time_cost=3,
    argon2__parallelism=4,
    deprecated="auto"
)


def hash_password(password: str) -> str:
    """Hash password using memory-hard Argon2id."""
    return pwd_context.hash(password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify plain password against Argon2id hash."""
    return pwd_context.verify(plain_password, hashed_password)


def create_access_token(subject: str, role: str, expires_delta: Optional[timedelta] = None) -> str:
    """Create short-lived JWT access token (15 mins)."""
    now = datetime.now(timezone.utc)
    if expires_delta:
        expire = now + expires_delta
    else:
        expire = now + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)

    to_encode: Dict[str, Any] = {
        "sub": str(subject),
        "role": role,
        "type": "access",
        "iat": now,
        "exp": expire,
    }
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)


def create_refresh_token(subject: str, device_uuid: str) -> Tuple[str, str]:
    """
    Create a rotating refresh token.
    Returns: (raw_refresh_token, token_hash_for_db)
    """
    import hashlib
    raw_token = os.urandom(32).hex()
    token_hash = hashlib.sha256(raw_token.encode("utf-8")).hexdigest()
    return raw_token, token_hash


def decode_access_token(token: str) -> Optional[Dict[str, Any]]:
    """Decode and validate a JWT access token."""
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        if payload.get("type") != "access":
            return None
        return payload
    except JWTError:
        return None


# ==============================================================================
# Biometric Encryption (AES-256-GCM)
# ==============================================================================

def encrypt_face_embedding(embedding_bytes: bytes) -> Tuple[bytes, bytes, bytes]:
    """
    Encrypts a 512-D float embedding vector using AES-256-GCM.
    Returns: (ciphertext, iv, auth_tag)
    """
    key = bytes.fromhex(settings.BIOMETRIC_MASTER_KEY[:64])
    aesgcm = AESGCM(key)
    iv = os.urandom(12)  # 96-bit random IV for GCM
    
    # AESGCM.encrypt appends 16-byte tag to the ciphertext
    encrypted_with_tag = aesgcm.encrypt(iv, embedding_bytes, None)
    ciphertext = encrypted_with_tag[:-16]
    tag = encrypted_with_tag[-16:]
    return ciphertext, iv, tag


def decrypt_face_embedding(ciphertext: bytes, iv: bytes, tag: bytes) -> bytes:
    """
    Decrypts an AES-256-GCM encrypted face embedding.
    """
    key = bytes.fromhex(settings.BIOMETRIC_MASTER_KEY[:64])
    aesgcm = AESGCM(key)
    encrypted_with_tag = ciphertext + tag
    return aesgcm.decrypt(iv, encrypted_with_tag, None)

