import 'package:flutter/material.dart';
import 'package:travel_wishlist/models/place.dart';
import 'package:travel_wishlist/core/services/firebase_service.dart';

class PlaceCard extends StatefulWidget {
  final Place place;
  final VoidCallback onPlaceUpdated;
  final bool isVisitedScreen;

  const PlaceCard({
    Key? key,
    required this.place,
    required this.onPlaceUpdated,
    this.isVisitedScreen = false,
  }) : super(key: key);

  @override
  State<PlaceCard> createState() => _PlaceCardState();
}

class _PlaceCardState extends State<PlaceCard> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.place.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: widget.isVisitedScreen ? Colors.red : Colors.green,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.isVisitedScreen ? Icons.delete : Icons.check_circle,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              widget.isVisitedScreen ? 'Delete' : 'Mark as Visited',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (widget.isVisitedScreen) {
          return await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Delete Place'),
                  content: Text(
                    'Delete ${widget.place.name} from visited places?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
          );
        } else {
          return await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Mark as Visited'),
                  content: Text('Have you visited ${widget.place.name}?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Yes',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
          );
        }
      },
      onDismissed: (direction) async {
        try {
          if (widget.isVisitedScreen) {
            await _firebaseService.deletePlace(widget.place.id);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${widget.place.name} has been deleted'),
                duration: const Duration(seconds: 2),
              ),
            );
          } else {
            await _firebaseService.updatePlace(
              widget.place.id,
              widget.place.name,
              widget.place.description,
              widget.place.imageUrl,
              true, // isVisited
            );
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${widget.place.name} marked as visited!'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
          widget.onPlaceUpdated();
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          title: Text(
            widget.place.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(widget.place.description),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              widget.place.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
            ),
          ),
          onTap:
              () =>
                  widget.isVisitedScreen
                      ? null
                      : _showPlaceOptions(context, widget.place),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          widget.place.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(widget.place.description),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            widget.place.imageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
          ),
        ),
      ),
    );
  }

  // Keep _showPlaceOptions method for non-visited places
  Future<void> _showPlaceOptions(BuildContext context, Place place) async {
    if (widget.isVisitedScreen) return;

    final nameController = TextEditingController(text: place.name);
    final descriptionController = TextEditingController(
      text: place.description,
    );
    final imageUrlController = TextEditingController(text: place.imageUrl);

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Destination'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Place Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Image URL',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final bool? confirm = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Delete Place'),
                          content: Text('Delete ${place.name}?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                  );

                  if (confirm == true && mounted) {
                    await _firebaseService.deletePlace(place.id);
                    if (!mounted) return;
                    Navigator.pop(context);
                    widget.onPlaceUpdated();
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
              FilledButton(
                onPressed: () async {
                  await _firebaseService.updatePlace(
                    place.id,
                    nameController.text,
                    descriptionController.text,
                    imageUrlController.text,
                  );
                  if (!mounted) return;
                  Navigator.pop(context);
                  widget.onPlaceUpdated();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${place.name} updated successfully'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text('Save Changes'),
              ),
            ],
          ),
    );

    // Dispose controllers
    nameController.dispose();
    descriptionController.dispose();
    imageUrlController.dispose();
  }
}
