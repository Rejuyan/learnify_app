class Quiz {
  final String id;
  final String courseId;
  final String question;
  final List<String> options;
  final int correctIndex;

  const Quiz({
    required this.id,
    required this.courseId,
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseId': courseId,
      'question': question,
      'options': options,
      'correctIndex': correctIndex,
    };
  }

  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(
      id: map['id'] as String? ?? '',
      courseId: map['courseId'] as String? ?? '',
      question: map['question'] as String? ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctIndex: map['correctIndex'] as int? ?? 0,
    );
  }
}
