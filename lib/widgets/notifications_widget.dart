import 'package:flutter/material.dart';

class NotificationsWidget extends StatelessWidget {
  const NotificationsWidget({super.key});

  Widget _buildNotificationItem(
      IconData icon, Color color, Color bgColor, Widget title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(child: title),
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
                  'Notifications',
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
            const Text(
              'TODAY',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildNotificationItem(
              Icons.attach_money,
              Colors.blue,
              Colors.blue.withValues(alpha: 0.1),
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black87),
                  children: [
                    const TextSpan(text: 'Richard Jones ', style: TextStyle(fontWeight: FontWeight.bold)),
                    const TextSpan(text: 'has purchased a blue t-shirt for '),
                    TextSpan(text: '\$79.00', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const Divider(),
            _buildNotificationItem(
              Icons.download,
              Colors.orange,
              Colors.orange.withValues(alpha: 0.1),
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black87),
                  children: [
                    const TextSpan(text: 'Your request for withdrawal of '),
                    TextSpan(text: '\$2500.00', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold)),
                    const TextSpan(text: ' has been initiated.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'YESTERDAY',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildNotificationItem(
              Icons.attach_money,
              Colors.blue,
              Colors.blue.withValues(alpha: 0.1),
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black87),
                  children: [
                    const TextSpan(text: 'Keyser Wick ', style: TextStyle(fontWeight: FontWeight.bold)),
                    const TextSpan(text: 'has purchased a black jacket for '),
                    TextSpan(text: '\$59.00', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const Divider(),
            _buildNotificationItem(
              Icons.question_mark,
              Colors.pink,
              Colors.pink.withValues(alpha: 0.1),
              RichText(
                text: const TextSpan(
                  style: TextStyle(color: Colors.black87),
                  children: [
                    TextSpan(text: 'Jane Davis ', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: 'has posted a new questions about your product.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
