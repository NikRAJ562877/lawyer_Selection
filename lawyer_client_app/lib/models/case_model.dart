// models/case_model.dart

class Case {
  final String title;
  final String description;
  final String caseType;

  Case({
    required this.title,
    required this.description,
    required this.caseType,
  });

  // Method to convert a Case instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'caseType': caseType,
    };
  }

  // Method to create a Case instance from JSON
  factory Case.fromJson(Map<String, dynamic> json) {
    return Case(
      title: json['title'] as String,
      description: json['description'] as String,
      caseType: json['caseType'] as String,
    );
  }
}
