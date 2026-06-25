class MemoryService:

    memory_store = {}

    @classmethod
    def get_context(cls, session_id):

        return cls.memory_store.get(
            session_id,
            {
                "history": [],
                "last_intent": None,
                "last_city": None
            }
        )

    @classmethod
    def update_context(
        cls,
        session_id,
        user_message,
        intent,
        city=None
    ):

        context = cls.get_context(session_id)

        context["history"].append(
            {
                "role": "user",
                "message": user_message
            }
        )

        context["last_intent"] = intent

        if city:
            context["last_city"] = city

        context["history"] = context["history"][-5:]

        cls.memory_store[session_id] = context