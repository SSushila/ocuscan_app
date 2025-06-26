class Patient {
  final String? id;
  final String name;
  final String recordNumber;
  final String notes;

  Patient({this.id, required this.name, required this.recordNumber, required this.notes});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'record_number': recordNumber,
      'notes': notes,
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'] as int?,
      name: map['name'] as String,
      recordNumber: map['record_number'] as String,
      notes: map['notes'] as String,
    );
  }
}
