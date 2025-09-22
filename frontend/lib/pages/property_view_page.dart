import 'package:flutter/material.dart';
import '/services/auth_services.dart';
import '/services/constants.dart';
import '/services/db_service.dart';
import '/ui/dropdown.dart';
import '/ui/loading.dart';
import '/ui/snackbar.dart';
import '/utils/property.dart';

class PropertiesPage extends StatefulWidget {
  const PropertiesPage({super.key});

  @override
  State<PropertiesPage> createState() => _PropertiesPageState();
}

class _PropertiesPageState extends State<PropertiesPage> {
  late Stream<List<Property>> _propertiesStream;
  String? _selectedPropertyType;
  String? _selectedFurnishingType;
  String? _selectedOwnershipType;
  String? _selectedUsageType;
  UserMode? get _userMode => authService.value.userMode;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    setState(() {
      _loading = true;
    });
    if (_userMode == null) {
      authService.value.signOut();
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    final stream = _getPropertiesStream();
    setState(() {
      _propertiesStream = stream;
      _loading = false;
    });
  }

  Stream<List<Property>> _getPropertiesStream() {
    setState(() {
      _loading = true;
    });
    var query = db
        .collection('properties')
        .orderBy('createdAt', descending: true);

    if (_selectedPropertyType != null) {
      query = query.where('propertyType', isEqualTo: _selectedPropertyType);
    }

    if (_selectedFurnishingType != null) {
      query = query.where('furnishingType', isEqualTo: _selectedFurnishingType);
    }

    if (_selectedOwnershipType != null) {
      query = query.where('ownershipType', isEqualTo: _selectedOwnershipType);
    }

    if (_selectedUsageType != null) {
      query = query.where('usageType', isEqualTo: _selectedUsageType);
    }

    Stream<List<Property>> res = query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Property(
          id: doc.id,
          address: data['address'] ?? '',
          size: (data['size'] ?? 0).toDouble(),
          ownershipType: parseOwnershipType(data['ownershipType']),
          propertyType: parsePropertyType(data['propertyType']),
          furnishingType: parseFurnishingType(data['furnishingType']),
          usageType: parseUsageType(data['usageType']),
        );
      }).toList();
    });
    setState(() {
      _loading = false;
    });
    return res;
  }

  @override
  Widget build(BuildContext context) {
    if (_userMode != UserMode.admin) {
      Navigator.pop(context);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Properties'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/properties/add');
            },
          ),
        ],
      ),
      body:
          _loading
              ? loading()
              : RefreshIndicator.adaptive(
                onRefresh: () async {
                  setState(() {
                    _selectedPropertyType = null;
                    _selectedFurnishingType = null;
                    _selectedOwnershipType = null;
                    _selectedUsageType = null;
                  });
                  _initializeData();
                },
                child: StreamBuilder<List<Property>>(
                  stream: _propertiesStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final properties = snapshot.data ?? [];

                    return Column(
                      children: [
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const SizedBox(width: 16),
                            Expanded(
                              child: Dropdown(
                                items: propertyOptions,
                                label: "Property Type",
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedPropertyType = newValue;
                                    _propertiesStream = _getPropertiesStream();
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Dropdown(
                                items: furnishingOptions,
                                label: "Furnishing Type",
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedFurnishingType = newValue;
                                    _propertiesStream = _getPropertiesStream();
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                        ),
                        Row(
                          children: [
                            const SizedBox(width: 16),
                            Expanded(
                              child: Dropdown(
                                items: ownershipOptions,
                                label: "Ownership Type",
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedOwnershipType = newValue;
                                    _propertiesStream = _getPropertiesStream();
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Dropdown(
                                items: usageOptions,
                                label: "Usage Type",
                                onChanged: (newValue) {
                                  _selectedUsageType = newValue;
                                  _propertiesStream = _getPropertiesStream();
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                        ),

                        const Divider(),

                        // Properties
                        if (properties.isEmpty)
                          Expanded(
                            child: Center(
                              child: Text(
                                'No properties found',
                                style: TextStyle(
                                  fontFamily:
                                      TextTheme.of(
                                        context,
                                      ).bodyMedium?.fontFamily,
                                ),
                              ),
                            ),
                          )
                        else
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              itemCount: properties.length,
                              itemBuilder: (context, index) {
                                final property = properties[index];
                                return PropertyCard(property: property);
                              },
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
    );
  }
}

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
