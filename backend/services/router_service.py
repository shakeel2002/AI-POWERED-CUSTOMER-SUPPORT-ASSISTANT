from tools.hotel_tool import hotel_tool
from tools.flight_tool import flight_tool
from tools.tracking_tool import tracking_tool
from tools.refund_tool import refund_tool
from tools.complaint_tool import complaint_tool
from tools.escalation_tool import escalation_tool

INTENT_MAP = {
    "hotel_search": hotel_tool,
    "flight_search": flight_tool,
    "order_tracking": tracking_tool,
    "refund_request": refund_tool,
    "complaint": complaint_tool,
    "escalation": escalation_tool
}

def execute(intent):

    tool = INTENT_MAP.get(intent)

    if not tool:
        return {
            "ui_type": "text",
            "message": "Unknown Intent",
            "data": []
        }

    return tool()