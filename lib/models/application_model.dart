/*
Student numbers
223039784 Nido Maphosa
223035639 PM Lesekele
219007064 T Dasheka
221001040 K.Loape
224020157 KP Molelekeng
 
         Assistant application record (Unit 2 - MVVM Model layer).
 */

/// ApplicationModel - represents a single Student Assistant application.
///
/// Following Unit 2 rules for Models:
/// no Flutter imports
/// All properties final (immutable)
/// copyWith() method for safe updates
/// fromJson / toJson for Supabase serialisation (Unit 5)
class ApplicationModel {
  final String id;
  final String userId;
  final String fullName;
  final String studentNumber;
  final String email;
  final String yearOfStudy;            // "1st Year" | "2nd Year" | "3rd Year"

  // First module application (required)
  final String module1Level;           // e.g. "Year 1"
  final String module1Code;            // e.g. "TPG316C"

  // Second module application (optional)
  final String? module2Level;
  final String? module2Code;

  final bool meetsRequirements;        // eligibility confirmation
  final String? documentUrl;           // supporting document (Supabase Storage)
  final String status;                 // "pending" | "approved" | "rejected"
  final DateTime createdAt;

  ApplicationModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.studentNumber,
    required this.email,
    required this.yearOfStudy,
    required this.module1Level,
    required this.module1Code,
    this.module2Level,
    this.module2Code,
    required this.meetsRequirements,
    this.documentUrl,
    required this.status,
    required this.createdAt,
  });

  /// Returns a new ApplicationModel with overridden fields.
  /// Keeps the model immutable (Unit 2 pattern).
  ApplicationModel copyWith({
    String? fullName,
    String? studentNumber,
    String? email,
    String? yearOfStudy,
    String? module1Level,
    String? module1Code,
    String? module2Level,
    String? module2Code,
    bool? meetsRequirements,
    String? documentUrl,
    String? status,
  }) {
    return ApplicationModel(
      id: id,
      userId: userId,
      fullName: fullName ?? this.fullName,
      studentNumber: studentNumber ?? this.studentNumber,
      email: email ?? this.email,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
      module1Level: module1Level ?? this.module1Level,
      module1Code: module1Code ?? this.module1Code,
      module2Level: module2Level ?? this.module2Level,
      module2Code: module2Code ?? this.module2Code,
      meetsRequirements: meetsRequirements ?? this.meetsRequirements,
      documentUrl: documentUrl ?? this.documentUrl,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }

  /// Build an ApplicationModel from a Supabase JSON row (Unit 5).
  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      fullName: json['full_name'] ?? '',
      studentNumber: json['student_number'] ?? '',
      email: json['email'] ?? '',
      yearOfStudy: json['year_of_study'] ?? '',
      module1Level: json['module1_level'] ?? '',
      module1Code: json['module1_code'] ?? '',
      module2Level: json['module2_level'],
      module2Code: json['module2_code'],
      meetsRequirements: json['meets_requirements'] ?? false,
      documentUrl: json['document_url'],
      status: json['status'] ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  /// Convert this model to a Supabase-ready map (Unit 5).
  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'student_number': studentNumber,
      'email': email,
      'year_of_study': yearOfStudy,
      'module1_level': module1Level,
      'module1_code': module1Code,
      'module2_level': module2Level,
      'module2_code': module2Code,
      'meets_requirements': meetsRequirements,
      'document_url': documentUrl,
      'status': status,
    };
  }
}
