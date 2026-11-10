import hashlib
import secrets


def generate_secure_token(nbytes: int = 32) -> str:
    """Generate high-entropy cryptographically secure token."""
    return secrets.token_urlsafe(nbytes)


def compute_sha256(data: bytes) -> str:
    """Compute hex SHA-256 digest of binary payload."""
    return hashlib.sha256(data).hexdigest()

