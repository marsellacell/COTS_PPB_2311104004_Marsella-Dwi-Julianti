class TaskModel {
  final int? id;
  final String title;
  final String course;
  final String deadline;
  final String status;
  final String? note;
  final bool isDone;
  final String? createdAt;
  final String? updatedAt;

  TaskModel({
    this.id,
    required this.title,
    required this.course,
    required this.deadline,
    required this.status,
    this.note,
    this.isDone = false,
    this.createdAt,
    this.updatedAt,
  });

  // From JSON
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'] ?? '',
      course: json['course'] ?? '',
      deadline: json['deadline'] ?? '',
      status: json['status'] ?? 'BERJALAN',
      note: json['note'],
      isDone: json['is_done'] ?? false,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'course': course,
      'deadline': deadline,
      'status': status,
      'note': note,
      'is_done': isDone,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    };
  }

  // Copy with method untuk update
  TaskModel copyWith({
    int? id,
    String? title,
    String? course,
    String? deadline,
    String? status,
    String? note,
    bool? isDone,
    String? createdAt,
    String? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      course: course ?? this.course,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      note: note ?? this.note,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
