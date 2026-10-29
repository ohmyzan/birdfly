class IdentificationResult {
  final bool isBird;
  final bool isImageValid;
  final String? commonName;
  final String? scientificName;
  final String? description;
  final String? rejectionReason;

  IdentificationResult({
    required this.isBird,
    required this.isImageValid,
    this.commonName,
    this.scientificName,
    this.description,
    this.rejectionReason,
  });

  factory IdentificationResult.fromJson(Map<String, dynamic> json) {
    return IdentificationResult(
      isBird: json['is_bird'] ?? false,
      isImageValid: json['is_image_valid'] ?? false,
      commonName: json['common_name'],
      scientificName: json['scientific_name'],
      description: json['description'],
      rejectionReason: json['rejection_reason'],
    );
  }
}
