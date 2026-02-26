import 'package:flutter/material.dart';
import '/services/db_service.dart';
import '/utils/property.dart';
import '/ui/snackbar.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  const PropertyCard({super.key, required this.property});

  Future<void> deleteProperty(BuildContext context, String propertyId) async {
    try {
      await db.collection('properties').doc(propertyId).delete();
      if (!context.mounted) return;
      successSnack(context, "Property deleted successfully");
      Navigator.pop(context);
    } catch (e) {
      errorSnack(context, "Error deleting property");
    }
  }

  void editProperty(BuildContext context, String propertyId) {
    Navigator.pushNamed(context, '/properties/edit', arguments: property.id);
  }

  void managePropertyContract(BuildContext context, String propertyId) {
    Navigator.pushNamed(
      context,
      '/properties/contract',
      arguments: property.id,
    );
  }

  Widget fallbackImage() {
    return Container(
      height: 120,
      width: 160,
      color: Colors.grey.shade200,
      child: const Center(child: Icon(Icons.image, size: 40)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Property image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child:
                property.imageUrl != null
                    ? Image.network(
                      property.imageUrl!,
                      height: 120,
                      width: 160,
                      fit: BoxFit.cover,
                      // Placeholder in case image fails to load
                      errorBuilder: (context, error, stackTrace) {
                        return fallbackImage();
                      },
                    )
                    : fallbackImage(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Address
                Text(
                  property.address,
                  style: TextStyle(
                    fontFamily: TextTheme.of(context).bodyMedium?.fontFamily,
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                  ),
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Property size
                Row(
                  children: [
                    Icon(Icons.square_foot, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${property.size.floor()} sq. ft.',
                      style: TextStyle(
                        fontFamily:
                            TextTheme.of(context).bodyMedium?.fontFamily,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),

                // Ownership type + Property Type
                const SizedBox(height: 6),
                FittedBox(
                  child: Row(
                    children: [
                      Text(
                        getOwnershipTypeText(property.ownershipType),
                        style: TextStyle(
                          fontFamily:
                              TextTheme.of(context).bodyMedium?.fontFamily,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const VerticalDivider(color: Colors.grey, thickness: 6),
                      Text(
                        getPropertyTypeText(property.propertyType),
                        style: TextStyle(
                          fontFamily:
                              TextTheme.of(context).bodyMedium?.fontFamily,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

                // Furnishing type + Usage Type
                FittedBox(
                  child: Row(
                    children: [
                      Text(
                        getFurnishingTypeText(property.furnishingType),
                        style: TextStyle(
                          fontFamily:
                              TextTheme.of(context).bodyMedium?.fontFamily,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const VerticalDivider(color: Colors.grey, thickness: 6),
                      Text(
                        getUsageTypeText(property.usageType),
                        style: TextStyle(
                          fontFamily:
                              TextTheme.of(context).bodyMedium?.fontFamily,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                editProperty(context, property.id);
              } else if (value == 'delete') {
                deleteProperty(context, property.id);
              } else if (value == 'contract') {
                managePropertyContract(context, property.id);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Text('Edit Property'),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('Delete Property'),
                ),
                const PopupMenuItem<String>(
                  value: 'contract',
                  child: Text("Manage Contract"),
                ),
              ];
            },
            icon: const Icon(Icons.more_vert),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
