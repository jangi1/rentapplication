import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/location_model.dart';
import '../../providers/user_provider.dart';
import '../../services/database_service.dart';
import 'landlord_dashboard.dart';

class LocationSetupScreen extends StatefulWidget {
  const LocationSetupScreen({super.key});

  @override
  State<LocationSetupScreen> createState() => _LocationSetupScreenState();
}

class _LocationSetupScreenState extends State<LocationSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _provinceController = TextEditingController();
  final _cityController = TextEditingController();
  final _barangayController = TextEditingController();
  final _streetController = TextEditingController();
  final _landmarkController = TextEditingController();
  bool _isLoading = false;

  Future<void> _saveLocation() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final user = userProvider.user;

        if (user != null) {
          final location = LocationModel(
            province: _provinceController.text.trim(),
            cityMunicipality: _cityController.text.trim(),
            barangay: _barangayController.text.trim(),
            streetAddress: _streetController.text.trim().isEmpty ? null : _streetController.text.trim(),
            landmark: _landmarkController.text.trim().isEmpty ? null : _landmarkController.text.trim(),
          );

          await DatabaseService().updateUserLocation(user.uid, location);
          
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LandlordDashboard()),
            );
          }
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Setup', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Landlord Location',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Provide your general service area. This helps tenants find your properties easily.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _provinceController,
                    decoration: const InputDecoration(labelText: 'Province', prefixIcon: Icon(Icons.map_outlined)),
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(labelText: 'City / Municipality', prefixIcon: Icon(Icons.location_city_outlined)),
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _barangayController,
                    decoration: const InputDecoration(labelText: 'Barangay', prefixIcon: Icon(Icons.place_outlined)),
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _streetController,
                    decoration: const InputDecoration(labelText: 'Street Address (Optional)', prefixIcon: Icon(Icons.home_outlined)),
                  ),
                  const SizedBox(height: 20),
                   TextFormField(
                    controller: _landmarkController,
                    decoration: const InputDecoration(labelText: 'Nearby Landmark (Optional)', prefixIcon: Icon(Icons.near_me_outlined)),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: _saveLocation,
                    child: const Text('Complete Setup'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
    );
  }
}
