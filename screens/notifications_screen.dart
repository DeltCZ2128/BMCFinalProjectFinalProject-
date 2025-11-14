import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// A simplified, read-only screen to display notifications.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    // Helper function to format the timestamp safely
    String formatTimestamp(Timestamp? timestamp) {
      if (timestamp == null) return '';
      return DateFormat('MM/dd/yy hh:mm a').format(timestamp.toDate());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: user == null
          ? const Center(child: Text('Please log in to see notifications.'))
          : StreamBuilder<QuerySnapshot>(
              // The stream directly queries all notifications for the current user.
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .where('userId', isEqualTo: user.uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                // Standard loading and error handling.
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('You have no notifications.'),
                  );
                }

                final notificationDocs = snapshot.data!.docs;

                // This ListView ONLY builds the UI. It does not modify any data.
                return ListView.builder(
                  itemCount: notificationDocs.length,
                  itemBuilder: (context, index) {
                    final notification = notificationDocs[index].data() as Map<String, dynamic>;

                    final String title = notification['title'] ?? 'No Title';
                    final String body = notification['body'] ?? '';
                    final Timestamp? timestamp = notification['createdAt'] as Timestamp?;
                    final bool isRead = notification['isRead'] ?? true;

                    return ListTile(
                      leading: Icon(
                        isRead ? Icons.circle_outlined : Icons.circle,
                        color: isRead ? Colors.grey : Theme.of(context).colorScheme.secondary,
                        size: 12,
                      ),
                      title: Text(
                        title,
                        style: TextStyle(
                          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                      subtitle: Text('$body\n${formatTimestamp(timestamp)}'),
                      isThreeLine: true,
                    );
                  },
                );
              },
            ),
    );
  }
}
// This is the definitive fix. There is no automatic 'mark as read' logic.
