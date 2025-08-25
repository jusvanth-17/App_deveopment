class LessonContent {
  final String title;
  final String level;
  final String subtopic;
  final String duration;
  final String description;
  final List<String> learningObjectives;
  final List<String> learningResources;
  final List<String> practiceExercises;
  final List<String> assessmentMethods;
  final List<String> culturalContext;
  
  const LessonContent({
    required this.title,
    required this.level,
    required this.subtopic,
    required this.duration,
    required this.description,
    required this.learningObjectives,
    required this.learningResources,
    required this.practiceExercises,
    required this.assessmentMethods,
    required this.culturalContext,
  });

  // Get a specific part of the lesson content
  String getPart(LessonPart part) {
    switch (part) {
      case LessonPart.introduction:
        return "Today we'll be learning about $subtopic in $level $title. $description This will take approximately $duration.";
      case LessonPart.learningObjectives:
        return "Our learning objectives for this lesson are:\n" + 
               learningObjectives.map((obj) => "- $obj").join("\n");
      case LessonPart.learningResources:
        return "Here are some resources to help you learn:\n" + 
               learningResources.map((res) => "- $res").join("\n");
      case LessonPart.practiceExercises:
        return "Let's practice with these exercises:\n" + 
               practiceExercises.map((ex) => "- $ex").join("\n");
      case LessonPart.assessmentMethods:
        return "We'll assess your learning with:\n" + 
               assessmentMethods.map((method) => "- $method").join("\n");
      case LessonPart.culturalContext:
        return "Cultural context for this lesson:\n" + 
               culturalContext.map((context) => "- $context").join("\n");
      case LessonPart.summary:
        return "To summarize what we've learned about $subtopic:\n" +
               "We covered the basics of $description\n" +
               "We focused on ${learningObjectives.length} main objectives and practiced with ${practiceExercises.length} different exercises.\n" +
               "Remember to review the resources provided to reinforce your learning.";
    }
  }

  // Get all parts in sequence
  List<String> getAllParts() {
    return LessonPart.values.map((part) => getPart(part)).toList();
  }
}

enum LessonPart {
  introduction,
  learningObjectives,
  learningResources,
  practiceExercises,
  assessmentMethods,
  culturalContext,
  summary,
}
