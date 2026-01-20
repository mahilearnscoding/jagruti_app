// File: lib/models/child.dart

class Child {
  final String id;
  final String name;
  final int age;
  final String guardianName;
  final String location;
  final List<String> tags; // <--- The usual suspect for crashing
  
  Child({
    required this.id,
    required this.name,
    required this.age,
    required this.guardianName,
    required this.location,
    required this.tags,
  });

  factory Child.fromMap(Map<String, dynamic> map) {
    return Child(
      id: map['\$id'] ?? '',
      name: map['name'] ?? 'Unknown',
      // Safely handles age as String ("5") or Int (5)
      age: map['age'] != null ? int.tryParse(map['age'].toString()) ?? 0 : 0, 
      guardianName: map['guardian_name'] ?? 'No Guardian',
      location: map['location'] ?? '',
      
      // *** THE CRASH FIX ***
      // This forces the "dynamic list" to become a "String list" safely
      tags: List<String>.from(map['tags'] ?? []), 
    );
  }
}