class Patient {
  Patient copyWith({
    String? id,
    String? name,
    String? recordNumber,
    String? notes,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      recordNumber: recordNumber ?? this.recordNumber,
      notes: notes ?? this.notes,
    );
  }
  final String? id;
  final String name;
  final String recordNumber;
  final String notes;

  Patient({this.id, required this.name, required this.recordNumber, required this.notes});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': name,
      'record_number': recordNumber,
      'notes': notes,
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id']?.toString(),
      name: map['full_name'] as String,
      recordNumber: map['record_number'] as String,
      notes: map['notes'] as String,
    );
  }
}
