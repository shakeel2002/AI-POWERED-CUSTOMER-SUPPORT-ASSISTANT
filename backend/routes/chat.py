from fastapi import APIRouter

from schemas.request import ChatRequest
from schemas.response import ChatResponse

from services.memory_service import MemoryService
from services.ollama_service import classify_intent
from services.router_service import execute

router = APIRouter()

@router.post(
    "/chat",
    response_model=ChatResponse
)
async def chat(request: ChatRequest):

    context = MemoryService.get_context(
        request.session_id
    )

    ai_response = classify_intent(
        request.message,
        context
    )

    intent = ai_response.get(
        "intent",
        "unknown"
    )

    tool_result = execute(intent)

    MemoryService.update_context(
        request.session_id,
        request.message,
        intent
    )

    return ChatResponse(
        success=True,
        intent=intent,
        ui_type=tool_result["ui_type"],
        message=tool_result["message"],
        data=tool_result["data"],
        memory=context
    )