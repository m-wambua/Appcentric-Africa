class Subject {
  final int id;
  final String name;
  final String code;
  final String? description;
  final int? papersCount;

  Subject({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    this.papersCount,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      description: json['description'],
      papersCount: json['papers_count'],
    );
  }
}