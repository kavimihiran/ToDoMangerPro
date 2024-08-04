class Label {
  final String id;
  String name;

  Label({required this.id, required this.name});

  factory Label.fromMap(Map<String, dynamic> map) {
    return Label(
      id: map['id'] as String,
      name: map['name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}
