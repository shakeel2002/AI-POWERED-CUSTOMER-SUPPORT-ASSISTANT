from data.mock_data import HOTELS

def hotel_tool(filter_type=None):

    hotels = HOTELS

    if filter_type == "cheap":
        hotels = sorted(
            hotels,
            key=lambda x: x["price"]
        )

    return {
        "ui_type": "hotel_page",
        "message": "Hotels Found",
        "data": hotels
    }