class FilterModel {
  String? province;
  String? city;
  String? barangay;
  double? minPrice;
  double? maxPrice;
  String? propertyType;
  int? bedrooms;
  int? bathrooms;
  bool? isFurnished;
  bool? hasParking;
  bool? isPetFriendly;
  bool onlyAvailable;

  FilterModel({
    this.province,
    this.city,
    this.barangay,
    this.minPrice,
    this.maxPrice,
    this.propertyType,
    this.bedrooms,
    this.bathrooms,
    this.isFurnished,
    this.hasParking,
    this.isPetFriendly,
    this.onlyAvailable = true,
  });

  bool get isEmpty =>
      province == null &&
      city == null &&
      barangay == null &&
      minPrice == null &&
      maxPrice == null &&
      (propertyType == null || propertyType == 'All') &&
      bedrooms == null &&
      bathrooms == null &&
      isFurnished == null &&
      hasParking == null &&
      isPetFriendly == null &&
      onlyAvailable == true;
}
