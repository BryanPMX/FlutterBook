/// A class representing a Contact entity in the FlutterBook app.
///
/// This class defines the structure of a contact, including id, name, email,
/// phone number, and notes.
class Contact {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final String notes;

  /// Creates a [Contact] instance.
  Contact({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.notes,
  });

  /// Creates a copy with updated fields.
  Contact copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? notes,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
    );
  }

  /// Converts the contact to a Map for DB operations.
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'notes': notes,
  };

  /// Creates a Contact from a Map.
  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'] as int?,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      notes: map['notes'] ?? '',
    );
  }
}