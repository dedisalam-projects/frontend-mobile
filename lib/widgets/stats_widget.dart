import 'package:flutter/material.dart';

class StatsWidget extends StatelessWidget {
  const StatsWidget({super.key});

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color iconColor,
    Color iconBgColor,
    String statText,
    String statDesc,
    Color statColor,
  ) {
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor),
                ),
              ],
            ),
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.grey, fontSize: 14),
                children: [
                  TextSpan(
                    text: statText,
                    style: TextStyle(
                      color: statColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(text: statDesc),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildStatCard(
          context,
          'Orders',
          '152',
          Icons.shopping_cart,
          Colors.blue,
          Colors.blue.withValues(alpha: 0.1),
          '24 new',
          'since last visit',
          Colors.blue.shade700,
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          context,
          'Revenue',
          '\$2,100',
          Icons.attach_money,
          Colors.orange,
          Colors.orange.withValues(alpha: 0.1),
          '%52+',
          'since last week',
          Colors.orange.shade700,
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          context,
          'Customers',
          '28441',
          Icons.people,
          Colors.cyan,
          Colors.cyan.withValues(alpha: 0.1),
          '520',
          'newly registered',
          Colors.cyan.shade700,
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          context,
          'Comments',
          '152 Unread',
          Icons.comment,
          Colors.purple,
          Colors.purple.withValues(alpha: 0.1),
          '85',
          'responded',
          Colors.purple.shade700,
        ),
      ],
    );
  }
}
