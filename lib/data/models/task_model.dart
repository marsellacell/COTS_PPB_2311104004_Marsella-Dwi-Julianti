class Task {
  final int id;
  final String title;
  final String course;
  final String deadline;
  final String status;
  final String note;
  final bool isDone;

  Task({
    required this.id,
    required this.title,
    required this.course,
    required this.deadline,
    required this.status,
    required this.note,
    required this.isDone,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      course: json['course'],
      deadline: json['deadline'],
      status: json['status'],
      note: json['note'] ?? '',
      isDone: json['is_done'] ?? false,
    );
  }

  Map<String, dynamic> toJsonForPost() {
    return {
      'title': title,
      'course': course,
      'deadline': deadline,
      'status': status,
      'note': note,
      'is_done': isDone,
    };
  }
}
