import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/apartment_model.dart';
import '../../models/location_model.dart';
import '../../providers/user_provider.dart';
import '../../services/database_service.dart';

class AddApartmentScreen extends StatefulWidget {
  final VoidCallback? onSuccess;
  const AddApartmentScreen({super.key, this.onSuccess});

  @override
  State<AddApartmentScreen> createState() => _AddApartmentScreenState();
}

class _AddApartmentScreenState extends State<AddApartmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _propertyTypeController = TextEditingController(text: 'Apartment');
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _floorAreaController = TextEditingController();
  
  final _provinceController = TextEditingController();
  final _cityController = TextEditingController();
  final _barangayController = TextEditingController();
  final _streetController = TextEditingController();
  final _landmarkController = TextEditingController();

  bool _isFurnished = false;
  bool _hasParking = false;
  bool _isPetFriendly = false;

  final List<String> _selectedAmenities = [];
  final List<String> _amenityOptions = [
    'Wi-Fi', 'Parking', 'Air Conditioning', 'Balcony', 
    'Kitchen', 'Security', 'Laundry Area', 'CCTV', 'Swimming Pool', 'Gym'
  ];

  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImages() async {
    final List<XFile> selectedImages = await _picker.pickMultiImage();
    if (selectedImages.isNotEmpty) {
      setState(() {
        _images.addAll(selectedImages.map((xFile) => File(xFile.path)));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _saveApartment() async {
    if (_formKey.currentState!.validate()) {
      if (_images.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one image.'), behavior: SnackBarBehavior.floating),
        );
        return;
      }

      setState(() => _isLoading = true);
      try {
        final user = Provider.of<UserProvider>(context, listen: false).user;
        
        ApartmentModel newApt = ApartmentModel(
          id: '',
          landlordId: user!.uid,
          landlordName: user.fullName,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          propertyType: _propertyTypeController.text.trim(),
          bedrooms: int.parse(_bedroomsController.text.trim()),
          bathrooms: int.parse(_bathroomsController.text.trim()),
          floorArea: double.parse(_floorAreaController.text.trim()),
          amenities: _selectedAmenities,
          imageUrls: [],
          status: 'Available',
          createdAt: DateTime.now(),
          location: LocationModel(
            province: _provinceController.text.trim(),
            cityMunicipality: _cityController.text.trim(),
            barangay: _barangayController.text.trim(),
            streetAddress: _streetController.text.trim().isEmpty ? null : _streetController.text.trim(),
            landmark: _landmarkController.text.trim().isEmpty ? null : _landmarkController.text.trim(),
          ),
          isFurnished: _isFurnished,
          hasParking: _hasParking,
          isPetFriendly: _isPetFriendly,
          contactNumber: user.contactNumber,
        );

        await DatabaseService().addApartment(newApt, _images);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Property listed successfully!'), behavior: SnackBarBehavior.floating));
          if (widget.onSuccess != null) {
            widget.onSuccess!();
          } else {
            Navigator.pop(context);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), behavior: SnackBarBehavior.floating));
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
        title: const Text('List New Property', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  _buildSectionTitle('Property Images', theme),
                  const SizedBox(height: 16),
                  _buildImagePicker(theme),
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle('Basic Information', theme),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Listing Title', hintText: 'e.g. Modern Studio Apartment'),
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Description', hintText: 'Tell tenants about your property...'),
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
                        child: TextFormField(
                          controller: _propertyTypeController,
                          decoration: const InputDecoration(labelText: 'Property Type'),
                          validator: (val) => val!.isEmpty ? 'Required' : null,
                        ),
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
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _streetController,
                    decoration: const InputDecoration(labelText: 'Street Address (Optional)'),
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
                  
                  _buildSectionTitle('Features & Amenities', theme),
                  const SizedBox(height: 16),
                  _buildFeatureSwitch('Furnished', _isFurnished, (v) => setState(() => _isFurnished = v)),
                  _buildFeatureSwitch('Parking Available', _hasParking, (v) => setState(() => _hasParking = v)),
                  _buildFeatureSwitch('Pet-Friendly', _isPetFriendly, (v) => setState(() => _isPetFriendly = v)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _amenityOptions.map((amenity) {
                      final isSelected = _selectedAmenities.contains(amenity);
                      return FilterChip(
                        label: Text(amenity),
                        selected: isSelected,
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              _selectedAmenities.add(amenity);
                            } else {
                              _selectedAmenities.remove(amenity);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: _saveApartment,
                    child: const Text('Publish Listing'),
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

  Widget _buildImagePicker(ThemeData theme) {
    return Column(
      children: [
        if (_images.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length + 1,
              itemBuilder: (context, index) {
                if (index == _images.length) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: _pickImages,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 120,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                        ),
                        child: Icon(Icons.add_a_photo_outlined, color: theme.colorScheme.primary),
                      ),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(_images[index], width: 120, height: 120, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        else
          InkWell(
            onTap: _pickImages,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_outlined, size: 48, color: theme.colorScheme.primary),
                  const SizedBox(height: 12),
                  Text('Upload Property Photos', style: theme.textTheme.titleSmall),
                  Text('Add at least 1 clear photo', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
          ),
      ],
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
}
