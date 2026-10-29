class BirdSpecies {
  final int id;
  final String commonName;
  final String scientificName;
  final String? imageUrl;
  final String? conservationStatus;
  final String? wikipediaUrl;

  BirdSpecies({
    required this.id,
    required this.commonName,
    required this.scientificName,
    this.imageUrl,
    this.conservationStatus,
    this.wikipediaUrl,
  });

  factory BirdSpecies.fromJson(Map<String, dynamic> json) {
    // Mengekstrak foto utama jika tersedia
    String? photoUrl;
    if (json['default_photo'] != null) {
      photoUrl =
          json['default_photo']['medium_url'] ?? json['default_photo']['url'];
    }

    // Mengekstrak status konservasi (misal: CR, EN, VU, LC)
    String? status;
    if (json['conservation_status'] != null) {
      status =
          json['conservation_status']['status_name'] ??
          json['conservation_status']['status'];
    }

    return BirdSpecies(
      id: json['id'] ?? 0,
      commonName:
          json['preferred_common_name'] ?? json['name'] ?? 'Tidak diketahui',
      scientificName: json['name'] ?? '',
      imageUrl: photoUrl,
      conservationStatus: status,
      wikipediaUrl: json['wikipedia_url'],
    );
  }
}
