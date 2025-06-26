class Scan {
  final String? id;
  final String patientId;
  final String imagePath;
  final String createdAt;

  Scan({this.id, required this.patientId, required this.imagePath, required this.createdAt});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'image_path': imagePath,
      'created_at': createdAt,
    };
  }

  factory Scan.fromMap(Map<String, dynamic> map) {
    return Scan(
      id: map['id'] as int?,
      patientId: map['patient_id'] as int,
      imagePath: map['image_path'] as String,
      createdAt: map['created_at'] as String,
    );
  }
}
