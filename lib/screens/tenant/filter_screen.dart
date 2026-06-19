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

  final _provinceController = TextEditingController();
  final _cityController = TextEditingController();
  final _barangayController = TextEditingController();

  final List<String> _propertyTypes = ['All', 'House', 'Apartment', 'Boarding House', 'Condominium'];
  final List<String> _bedroomOptions = ['All', 'Studio', '1', '2', '3+'];

  @override
  void initState() {
    super.initState();
    final f = widget.initialFilters;
    _currentRangeValues = RangeValues(f?.minPrice ?? 0, f?.maxPrice ?? 100000);
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
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filters', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _resetFilters,
            child: const Text('Reset'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Location', theme),
            const SizedBox(height: 16),
            TextFormField(
              controller: _provinceController,
              decoration: const InputDecoration(labelText: 'Province', prefixIcon: Icon(Icons.map_outlined)),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(labelText: 'City / Municipality', prefixIcon: Icon(Icons.location_city_outlined)),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _barangayController,
              decoration: const InputDecoration(labelText: 'Barangay', prefixIcon: Icon(Icons.place_outlined)),
            ),
            
            const SizedBox(height: 32),
            _buildSectionHeader('Price Range', theme),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _priceDisplay('Min', _currentRangeValues.start, theme),
                Icon(Icons.remove, color: theme.dividerColor),
                _priceDisplay('Max', _currentRangeValues.end, theme),
              ],
            ),
            const SizedBox(height: 16),
            RangeSlider(
              values: _currentRangeValues,
              min: 0,
              max: 100000,
              divisions: 100,
              onChanged: (values) => setState(() => _currentRangeValues = values),
            ),
            
            const SizedBox(height: 32),
            _buildSectionHeader('Property Type', theme),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _propertyTypes.map((type) => _buildChoiceChip(type, _selectedPropertyType, (val) {
                setState(() => _selectedPropertyType = val);
              }, theme)).toList(),
            ),
            
            const SizedBox(height: 32),
            _buildSectionHeader('Bedrooms', theme),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _bedroomOptions.map((opt) => _buildChoiceChip(opt, _selectedBedrooms, (val) {
                setState(() => _selectedBedrooms = val);
              }, theme)).toList(),
            ),
            
            const SizedBox(height: 32),
            _buildSectionHeader('Features', theme),
            const SizedBox(height: 8),
            _buildFeatureSwitch('Furnished', _features['Furnished']!, (v) => setState(() => _features['Furnished'] = v)),
            _buildFeatureSwitch('Parking Available', _features['Parking']!, (v) => setState(() => _features['Parking'] = v)),
            _buildFeatureSwitch('Pet-Friendly', _features['Pet-Friendly']!, (v) => setState(() => _features['Pet-Friendly'] = v)),
            _buildFeatureSwitch('Show only available', _features['Available Now']!, (v) => setState(() => _features['Available Now'] = v)),
            
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: ElevatedButton(
          onPressed: _applyFilters,
          child: const Text('Show Results'),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _priceDisplay(String label, double value, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          Text('₱${value.round()}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildChoiceChip(String label, String selectedValue, Function(String) onSelected, ThemeData theme) {
    bool isSelected = label == selectedValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) { if (selected) onSelected(label); },
      showCheckmark: false,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  void _resetFilters() {
    setState(() {
      _currentRangeValues = const RangeValues(0, 100000);
      _selectedPropertyType = 'All';
      _selectedBedrooms = 'All';
      _features.updateAll((key, value) => key == 'Available Now' ? true : false);
      _provinceController.clear();
      _cityController.clear();
      _barangayController.clear();
    });
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
