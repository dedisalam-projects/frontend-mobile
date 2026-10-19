import 'package:flutter/material.dart';

class BestSellingWidget extends StatelessWidget {
  const BestSellingWidget({super.key});

  Widget _buildBestSellingItem(
      String title, String category, int percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    category,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 100,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 100 * (percentage / 100),
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '%$percentage',
                    style: TextStyle(
                        color: color, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Best Selling Products',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildBestSellingItem('Space T-Shirt', 'Clothing', 50, Colors.orange),
            _buildBestSellingItem('Portal Sticker', 'Accessories', 16, Colors.cyan),
            _buildBestSellingItem('Supernova Sticker', 'Accessories', 67, Colors.pink),
            _buildBestSellingItem('Wonders Notebook', 'Office', 35, Colors.green),
            _buildBestSellingItem('Mat Black Case', 'Accessories', 75, Colors.purple),
            _buildBestSellingItem('Robots T-Shirt', 'Clothing', 40, Colors.teal),
          ],
        ),
      ),
    );
  }
}
