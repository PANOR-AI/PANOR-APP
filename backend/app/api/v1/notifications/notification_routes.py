from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
import asyncio

from app.database import get_db
from app.models.all_models import User, Notification
from app.schemas.response_envelope import success_response, error_response
from app.security import get_current_active_user
from app.core.websocket import manager

router = APIRouter(prefix="/api/notifications", tags=["notifications"])


async def create_and_push_notification(
    db: AsyncSession,
    user_id: str,
    title: str,
    message: str,
    notification_type: str = "info",
) -> Notification:
    """
    Persists a notification to the database AND immediately pushes it
    to the user's active WebSocket connection(s) if connected.
    Import and call this helper from any route that needs to notify a user.
    """
    notif = Notification(user_id=user_id, title=title, message=message)
    db.add(notif)
    await db.commit()
    await db.refresh(notif)

    # Non-blocking WebSocket push — fire and forget
    asyncio.create_task(
        manager.send_personal_message(
            {
                "event": "notification",
                "type": notification_type,
                "data": {
                    "id": notif.id,
                    "title": notif.title,
                    "message": notif.message,
                    "is_read": notif.is_read,
                    "created_at": notif.created_at.isoformat(),
                },
            },
            user_id,
        )
    )
    return notif


@router.get("")
async def get_notifications(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    """Retrieve unread and recent notifications for the logged-in user."""
    result = await db.execute(
        select(Notification)
        .where(Notification.user_id == current_user.id)
        .order_by(Notification.created_at.desc())
        .limit(50)
    )
    notifications = result.scalars().all()

    data = [
        {
            "id": n.id,
            "title": n.title,
            "message": n.message,
            "is_read": n.is_read,
            "created_at": n.created_at.isoformat(),
        }
        for n in notifications
    ]

    return success_response(data, "Notifications retrieved successfully")


@router.patch("/{notification_id}/read")
async def mark_notification_read(
    notification_id: str,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
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
    db: AsyncSession = Depends(get_db),
):
    """Mark all user notifications as read."""
    result = await db.execute(
        select(Notification)
        .where(Notification.user_id == current_user.id)
        .where(Notification.is_read == False)  # noqa: E712
    )
    notifications = result.scalars().all()
    for n in notifications:
        n.is_read = True
    await db.commit()

    return success_response(
        {"updated_count": len(notifications)},
        f"Marked {len(notifications)} notifications as read",
    )
