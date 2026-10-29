import 'package:flutter/material.dart';

import '../services/inaturalist_service.dart';
import '../models/bird_species.dart';
import 'species_detail_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final INaturalistService _iNaturalistService = INaturalistService();

  final TextEditingController _searchController = TextEditingController();

  List<BirdSpecies> _birds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  Future<void> _loadCatalog({String query = ''}) async {
    setState(() => _isLoading = true);

    try {
      final results = await _iNaturalistService.fetchBirdCatalog(query: query);

      if (!mounted) return;

      setState(() {
        _birds = results;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _birds = [];
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memuat katalog burung. Silakan coba lagi.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Katalog Burung',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1B5E20),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari nama burung atau spesies...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF1B5E20)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                          _loadCatalog();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (_) {
                setState(() {});
              },
              onSubmitted: (value) {
                _loadCatalog(query: value.trim());
              },
            ),
          ),

          // Grid Daftar Burung
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF1B5E20)),
                  )
                : _birds.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 56,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Spesies burung tidak ditemukan.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () {
                              _loadCatalog(
                                query: _searchController.text.trim(),
                              );
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba lagi'),
                          ),
                        ],
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: _birds.length,
                    itemBuilder: (context, index) {
                      final bird = _birds[index];

                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SpeciesDetailScreen(species: bird),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: SizedBox(
                                  width: double.infinity,
                                  child:
                                      bird.imageUrl != null &&
                                          bird.imageUrl!.isNotEmpty
                                      ? Image.network(
                                          bird.imageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey[300],
                                                  alignment: Alignment.center,
                                                  child: const Icon(
                                                    Icons.pets,
                                                    color: Colors.grey,
                                                    size: 40,
                                                  ),
                                                );
                                              },
                                        )
                                      : Container(
                                          color: Colors.grey[300],
                                          alignment: Alignment.center,
                                          child: const Icon(
                                            Icons.pets,
                                            color: Colors.grey,
                                            size: 40,
                                          ),
                                        ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      bird.commonName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      bird.scientificName,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
    );
  }
}
