import 'package:flutter/material.dart';
import '../models/location.dart';
import '../utils/constants.dart';

class LocationDetailsDialog extends StatelessWidget {
  final Location location;
  final Function(Location) onEdit;
  final Function(Location) onDelete;
  final Function() onClose;
  final Function(double, double) onNavigate;
  final String Function(double, double) getDistanceString;

  const LocationDetailsDialog({
    Key? key,
    required this.location,
    required this.onEdit,
    required this.onDelete,
    required this.onClose,
    required this.onNavigate,
    required this.getDistanceString,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.grey.shade50
          : Colors.grey.shade900,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                location.pseudo,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 24,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.edit_rounded,
                                color: Colors.blue,
                                size: 20,
                              ),
                              onPressed: () {
                                onClose();
                                onEdit(location);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 24,
                  top: -12,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: onClose,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.close_rounded,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor:
                          CategoryIcons.getCategoryData(location.category)
                              .$2
                              .withOpacity(0.1),
                      child: Icon(
                        CategoryIcons.getCategoryData(location.category).$1,
                        color:
                            CategoryIcons.getCategoryData(location.category).$2,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      location.category,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: const Text('Category'),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.blue.shade50
                              : Colors.blue.shade900.withOpacity(0.2),
                      child: const Icon(
                        Icons.phone,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                    title: Text(location.numero),
                    subtitle: const Text('Phone Number'),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.orange.shade50
                              : Colors.orange.shade900.withOpacity(0.2),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.orange,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'Lat: ${location.latitude.toStringAsFixed(6)}\nLng: ${location.longitude.toStringAsFixed(6)}',
                    ),
                    subtitle: Text(
                      'Distance: ${getDistanceString(location.latitude, location.longitude)}',
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        onClose();
                        onDelete(location);
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      label: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () =>
                          onNavigate(location.latitude, location.longitude),
                      icon: const Icon(Icons.navigation_rounded),
                      label: const Text('Navigate'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
