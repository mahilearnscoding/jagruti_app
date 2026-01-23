class Child {
  final String id;
  final String name;
  final int age;
  final String guardianName;
  final String location;
  final List<String> tags; 
  
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
      // handles age as string or int
      age: map['age'] != null ? int.tryParse(map['age'].toString()) ?? 0 : 0, 
      guardianName: map['guardian_name'] ?? 'No Guardian',
      location: map['location'] ?? '',
      tags: List<String>.from(map['tags'] ?? []), 
    );
  }
}