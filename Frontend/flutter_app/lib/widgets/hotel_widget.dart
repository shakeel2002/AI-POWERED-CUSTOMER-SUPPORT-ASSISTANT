import 'package:flutter/material.dart';

class HotelWidget extends StatelessWidget {
  final List<dynamic> data;

  const HotelWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No hotels found.'),
      );
    }

    return SizedBox(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: data.length,
        itemBuilder: (context, index) {
          final hotel = data[index];
          final name = hotel['name'] ?? 'No name';
          final price = hotel['price']?.toString() ?? '-';
          final rating = hotel['rating']?.toString() ?? '-';

          return SizedBox(
            width: 260,
            child: Card(
              margin: const EdgeInsets.all(12.0),
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Placeholder image
                  Container(
                    height: 140,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: Image.network(
                      'https://via.placeholder.com/400x200.png?text=Hotel',
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('\$\$price',
                                style: const TextStyle(fontSize: 14)),
                            Row(
                              children: [
                                const Icon(Icons.star, size: 14),
                                const SizedBox(width: 4),
                                Text(rating),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
