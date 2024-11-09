import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../models/location.dart';
import '../providers/theme_provider.dart';
import '../services/location_service.dart';
import '../utils/constants.dart';
import '../widgets/add_edit_location_dialog.dart';
import '../widgets/location_details_dialog.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LocationService _locationService = LocationService();
  GoogleMapController? _mapController;
  Position? _currentPosition;
  String _errorMessage = '';
  Set<Marker> _markers = {};
  List<Location> locations = [];
  String _searchQuery = '';
  Map<String, BitmapDescriptor> _categoryMarkerIcons = {};

  @override
  void initState() {
    super.initState();
    _createCategoryMarkerIcons().then((_) {
      _checkPermissionAndGetLocation();
      _fetchLocations();
    });
  }

  ScaffoldMessengerState get scaffoldMessenger => ScaffoldMessenger.of(context);

  Future<void> _createCategoryMarkerIcons() async {
    for (var entry in CategoryIcons.icons.entries) {
      final iconData = entry.value.$1;
      final color = entry.value.$2;
      final markerIcon = await _createCustomMarkerIcon(iconData, color);
      _categoryMarkerIcons[entry.key] = markerIcon;
    }
  }

  Future<BitmapDescriptor> _createCustomMarkerIcon(
      IconData iconData, Color color) async {
    final size = const Size(96, 96);
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    // Draw white circle background
    final Paint circlePaint = Paint()..color = Colors.white;
    canvas.drawCircle(size.center(Offset.zero), 40, circlePaint);

    // Draw colored border
    final Paint borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(size.center(Offset.zero), 40, borderPaint);

    // Draw icon
    TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: 48,
        fontFamily: iconData.fontFamily,
        color: color,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      size.center(Offset(-textPainter.width / 2, -textPainter.height / 2)),
    );

    final picture = pictureRecorder.endRecording();
    final image =
        await picture.toImage(size.width.toInt(), size.height.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  Future<void> _fetchLocations() async {
    try {
      final fetchedLocations = await _locationService.fetchLocations();
      if (mounted) {
        setState(() {
          locations = fetchedLocations;
          _createMarkers();
        });
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Error fetching locations: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _createMarkers() {
    _markers = locations.map((location) {
      final categoryIcon = _categoryMarkerIcons[location.category] ??
          _categoryMarkerIcons['Other'] ??
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);

      return Marker(
        markerId: MarkerId(location.id.toString()),
        position: LatLng(location.latitude, location.longitude),
        onTap: () => _showLocationDetails(location),
        icon: categoryIcon,
      );
    }).toSet();
  }

  void _showLocationDetails(Location location) {
    showDialog(
      context: context,
      builder: (context) => LocationDetailsDialog(
        location: location,
        onEdit: _editLocation,
        onDelete: _deleteLocation,
        onClose: () => Navigator.pop(context),
        onNavigate: (lat, lng) {
          _mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(lat, lng),
                zoom: 18,
              ),
            ),
          );
          Navigator.pop(context);
        },
        getDistanceString: _getDistanceString,
      ),
    );
  }

  Future<void> _checkPermissionAndGetLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _errorMessage = 'Location services are disabled.';
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _errorMessage = 'Location permissions are denied.';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _errorMessage = 'Location permissions are permanently denied.';
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
        _errorMessage = '';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error getting location: $e';
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    await _checkPermissionAndGetLocation();
    if (_currentPosition != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target:
                LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            zoom: 15,
          ),
        ),
      );
    }
  }

  void _editLocation(Location location) async {
    showDialog(
      context: context,
      builder: (context) => AddEditLocationDialog(
        location: location,
        onSave: (pseudo, numero, category) async {
          Navigator.pop(context);
          try {
            await _locationService.updateLocation(
              location.id,
              pseudo,
              numero,
              category,
            );
            if (mounted) {
              scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text('Location updated successfully')),
              );
              _fetchLocations();
            }
          } catch (e) {
            if (mounted) {
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text('Error updating location: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  String _getDistanceString(double lat, double lng) {
    if (_currentPosition == null) return '';

    double distanceInMeters = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      lat,
      lng,
    );

    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()}m';
    } else {
      double distanceInKm = distanceInMeters / 1000;
      return '${distanceInKm.toStringAsFixed(1)}km';
    }
  }

  void _addNewLocation(LatLng position) async {
    showDialog(
      context: context,
      builder: (context) => AddEditLocationDialog(
        onSave: (pseudo, numero, category) async {
          Navigator.pop(context);
          try {
            await _locationService.addLocation(
              pseudo,
              numero,
              position.latitude,
              position.longitude,
              category,
            );
            if (mounted) {
              scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text('Location added successfully')),
              );
              _fetchLocations();
            }
          } catch (e) {
            if (mounted) {
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text('Error adding location: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  Future<void> _deleteLocation(Location location) async {
    try {
      await _locationService.deleteLocation(location.id);
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Location deleted successfully')),
        );
        _fetchLocations();
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Error deleting location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 50),
          child: AppBar(
            title: const Text(
              'My Favorite Locations',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? Colors.white.withOpacity(0.95)
                : Colors.black.withOpacity(0.95),
            elevation: 0,
            centerTitle: true,
            actions: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 50),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return RotationTransition(
                    turns: animation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: IconButton(
                  key:
                      ValueKey<bool>(context.watch<ThemeProvider>().isDarkMode),
                  icon: Icon(
                    context.watch<ThemeProvider>().isDarkMode
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                  ),
                  onPressed: () {
                    context.read<ThemeProvider>().toggleTheme();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: _errorMessage.isNotEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _checkPermissionAndGetLocation,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : _currentPosition == null
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                        ),
                        zoom: 15,
                      ),
                      onMapCreated: (controller) {
                        _mapController = controller;
                        context
                            .read<ThemeProvider>()
                            .setMapController(controller);
                        final isDark =
                            Theme.of(context).brightness == Brightness.dark;
                        if (isDark) {
                          controller.setMapStyle(ThemeProvider.darkMapStyle);
                        }
                      },
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: true,
                      mapToolbarEnabled: false,
                      markers: _markers,
                      onTap: _addNewLocation,
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: MediaQuery.of(context).size.height * 0.9,
                      child: DraggableScrollableSheet(
                        initialChildSize: 0.4,
                        minChildSize: 0.25,
                        maxChildSize: 0.9,
                        snap: true,
                        snapSizes: const [0.4, 0.9],
                        builder: (context, scrollController) {
                          return NotificationListener<
                              DraggableScrollableNotification>(
                            onNotification: (notification) {
                              // Optional: Add custom behavior based on sheet position
                              return false;
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.white
                                    : Colors.grey.shade900,
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(28)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 0,
                                    blurRadius: 10,
                                    offset: const Offset(0, -2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Handle bar
                                  Container(
                                    margin: const EdgeInsets.only(
                                        top: 12, bottom: 8),
                                    width: 40,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.grey[300]
                                          : Colors.grey[700],
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  // Content
                                  Expanded(
                                    child: ListView(
                                      controller: scrollController,
                                      padding: EdgeInsets.zero,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 4,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Locations (${locations.length})',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.refresh),
                                                onPressed: () {
                                                  _fetchLocations();
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Search field
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          child: TextField(
                                            decoration: InputDecoration(
                                              hintText:
                                                  'Search by name, phone or category...',
                                              hintStyle: TextStyle(
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.light
                                                    ? Colors.grey.shade500
                                                    : Colors.grey.shade400,
                                                fontSize: 14,
                                              ),
                                              prefixIcon: Icon(
                                                Icons.search_rounded,
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.light
                                                    ? Colors.blue.shade400
                                                    : Colors.blue.shade200,
                                              ),
                                              suffixIcon: _searchQuery
                                                      .isNotEmpty
                                                  ? IconButton(
                                                      icon: Icon(
                                                        Icons.clear_rounded,
                                                        color: Theme.of(context)
                                                                    .brightness ==
                                                                Brightness.light
                                                            ? Colors
                                                                .grey.shade600
                                                            : Colors
                                                                .grey.shade400,
                                                        size: 20,
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          _searchQuery = '';
                                                        });
                                                        FocusScope.of(context)
                                                            .unfocus();
                                                      },
                                                    )
                                                  : null,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.light
                                                      ? Colors.grey.shade300
                                                      : Colors.grey.shade700,
                                                  width: 1,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.light
                                                      ? Colors.grey.shade300
                                                      : Colors.grey.shade700,
                                                  width: 1,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.light
                                                      ? Colors.blue.shade300
                                                      : Colors.blue.shade200,
                                                  width: 2,
                                                ),
                                              ),
                                              filled: true,
                                              fillColor: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.light
                                                  ? Colors.grey.shade50
                                                  : Colors.grey.shade800,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 12,
                                              ),
                                            ),
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.light
                                                  ? Colors.grey.shade800
                                                  : Colors.grey.shade100,
                                            ),
                                            onChanged: (value) {
                                              setState(() {
                                                _searchQuery =
                                                    value.toLowerCase();
                                              });
                                            },
                                          ),
                                        ),
                                        // Locations list
                                        ...locations
                                            .where((location) =>
                                                location.pseudo
                                                    .toLowerCase()
                                                    .contains(_searchQuery) ||
                                                location.numero
                                                    .toLowerCase()
                                                    .contains(_searchQuery) ||
                                                location.category
                                                    .toLowerCase()
                                                    .contains(_searchQuery))
                                            .map((location) => ListTile(
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                    horizontal: 16,
                                                    vertical: 4,
                                                  ),
                                                  leading: CircleAvatar(
                                                    backgroundColor: CategoryIcons
                                                            .getCategoryData(
                                                                location
                                                                    .category)
                                                        .$2
                                                        .withOpacity(0.1),
                                                    child: Icon(
                                                      CategoryIcons
                                                              .getCategoryData(
                                                                  location
                                                                      .category)
                                                          .$1,
                                                      color: CategoryIcons
                                                              .getCategoryData(
                                                                  location
                                                                      .category)
                                                          .$2,
                                                      size: 20,
                                                    ),
                                                  ),
                                                  title: Text(
                                                    location.pseudo,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  subtitle: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.phone,
                                                        size: 14,
                                                        color: Colors
                                                            .grey.shade600,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        location.numero,
                                                        style: TextStyle(
                                                          color: Colors
                                                              .grey.shade600,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Icon(
                                                        Icons.place_outlined,
                                                        size: 12,
                                                        color: Colors
                                                            .grey.shade400,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        _getDistanceString(
                                                            location.latitude,
                                                            location.longitude),
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color: Colors
                                                              .grey.shade500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  trailing: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons.edit,
                                                          color: Colors.blue,
                                                        ),
                                                        onPressed: () =>
                                                            _editLocation(
                                                                location),
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons.navigation,
                                                          color: Colors.blue,
                                                        ),
                                                        onPressed: () {
                                                          _mapController
                                                              ?.animateCamera(
                                                            CameraUpdate
                                                                .newCameraPosition(
                                                              CameraPosition(
                                                                target: LatLng(
                                                                  location
                                                                      .latitude,
                                                                  location
                                                                      .longitude,
                                                                ),
                                                                zoom: 18,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons.delete_outline,
                                                          color: Colors.red,
                                                        ),
                                                        onPressed: () =>
                                                            _deleteLocation(
                                                                location),
                                                      ),
                                                    ],
                                                  ),
                                                  onTap: () =>
                                                      _showLocationDetails(
                                                          location),
                                                )),
                                        // Bottom padding
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .padding
                                                  .bottom +
                                              16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      right: 14,
                      bottom: 16,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 50),
                        child: FloatingActionButton(
                          onPressed: _getCurrentLocation,
                          elevation: 2,
                          backgroundColor:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.white
                                  : Colors.grey.shade800,
                          foregroundColor:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.black87
                                  : Colors.white,
                          child: const Icon(Icons.my_location),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
