"""add_phase2_tables

Revision ID: a1b2c3d4e5f6
Revises: abbd45ecd240
Create Date: 2026-05-21 02:40:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'a1b2c3d4e5f6'
down_revision: Union[str, None] = 'abbd45ecd240'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Create consultations table
    op.create_table(
        'consultations',
        sa.Column('id', sa.String(length=36), nullable=False),
        sa.Column('patient_id', sa.String(length=36), nullable=False),
        sa.Column('doctor_id', sa.String(length=36), nullable=False),
        sa.Column('appointment_id', sa.String(length=36), nullable=True),
        sa.Column('soap_note', sa.JSON(), nullable=False),
        sa.Column('ai_trace', sa.JSON(), nullable=True),
        sa.Column('confidence_score', sa.Float(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.ForeignKeyConstraint(['appointment_id'], ['appointments.id'], ),
        sa.ForeignKeyConstraint(['doctor_id'], ['doctors.id'], ),
        sa.ForeignKeyConstraint(['patient_id'], ['patients.id'], ),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_consultations_id'), 'consultations', ['id'], unique=False)

    # Create epidemiology_events table
    op.create_table(
        'epidemiology_events',
        sa.Column('id', sa.String(length=36), nullable=False),
        sa.Column('disease_name', sa.String(length=255), nullable=False),
        sa.Column('location', sa.String(length=255), nullable=False),
        sa.Column('latitude', sa.Float(), nullable=True),
        sa.Column('longitude', sa.Float(), nullable=True),
        sa.Column('cases', sa.Integer(), nullable=False),
        sa.Column('deaths', sa.Integer(), nullable=False),
        sa.Column('reported_at', sa.DateTime(), nullable=True),
        sa.Column('status', sa.String(length=50), nullable=True),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_epidemiology_events_disease_name'), 'epidemiology_events', ['disease_name'], unique=False)
    op.create_index(op.f('ix_epidemiology_events_id'), 'epidemiology_events', ['id'], unique=False)


def downgrade() -> None:
    op.drop_index(op.f('ix_epidemiology_events_id'), table_name='epidemiology_events')
    op.drop_index(op.f('ix_epidemiology_events_disease_name'), table_name='epidemiology_events')
    op.drop_table('epidemiology_events')
    op.drop_index(op.f('ix_consultations_id'), table_name='consultations')
    op.drop_table('consultations')
