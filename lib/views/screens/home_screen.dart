import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_wishlist/viewmodels/auth/auth_bloc.dart';
import 'package:travel_wishlist/viewmodels/auth/auth_state.dart';
import 'package:travel_wishlist/core/services/firebase_service.dart';
import 'package:travel_wishlist/models/place.dart';
import 'package:travel_wishlist/views/screens/add_place_screen.dart';
import 'package:travel_wishlist/views/screens/profile_screen.dart';
import 'package:travel_wishlist/views/screens/visited_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Place> _places = [];
  List<Place> _visitedPlaces = [];
  bool _isLoading = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadBothLists();
  }

  Future<void> _loadBothLists() async {
    await Future.wait([_loadPlaces(), _loadVisitedPlaces()]);
  }

  Future<void> _loadPlaces() async {
    setState(() => _isLoading = true);
    try {
      final places = await _firebaseService.getUserPlaces();
      setState(() {
        _places = places;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading places: $e')));
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadVisitedPlaces() async {
    setState(() => _isLoading = true);
    try {
      final places = await _firebaseService.getVisitedPlaces();
      setState(() {
        _visitedPlaces = places;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsVisited(Place place) async {
    try {
      final success = await _firebaseService.updatePlace(
        place.id,
        place.name,
        place.description,
        place.imageUrl,
        true, // Mark as visited
      );

      if (success) {
        await _loadBothLists(); // Refresh both lists
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Marked as visited!')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating place: $e')));
    }
  }

  void _showEditDialog(Place place) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Edit Place'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: place.name,
                    decoration: const InputDecoration(labelText: 'Name'),
                    onChanged:
                        (value) =>
                            place = Place(
                              id: place.id,
                              name: value,
                              description: place.description,
                              imageUrl: place.imageUrl,
                              isVisited: place.isVisited,
                              createdAt: place.createdAt,
                              updatedAt: DateTime.now(),
                            ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: place.description,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                    onChanged:
                        (value) =>
                            place = Place(
                              id: place.id,
                              name: place.name,
                              description: value,
                              imageUrl: place.imageUrl,
                              isVisited: place.isVisited,
                              createdAt: place.createdAt,
                              updatedAt: DateTime.now(),
                            ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: place.imageUrl,
                    decoration: const InputDecoration(labelText: 'Image URL'),
                    onChanged:
                        (value) =>
                            place = Place(
                              id: place.id,
                              name: place.name,
                              description: place.description,
                              imageUrl: value,
                              isVisited: place.isVisited,
                              createdAt: place.createdAt,
                              updatedAt: DateTime.now(),
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
                  await _firebaseService.updatePlace(
                    place.id,
                    place.name,
                    place.description,
                    place.imageUrl,
                  );
                  if (!mounted) return;
                  Navigator.pop(context);
                  _loadPlaces();
                },
                child: const Text('Save', style: TextStyle(color: Colors.teal)),
              ),
              TextButton(
                onPressed: () async {
                  await _firebaseService.deletePlace(place.id);
                  if (!mounted) return;
                  Navigator.pop(context);
                  _loadPlaces();
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return AddPlaceScreen(
          onPlaceAdded: () {
            _loadBothLists();
            setState(() {
              _selectedIndex = 1; // Switch to wishlist tab after adding
            });
          },
        );
      case 1:
        // Wishlist tab with new design
        return Column(
          children: [
            // Header with gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal.shade300, Colors.blue.shade400],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Wishlist',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Places you want to visit',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadPlaces,
                child:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _places.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.card_travel,
                                size: 80,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Your wishlist is empty',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add destinations from Explore',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _places.length,
                          itemBuilder: (context, index) {
                            final place = _places[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                              child: InkWell(
                                // Add this InkWell
                                onTap: () => _showEditDialog(place),
                                borderRadius: BorderRadius.circular(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16),
                                      ),
                                      child: Image.network(
                                        place.imageUrl,
                                        height: 200,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            place.name,
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            place.description,
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              TextButton.icon(
                                                onPressed:
                                                    () => _markAsVisited(place),
                                                icon: const Icon(
                                                  Icons.flight_takeoff,
                                                ),
                                                label: const Text(
                                                  'Mark as Visited',
                                                ),
                                                style: TextButton.styleFrom(
                                                  foregroundColor: Colors.teal,
                                                ),
                                              ),
                                            ],
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
            ),
          ],
        );
      case 2:
        return const VisitedScreen();
      case 3:
        return ProfileScreen();
      default:
        return const Center(child: Text('Unknown Page'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('tabanog.png', height: 35, width: 35),
              const SizedBox(width: 8),
              const Text(
                'Travelón',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: _buildBody(),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.teal,
          unselectedItemColor: Colors.grey[500],
          backgroundColor: Colors.teal[50],
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite),
              label: 'Wishlist',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.place_outlined),
              activeIcon: Icon(Icons.place),
              label: 'Visited',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class AddPlaceContent extends StatelessWidget {
  final VoidCallback onPlaceAdded;

  const AddPlaceContent({Key? key, required this.onPlaceAdded})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AddPlaceScreen(onPlaceAdded: onPlaceAdded);
  }
}
