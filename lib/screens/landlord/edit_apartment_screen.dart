import 'package:flutter/material.dart';
import '../../models/apartment_model.dart';
import '../../models/location_model.dart';
import '../../services/database_service.dart';

class EditApartmentScreen extends StatefulWidget {
  final ApartmentModel apartment;
  const EditApartmentScreen({super.key, required this.apartment});

  @override
  State<EditApartmentScreen> createState() => _EditApartmentScreenState();
}

class _EditApartmentScreenState extends State<EditApartmentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _propertyTypeController;
  late TextEditingController _bedroomsController;
  late TextEditingController _bathroomsController;
  late TextEditingController _floorAreaController;
  
  late TextEditingController _provinceController;
  late TextEditingController _cityController;
  late TextEditingController _barangayController;
  late TextEditingController _streetController;
  late TextEditingController _landmarkController;

  late String _status;
  late bool _isFurnished;
  late bool _hasParking;
  late bool _isPetFriendly;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.apartment.title);
    _descriptionController = TextEditingController(text: widget.apartment.description);
    _priceController = TextEditingController(text: widget.apartment.price.toString());
    _propertyTypeController = TextEditingController(text: widget.apartment.propertyType);
    _bedroomsController = TextEditingController(text: widget.apartment.bedrooms.toString());
    _bathroomsController = TextEditingController(text: widget.apartment.bathrooms.toString());
    _floorAreaController = TextEditingController(text: widget.apartment.floorArea.toString());
    
    _provinceController = TextEditingController(text: widget.apartment.location.province);
    _cityController = TextEditingController(text: widget.apartment.location.cityMunicipality);
    _barangayController = TextEditingController(text: widget.apartment.location.barangay);
    _streetController = TextEditingController(text: widget.apartment.location.streetAddress ?? '');
    _landmarkController = TextEditingController(text: widget.apartment.location.landmark ?? '');

    _status = widget.apartment.status;
    _isFurnished = widget.apartment.isFurnished;
    _hasParking = widget.apartment.hasParking;
    _isPetFriendly = widget.apartment.isPetFriendly;
  }

  void _updateApartment() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      Map<String, dynamic> data = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'propertyType': _propertyTypeController.text.trim(),
        'bedrooms': int.parse(_bedroomsController.text.trim()),
        'bathrooms': int.parse(_bathroomsController.text.trim()),
        'floorArea': double.parse(_floorAreaController.text.trim()),
        'status': _status,
        'isFurnished': _isFurnished,
        'hasParking': _hasParking,
        'isPetFriendly': _isPetFriendly,
        'location': LocationModel(
          province: _provinceController.text.trim(),
          cityMunicipality: _cityController.text.trim(),
          barangay: _barangayController.text.trim(),
          streetAddress: _streetController.text.trim().isEmpty ? null : _streetController.text.trim(),
          landmark: _landmarkController.text.trim().isEmpty ? null : _landmarkController.text.trim(),
        ).toMap(),
      };

      try {
        await DatabaseService().updateApartment(widget.apartment.id, data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Property updated successfully!'), behavior: SnackBarBehavior.floating));
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating: $e'), behavior: SnackBarBehavior.floating));
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
        title: const Text('Edit Property', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _buildSectionTitle('Basic Information', theme),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Listing Title'),
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Price / Month', prefixText: '₱ '),
                          validator: (val) => val!.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatusDropdown(theme),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle('Location', theme),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _provinceController,
                          decoration: const InputDecoration(labelText: 'Province'),
                          validator: (val) => val!.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _cityController,
                          decoration: const InputDecoration(labelText: 'City'),
                          validator: (val) => val!.isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _barangayController,
                    decoration: const InputDecoration(labelText: 'Barangay'),
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle('Specifications', theme),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _bedroomsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Bedrooms', prefixIcon: Icon(Icons.king_bed_outlined)),
                          validator: (val) => val!.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _bathroomsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Bathrooms', prefixIcon: Icon(Icons.bathtub_outlined)),
                          validator: (val) => val!.isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                   TextFormField(
                    controller: _floorAreaController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Floor Area (sqm)', prefixIcon: Icon(Icons.square_foot_outlined)),
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle('Features', theme),
                  const SizedBox(height: 16),
                  _buildFeatureSwitch('Furnished', _isFurnished, (v) => setState(() => _isFurnished = v)),
                  _buildFeatureSwitch('Parking Available', _hasParking, (v) => setState(() => _hasParking = v)),
                  _buildFeatureSwitch('Pet-Friendly', _isPetFriendly, (v) => setState(() => _isPetFriendly = v)),
                  
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: _updateApartment,
                    child: const Text('Save Changes'),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
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

  Widget _buildFeatureSwitch(String label, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(label, style: const TextStyle(fontSize: 14)),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildStatusDropdown(ThemeData theme) {
    return DropdownButtonFormField<String>(
      value: _status,
      decoration: const InputDecoration(labelText: 'Status'),
      items: ['Available', 'Reserved', 'Rented'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _status = newValue!;
        });
      },
    );
  }
}
