class ObservationJournal {
  final int? id;
  final String speciesName;
  final String scientificName;
  final String imagePath;
  final String date;
  final String? location;
  final String? notes;

  ObservationJournal({
    this.id,
    required this.speciesName,
    required this.scientificName,
    required this.imagePath,
    required this.date,
    this.location,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'species_name': speciesName,
      'scientific_name': scientificName,
      'image_path': imagePath,
      'date': date,
      'location': location,
      'notes': notes,
    };
  }

  factory ObservationJournal.fromMap(Map<String, dynamic> map) {
    return ObservationJournal(
      id: map['id'],
      speciesName: map['species_name'],
      scientificName: map['scientific_name'],
      imagePath: map['image_path'],
      date: map['date'],
      location: map['location'],
      notes: map['notes'],
    );
  }
}
