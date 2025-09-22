// Model classes for property data
enum OwnershipType { owned, rented, managed }

enum PropertyType { villa, apartment, shop }

enum FurnishingType { furnished, unfurnished }

enum UsageType { residential, commercial }

final List<String> ownershipOptions = ['Owned', 'Rented', 'Managed'];
final List<String> propertyOptions = ['Villa', 'Apartment', 'Shop'];
final List<String> furnishingOptions = ['Furnished', 'Unfurnished'];
final List<String> usageOptions = ['Residential', 'Commercial'];

class Property {
  final String id;
  final String address;
  final double size; // in square meters
  final OwnershipType ownershipType;
  final PropertyType propertyType;
  final FurnishingType furnishingType;
  final UsageType usageType;
  final String? imageUrl;

  const Property({
    required this.id,
    required this.address,
    required this.size,
    required this.ownershipType,
    required this.propertyType,
    required this.furnishingType,
    required this.usageType,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'ownershipType': ownershipType,
      'propertyType': propertyType,
      'furnishingType': furnishingType,
      'usageType': usageType,
      'size': size,
      'address': address,
    };
  }

  factory Property.fromJson(Map<String, dynamic> json, String id) {
    return Property(
      id: id,
      ownershipType: json['ownershipType'],
      propertyType: json['propertyType'],
      furnishingType: json['furnishingType'],
      usageType: json['usageType'],
      size: json['size'],
      address: json['address'],
    );
  }
}

// Helper method to get text representation of the enum values
String getOwnershipTypeText(OwnershipType type) {
  switch (type) {
    case OwnershipType.owned:
      return 'Owned';
    case OwnershipType.rented:
      return 'Rented';
    case OwnershipType.managed:
      return 'Managed';
  }
}

OwnershipType parseOwnershipType(String type) {
  switch (type) {
    case 'Owned':
      return OwnershipType.owned;
    case 'Rented':
      return OwnershipType.rented;
    case 'Managed':
      return OwnershipType.managed;
    default:
      throw Exception('Invalid ownership type: $type');
  }
}

String getPropertyTypeText(PropertyType type) {
  switch (type) {
    case PropertyType.villa:
      return 'Villa';
    case PropertyType.apartment:
      return 'Apartment';
    case PropertyType.shop:
      return 'Shop';
  }
}

PropertyType parsePropertyType(String type) {
  switch (type) {
    case 'Villa':
      return PropertyType.villa;
    case 'Apartment':
      return PropertyType.apartment;
    case 'Shop':
      return PropertyType.shop;
    default:
      throw Exception('Invalid property type: $type');
  }
}

String getFurnishingTypeText(FurnishingType type) {
  switch (type) {
    case FurnishingType.furnished:
      return 'Furnished';
    case FurnishingType.unfurnished:
      return 'Unfurnished';
  }
}

FurnishingType parseFurnishingType(String type) {
  switch (type) {
    case 'Furnished':
      return FurnishingType.furnished;
    case 'Unfurnished':
      return FurnishingType.unfurnished;
    default:
      throw Exception('Invalid furnishing type: $type');
  }
}

String getUsageTypeText(UsageType type) {
  switch (type) {
    case UsageType.residential:
      return 'Residential';
    case UsageType.commercial:
      return 'Commercial';
  }
}

UsageType parseUsageType(String type) {
  switch (type) {
    case 'Residential':
      return UsageType.residential;
    case 'Commercial':
      return UsageType.commercial;
    default:
      throw Exception('Invalid usage type: $type');
  }
}
