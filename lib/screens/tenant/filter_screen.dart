import 'package:flutter/material.dart';
import '../../models/filter_model.dart';

class FilterScreen extends StatefulWidget {
  final FilterModel? initialFilters;
  const FilterScreen({super.key, this.initialFilters});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late RangeValues _currentRangeValues;
  late String _selectedPropertyType;
  late String _selectedBedrooms;
  late Map<String, bool> _features;

  // Location controllers
  final _provinceController = TextEditingController();
  final _cityController = TextEditingController();
  final _barangayController = TextEditingController();

  final List<String> _propertyTypes = ['All', 'House', 'Apartment', 'Boarding House', 'Condominium'];
  final List<String> _bedroomOptions = ['All', 'Studio', '1', '2', '3+'];

  @override
  void initState() {
    super.initState();
    final f = widget.initialFilters;
    _currentRangeValues = RangeValues(f?.minPrice ?? 0, f?.maxPrice ?? 50000);
    _selectedPropertyType = f?.propertyType ?? 'All';
    _selectedBedrooms = f?.bedrooms == null ? 'All' : (f!.bedrooms == 0 ? 'Studio' : (f.bedrooms == 3 ? '3+' : f.bedrooms.toString()));
    
    _features = {
      'Furnished': f?.isFurnished ?? false,
      'Parking': f?.hasParking ?? false,
      'Pet-Friendly': f?.isPetFriendly ?? false,
      'Available Now': f?.onlyAvailable ?? true,
    };

    _provinceController.text = f?.province ?? '';
    _cityController.text = f?.city ?? '';
    _barangayController.text = f?.barangay ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Filters', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _currentRangeValues = const RangeValues(0, 50000);
                _selectedPropertyType = 'All';
                _selectedBedrooms = 'All';
                _features.updateAll((key, value) => key == 'Available Now' ? true : false);
                _provinceController.clear();
                _cityController.clear();
                _barangayController.clear();
              });
            },
            child: const Text('Reset', style: TextStyle(color: Color(0xFF1E88E5))),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Location'),
            const SizedBox(height: 15),
            _buildLocationField(_provinceController, 'Province', 'e.g. Davao del Sur'),
            _buildLocationField(_cityController, 'City / Municipality', 'e.g. Davao City'),
            _buildLocationField(_barangayController, 'Barangay', 'e.g. Bucana'),
            
            const SizedBox(height: 20),
            _buildSectionTitle('Price Range'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('₱ ${_currentRangeValues.start.round()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('₱ ${_currentRangeValues.end.round()}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            RangeSlider(
              values: _currentRangeValues,
              min: 0,
              max: 50000,
              divisions: 50,
              activeColor: const Color(0xFF1E88E5),
              inactiveColor: Colors.blue.withValues(alpha: 0.1),
              onChanged: (RangeValues values) {
                setState(() => _currentRangeValues = values);
              },
            ),
            
            const SizedBox(height: 30),
            _buildSectionTitle('Property Type'),
            const SizedBox(height: 15),
            Wrap(
              spacing: 10,
              children: _propertyTypes.map((type) => _buildChoiceChip(type, _selectedPropertyType, (val) {
                setState(() => _selectedPropertyType = val);
              })).toList(),
            ),
            
            const SizedBox(height: 30),
            _buildSectionTitle('Bedrooms'),
            const SizedBox(height: 15),
            Wrap(
              spacing: 10,
              children: _bedroomOptions.map((opt) => _buildChoiceChip(opt, _selectedBedrooms, (val) {
                setState(() => _selectedBedrooms = val);
              })).toList(),
            ),
            
            const SizedBox(height: 30),
            _buildSectionTitle('Features'),
            const SizedBox(height: 10),
            ..._features.keys.map((key) => CheckboxListTile(
              title: Text(key),
              value: _features[key],
              activeColor: const Color(0xFF1E88E5),
              onChanged: (val) => setState(() => _features[key] = val!),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            )),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            onPressed: _applyFilters,
            child: const Text('Show Results', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _buildLocationField(TextEditingController controller, String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildChoiceChip(String label, String selectedValue, Function(String) onSelected) {
    bool isSelected = label == selectedValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) { if (selected) onSelected(label); },
      selectedColor: const Color(0xFF1E88E5),
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
      backgroundColor: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide.none),
    );
  }

  void _applyFilters() {
    int? bedrooms;
    if (_selectedBedrooms == 'Studio') {
      bedrooms = 0;
    } else if (_selectedBedrooms == '3+') {
      bedrooms = 3;
    } else if (_selectedBedrooms != 'All') {
      bedrooms = int.tryParse(_selectedBedrooms);
    }

    final filters = FilterModel(
      province: _provinceController.text.trim().isEmpty ? null : _provinceController.text.trim(),
      city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
      barangay: _barangayController.text.trim().isEmpty ? null : _barangayController.text.trim(),
      minPrice: _currentRangeValues.start,
      maxPrice: _currentRangeValues.end,
      propertyType: _selectedPropertyType,
      bedrooms: bedrooms,
      isFurnished: _features['Furnished'],
      hasParking: _features['Parking'],
      isPetFriendly: _features['Pet-Friendly'],
      onlyAvailable: _features['Available Now'] ?? true,
    );

    Navigator.pop(context, filters);
  }
}
