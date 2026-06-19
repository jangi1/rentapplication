import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/database_service.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  File? _idImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _idImage = File(image.path);
      });
    }
  }

  void _submit() async {
    if (_idImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an ID image first.'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      await DatabaseService().submitVerification(user!.uid, _idImage!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification submitted successfully!'), behavior: SnackBarBehavior.floating),
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
    final user = Provider.of<UserProvider>(context).user;
    final theme = Theme.of(context);
    final status = user?.verificationStatus ?? 'None';

    return Scaffold(
      appBar: AppBar(
        title: const Text('ID Verification', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Verify Identity',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Upload a government-issued ID to gain the "Verified Landlord" badge and build trust with potential tenants.',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 32),
            _buildStatusBadge(status, theme),
            const SizedBox(height: 32),
            if (status == 'None' || status == 'Rejected') ...[
              Text(
                'Select ID Photo',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildImageUploader(theme),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Submit for Review'),
              ),
            ] else ...[
              _buildInfoSection(status, theme),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, ThemeData theme) {
    Color color = Colors.grey;
    String text = 'Not Started';
    IconData icon = Icons.info_outline;

    if (status == 'Pending') {
      color = Colors.orange;
      text = 'Review in Progress';
      icon = Icons.hourglass_top_rounded;
    } else if (status == 'Verified') {
      color = Colors.green;
      text = 'Verified Landlord';
      icon = Icons.verified_rounded;
    } else if (status == 'Rejected') {
      color = Colors.red;
      text = 'Verification Failed';
      icon = Icons.error_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status',
                style: theme.textTheme.labelSmall?.copyWith(color: color.withValues(alpha: 0.7)),
              ),
              Text(
                text,
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploader(ThemeData theme) {
    return InkWell(
      onTap: _pickImage,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.dividerColor, style: BorderStyle.solid),
        ),
        child: _idImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.file(_idImage!, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, size: 48, color: theme.colorScheme.primary),
                  const SizedBox(height: 12),
                  const Text('Click to take or upload ID photo', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text('Ensure all details are readable', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
      ),
    );
  }

  Widget _buildInfoSection(String status, ThemeData theme) {
    String title = '';
    String description = '';
    
    if (status == 'Pending') {
      title = 'Under Review';
      description = 'Our team is verifying your documents. This usually takes 24-48 hours. We will notify you via email once completed.';
    } else if (status == 'Verified') {
      title = 'Verification Successful';
      description = 'Your account is now fully verified. You can now enjoy full access to all landlord features and a trust badge on your profile.';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7), height: 1.5),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
