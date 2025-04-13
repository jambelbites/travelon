import 'package:flutter/material.dart';
import '../../core/services/firebase_service.dart';
import '../../models/data/countries.dart';
import '../../models/country.dart';

class AddPlaceScreen extends StatefulWidget {
  final VoidCallback onPlaceAdded;

  const AddPlaceScreen({Key? key, required this.onPlaceAdded})
    : super(key: key);

  @override
  _AddPlaceScreenState createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final _firebaseService = FirebaseService();
  final _searchController = TextEditingController();
  bool _isLoading = false;
  Country? _selectedCountry;
  String? _selectedContinent;
  List<Country> _filteredCountries = [];

  @override
  void initState() {
    super.initState();
    _filteredCountries = countries;
  }

  void _filterCountries(String query) {
    setState(() {
      _filteredCountries =
          countries.where((country) {
            final matchesSearch = country.name.toLowerCase().contains(
              query.toLowerCase(),
            );
            final matchesContinent =
                _selectedContinent == null ||
                country.continent == _selectedContinent;
            return matchesSearch && matchesContinent;
          }).toList();
    });
  }

  void _filterByContinent(String? continent) {
    setState(() {
      _selectedContinent = continent;
      _filterCountries(_searchController.text);
    });
  }

  Future<void> _addPlace(Country country) async {
    try {
      await _firebaseService.addPlaceToUser(
        country.name,
        country.description,
        country.imageUrl,
      );

      if (!mounted) return;

      // Call the callback to notify parent
      widget.onPlaceAdded();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Added to your wishlist!')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error adding place: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search countries...',
                    hintStyle: TextStyle(color: Colors.teal.shade300),
                    prefixIcon: Icon(Icons.search, color: Colors.teal.shade300),
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.teal.shade200),
                    ),
                  ),
                  onChanged: _filterCountries,
                ),
                const SizedBox(height: 16),
                // Continent Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _selectedContinent == null,
                        onSelected: (_) => _filterByContinent(null),
                        selectedColor: Colors.teal.shade200,
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color:
                              _selectedContinent == null
                                  ? Colors.white
                                  : Colors.teal.shade700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ...continents.map(
                        (continent) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(continent),
                            selected: _selectedContinent == continent,
                            onSelected: (_) => _filterByContinent(continent),
                            selectedColor: Colors.teal.shade200,
                            checkmarkColor: Colors.white,
                            labelStyle: TextStyle(
                              color:
                                  _selectedContinent == continent
                                      ? Colors.white
                                      : Colors.teal.shade700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredCountries.length,
              itemBuilder: (context, index) {
                final country = _filteredCountries[index];
                final isSelected = _selectedCountry?.code == country.code;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: isSelected ? 4 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isSelected ? Colors.teal : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: InkWell(
                    onTap: () => setState(() => _selectedCountry = country),
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: Image.network(
                                country.imageUrl +
                                    '?auto=format&fit=crop&w=800', // Add size optimization
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                cacheHeight: 400, // Add image caching
                                cacheWidth: 800, // Add image caching
                                loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    height: 200,
                                    width: double.infinity,
                                    color: Colors.teal.shade50,
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 200,
                                    width: double.infinity,
                                    color: Colors.teal.shade50,
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: Colors.teal.shade300,
                                    ),
                                  );
                                },
                              ),
                            ),
                            if (isSelected)
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.teal,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      country.name,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Chip(
                                    label: Text(
                                      country.continent,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    backgroundColor: Colors.teal.shade300,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                country.description,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                  height: 1.4,
                                ),
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
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient:
                _selectedCountry != null
                    ? LinearGradient(
                      colors: [Colors.teal.shade300, Colors.blue.shade400],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                    : LinearGradient(
                      colors: [Colors.grey.shade300, Colors.grey.shade400],
                    ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ElevatedButton(
            onPressed:
                _isLoading || _selectedCountry == null
                    ? null
                    : () => _addPlace(_selectedCountry!),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
            ),
            child:
                _isLoading
                    ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : const Text(
                      'Add to Wishlist',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}
