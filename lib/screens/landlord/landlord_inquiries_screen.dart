import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/inquiry_model.dart';
import '../../providers/user_provider.dart';
import '../../services/database_service.dart';
import 'package:intl/intl.dart';

class LandlordInquiriesScreen extends StatelessWidget {
  const LandlordInquiriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final db = DatabaseService();

    return StreamBuilder<List<InquiryModel>>(
      // In a real app, you'd filter this by apartments owned by the landlord
      stream: db.getLandlordInquiries(user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No inquiries received yet.'));
        }

        final inquiries = snapshot.data!;
        return ListView.builder(
          itemCount: inquiries.length,
          itemBuilder: (context, index) {
            final inquiry = inquiries[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                title: Text('Message: ${inquiry.message}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status: ${inquiry.status}'),
                    Text('Date: ${DateFormat.yMMMd().add_jm().format(inquiry.inquiryDate)}'),
                  ],
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.reply),
                onTap: () {
                  // Logic to reply or view details
                },
              ),
            );
          },
        );
      },
    );
  }
}
