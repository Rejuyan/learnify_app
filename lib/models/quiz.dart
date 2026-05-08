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
}
