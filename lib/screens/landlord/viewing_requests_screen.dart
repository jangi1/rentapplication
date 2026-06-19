import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/viewing_request_model.dart';
import '../../providers/user_provider.dart';
import '../../services/database_service.dart';

class ViewingRequestsScreen extends StatelessWidget {
  const ViewingRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final db = DatabaseService();
    final theme = Theme.of(context);

    if (user == null) return const Scaffold(body: Center(child: Text('Please log in.')));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Viewing Requests', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<List<ViewingRequestModel>>(
        stream: db.getLandlordViewingRequests(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState(theme);
          }

          final requests = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            itemCount: requests.length,
            itemBuilder: (context, index) => _buildRequestCard(context, requests[index], db, theme),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_month_outlined, size: 80, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.1)),
          const SizedBox(height: 24),
          Text(
            'No viewing requests',
            style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          const Text('Requested viewings will appear here', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, ViewingRequestModel req, DatabaseService db, ThemeData theme) {
    Color statusColor = Colors.orange;
    if (req.status == 'Accepted') statusColor = Colors.green;
    if (req.status == 'Declined') statusColor = Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    req.propertyTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _statusBadge(req.status, statusColor),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(req.tenantName[0].toUpperCase(), style: TextStyle(fontSize: 10, color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                Text(req.tenantName, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.event_available_outlined, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(DateFormat('MMM dd, yyyy').format(req.preferredDate), style: const TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(width: 16),
                  Icon(Icons.schedule_outlined, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(req.preferredTimeSlot, style: const TextStyle(fontSize: 12))),
                ],
              ),
            ),
            if (req.message.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                req.message,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7), fontStyle: FontStyle.italic),
              ),
            ],
            if (req.status == 'Pending') ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: () => db.updateViewingStatus(req.id, 'Accepted'),
                      style: FilledButton.styleFrom(backgroundColor: Colors.green.withValues(alpha: 0.1), foregroundColor: Colors.green),
                      child: const Text('Accept'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => db.updateViewingStatus(req.id, 'Declined'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Decline'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
