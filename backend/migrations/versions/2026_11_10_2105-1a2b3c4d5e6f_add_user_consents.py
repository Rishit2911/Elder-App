"""add_user_consents

Revision ID: 1a2b3c4d5e6f
Revises: 045b65eefb24
Create Date: 2026-11-10 21:05:00.000000+00:00

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = '1a2b3c4d5e6f'
down_revision: Union[str, None] = '045b65eefb24'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        'user_consents',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, server_default=sa.text('gen_random_uuid()')),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False),
        sa.Column('consent_type', sa.String(length=50), nullable=False),
        sa.Column('consent_version', sa.String(length=20), server_default='1.0', nullable=False),
        sa.Column('is_granted', sa.Boolean(), server_default='true', nullable=False),
        sa.Column('granted_at', sa.DateTime(timezone=True), server_default=sa.text('CURRENT_TIMESTAMP'), nullable=False),
        sa.Column('withdrawn_at', sa.DateTime(timezone=True), nullable=True),
    )
    op.create_index(op.f('ix_user_consents_id'), 'user_consents', ['id'], unique=False)
    op.create_index(op.f('ix_user_consents_user_id'), 'user_consents', ['user_id'], unique=False)


def downgrade() -> None:
    op.drop_index(op.f('ix_user_consents_user_id'), table_name='user_consents')
    op.drop_index(op.f('ix_user_consents_id'), table_name='user_consents')
    op.drop_table('user_consents')

