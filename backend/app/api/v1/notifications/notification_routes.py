from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from app.database import get_db
from app.models.all_models import User, Notification
from app.schemas.response_envelope import success_response, error_response
from app.security import get_current_active_user

router = APIRouter(prefix="/api/notifications", tags=["notifications"])


@router.get("")
async def get_notifications(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Retrieve unread and recent notifications for the logged-in user."""
    result = await db.execute(
        select(Notification)
        .where(Notification.user_id == current_user.id)
        .order_by(Notification.created_at.desc())
        .limit(20)
    )
    notifications = result.scalars().all()

    data = [{
        "id": n.id,
        "title": n.title,
        "message": n.message,
        "is_read": n.is_read,
        "created_at": n.created_at.isoformat(),
    } for n in notifications]

    return success_response(data, "Notifications retrieved successfully")


@router.patch("/{notification_id}/read")
async def mark_notification_read(
    notification_id: str,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Mark a specific notification as read."""
    result = await db.execute(
        select(Notification)
        .where(Notification.id == notification_id)
        .where(Notification.user_id == current_user.id)
    )
    notif = result.scalars().first()
    if not notif:
        return error_response(["Notification not found"], "Not found", 404)

    notif.is_read = True
    await db.commit()

    return success_response({"id": notification_id, "is_read": True}, "Notification marked as read")


@router.patch("/mark-all-read")
async def mark_all_read(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Mark all user notifications as read."""
    result = await db.execute(
        select(Notification)
        .where(Notification.user_id == current_user.id)
        .where(Notification.is_read == False)
    )
    notifications = result.scalars().all()
    for n in notifications:
        n.is_read = True
    await db.commit()

    return success_response(
        {"updated_count": len(notifications)},
        f"Marked {len(notifications)} notifications as read"
    )
