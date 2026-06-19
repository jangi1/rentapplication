import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/apartment_model.dart';
import '../../models/viewing_request_model.dart';
import '../../providers/user_provider.dart';
import '../../services/database_service.dart';

class RequestViewingScreen extends StatefulWidget {
  final ApartmentModel apartment;
  const RequestViewingScreen({super.key, required this.apartment});

  @override
  State<RequestViewingScreen> createState() => _RequestViewingScreenState();
}

class _RequestViewingScreenState extends State<RequestViewingScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTimeSlot = 'Morning (9:00 AM - 12:00 PM)';
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;

  final List<String> _timeSlots = [
    'Morning (9:00 AM - 12:00 PM)',
    'Afternoon (1:00 PM - 4:00 PM)',
    'Evening (5:00 PM - 7:00 PM)',
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitRequest() async {
    setState(() => _isLoading = true);
    try {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      
      final request = ViewingRequestModel(
        id: '',
        apartmentId: widget.apartment.id,
        propertyTitle: widget.apartment.title,
        tenantId: user!.uid,
        tenantName: user.fullName,
        landlordId: widget.apartment.landlordId,
        preferredDate: _selectedDate,
        preferredTimeSlot: _selectedTimeSlot,
        message: _messageController.text.trim(),
        status: 'Pending',
        createdAt: DateTime.now(),
      );

      await DatabaseService().requestViewing(request);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Viewing request sent!'), behavior: SnackBarBehavior.floating),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Viewing', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Icon(Icons.home_work_outlined, size: 40, color: theme.colorScheme.primary),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.apartment.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Landlord: ${widget.apartment.landlordName}', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('Select Date', theme),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDate(context),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Icon(Icons.calendar_month_outlined, color: theme.colorScheme.primary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('Preferred Time Slot', theme),
            const SizedBox(height: 8),
            ..._timeSlots.map((slot) => RadioListTile<String>(
              title: Text(slot, style: const TextStyle(fontSize: 14)),
              value: slot,
              groupValue: _selectedTimeSlot,
              onChanged: (val) => setState(() => _selectedTimeSlot = val!),
              contentPadding: EdgeInsets.zero,
            )),
            const SizedBox(height: 32),
            _buildSectionTitle('Message (Optional)', theme),
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Ask about parking, house rules, or confirm arrival time...',
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitRequest,
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Submit Viewing Request'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}
