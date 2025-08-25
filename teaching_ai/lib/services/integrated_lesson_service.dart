import 'package:teaching_ai/models/lesson_content.dart';
import 'package:teaching_ai/services/ai_lesson_service.dart';

/// A service that provides lessons focused on AI teaching
class IntegratedLessonService {
  // Map that holds only AI lessons
  static final Map<String, List<LessonContent>> _allLessons = {
    "AI": AILessonService.getAllLessons(),
  };

  // Get lessons for a specific subject (only "AI" is supported)
  static List<LessonContent> getLessonsForSubject(String subject) {
    // Return lessons for the specified subject, or empty list if not found
    return _allLessons[subject] ?? [];
  }

  // Get lessons by level for a specific subject
  static List<LessonContent> getLessonsByLevel(String subject, String level) {
    final lessons = getLessonsForSubject(subject);
    return lessons.where((lesson) => lesson.level == level).toList();
  }

  // Get a lesson by index
  static LessonContent getLessonByIndex(String subject, int index) {
    final lessons = getLessonsForSubject(subject);
    if (index >= 0 && index < lessons.length) {
      return lessons[index];
    }
    
    // If subject is "AI", use the AILessonService default lesson
    if (subject == "AI") {
      return AILessonService.getLessonByIndex(0);
    }
    
    // Return a default lesson if subject not found or index is out of bounds
    return LessonContent(
      title: "$subject",
      level: "Beginner",
      subtopic: "Introduction to $subject",
      duration: "1 hour",
      description: "Basic introduction to $subject for beginners.",
      learningObjectives: [
        "Learn basic concepts in $subject", 
        "Understand fundamental principles"
      ],
      learningResources: [
        "Online learning platforms", 
        "Basic introduction materials"
      ],
      practiceExercises: [
        "Identify concepts in real-world scenarios", 
        "Practice basic applications"
      ],
      assessmentMethods: [
        "Quiz on basic concepts", 
        "Short reflection on impact"
      ],
      culturalContext: [
        "Understanding different perspectives across cultures", 
        "Exploring ethical considerations in the field"
      ],
    );
  }

  // Get available subjects (currently only "AI")
  static List<String> getAvailableSubjects() {
    return _allLessons.keys.toList();
  }

  // Get available levels for a subject
  static List<String> getAvailableLevels(String subject) {
    final lessons = getLessonsForSubject(subject);
    final Set<String> levels = {};
    
    for (var lesson in lessons) {
      levels.add(lesson.level);
    }
    
    return levels.toList();
  }
}
