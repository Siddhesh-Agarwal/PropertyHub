import 'package:flutter/material.dart';
import '/services/auth_services.dart';
import '/services/constants.dart';
import '/services/db_service.dart';
import '/ui/dropdown.dart';
import '/ui/loading.dart';
import '/ui/error.dart';
import '/ui/property_card.dart';
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
                      return loading();
                    }
                    if (snapshot.hasError) {
                      return ErrorView(
                        error: snapshot.error.toString(),
                        onRetry: () => setState(() {}),
                      );
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
                                value: _selectedPropertyType,
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
                                value: _selectedFurnishingType,
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
                                value: _selectedOwnershipType,
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
                                value: _selectedUsageType,
                                label: "Usage Type",
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedUsageType = newValue;
                                    _propertiesStream = _getPropertiesStream();
                                  });
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
