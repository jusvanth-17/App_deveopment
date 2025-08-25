import 'package:teaching_ai/models/lesson_content.dart';

class LessonService {
  // Sample lessons for demonstration
  static final Map<String, List<LessonContent>> _allLessons = {
    "Spanish": [
      LessonContent(
        title: "Spanish Language",
        level: "Beginner",
        subtopic: "Greetings and Introductions",
        duration: "4 hours",
        description: "Learn basic greetings, farewells, and how to introduce oneself and others.",
        learningObjectives: [
          "Recognize and use common greetings and farewells",
          "Introduce oneself and provide basic personal information"
        ],
        learningResources: [
          "Textbook: 'Spanish for Beginners'",
          "Online resource: Duolingo - Basics Section"
        ],
        practiceExercises: [
          "Role-playing greetings with a partner",
          "Flashcard creation for vocabulary"
        ],
        assessmentMethods: [
          "Short oral presentation introducing oneself",
          "Written quiz on vocabulary"
        ],
        culturalContext: [
          "Understanding cultural norms around greetings in Spanish-speaking countries",
          "Practicing greetings in real-life situations like meeting new people"
        ],
      ),
      LessonContent(
        title: "Spanish Language",
        level: "Beginner",
        subtopic: "Numbers and Basic Math",
        duration: "3 hours",
        description: "Understanding and using numbers in everyday contexts.",
        learningObjectives: [
          "Identify and pronounce numbers 1-100",
          "Perform basic arithmetic operations using Spanish terms"
        ],
        learningResources: [
          "Online resource: SpanishDict - Numbers",
          "Workbook: 'Practice Makes Perfect: Spanish Vocabulary'"
        ],
        practiceExercises: [
          "Number bingo game",
          "Simple math problems in Spanish"
        ],
        assessmentMethods: [
          "Oral quiz on number pronunciation",
          "Written exercises on arithmetic"
        ],
        culturalContext: [
          "Using numbers in shopping and budgeting scenarios",
          "Discussing age and dates in conversations"
        ],
      ),
    ],
    "French": [
      LessonContent(
        title: "French Language",
        level: "Beginner",
        subtopic: "Greetings and Introductions",
        duration: "4 hours",
        description: "Learn basic greetings, farewells, and how to introduce oneself and others in French.",
        learningObjectives: [
          "Master common French greetings for different times of day",
          "Introduce yourself and ask basic questions about others"
        ],
        learningResources: [
          "Textbook: 'French for Beginners'",
          "Online resource: TV5Monde - French Learning"
        ],
        practiceExercises: [
          "Conversation practice with greeting scenarios",
          "Recording yourself introducing yourself in French"
        ],
        assessmentMethods: [
          "Role-play greetings with proper pronunciation",
          "Written quiz on formal vs. informal expressions"
        ],
        culturalContext: [
          "Understanding the importance of formal/informal distinctions in French culture",
          "Learning about cheek-kissing customs in France and other French-speaking regions"
        ],
      ),
      LessonContent(
        title: "French Language",
        level: "Beginner",
        subtopic: "Ordering Food and Drinks",
        duration: "3 hours",
        description: "Learn vocabulary and phrases for ordering in cafés and restaurants.",
        learningObjectives: [
          "Master essential food and drink vocabulary",
          "Learn phrases for ordering, asking for the bill, and making special requests"
        ],
        learningResources: [
          "Online resource: Coffee Break French - Restaurant Episode",
          "Flashcard app: 'French Food Vocabulary'"
        ],
        practiceExercises: [
          "Role-play restaurant scenarios",
          "Menu translation exercise"
        ],
        assessmentMethods: [
          "Simulate ordering a three-course meal in French",
          "Vocabulary test on food and restaurant terms"
        ],
        culturalContext: [
          "Understanding French dining etiquette and customs",
          "Learning about typical meal times and courses in France"
        ],
      ),
    ],
    "German": [
      LessonContent(
        title: "German Language",
        level: "Beginner",
        subtopic: "Introducing Yourself",
        duration: "4 hours",
        description: "Master basic German introductions and personal information.",
        learningObjectives: [
          "Introduce yourself and understand others' introductions",
          "Ask and answer questions about name, origin, occupation, and interests"
        ],
        learningResources: [
          "Textbook: 'German Made Simple'",
          "Online resource: Deutsche Welle - Learn German"
        ],
        practiceExercises: [
          "Partner introductions with Q&A",
          "Creating a personal introduction video"
        ],
        assessmentMethods: [
          "Oral introduction to the class",
          "Written exercise filling out a German form with personal details"
        ],
        culturalContext: [
          "Understanding formal vs. informal address in German culture",
          "Learning about common German names and their pronunciations"
        ],
      ),
      LessonContent(
        title: "German Language",
        level: "Beginner",
        subtopic: "Getting Around",
        duration: "5 hours",
        description: "Learn to navigate public transportation and ask for directions in German.",
        learningObjectives: [
          "Master vocabulary for transportation methods and locations",
          "Learn to ask for and understand directions"
        ],
        learningResources: [
          "App: 'German Transport Vocabulary'",
          "Video series: 'Navigating German Cities'"
        ],
        practiceExercises: [
          "Map exercises finding routes and describing them",
          "Role-play asking for directions in different scenarios"
        ],
        assessmentMethods: [
          "Describe a route from one landmark to another",
          "Comprehension test based on announcements at train stations"
        ],
        culturalContext: [
          "Understanding the German public transportation system",
          "Learning about punctuality expectations in German culture"
        ],
      ),
    ],
    "Japanese": [
      // Beginner Level
      LessonContent(
        title: "Japanese Language",
        level: "Beginner",
        subtopic: "Basic Greetings and Introductions",
        duration: "10 hours",
        description: "Learn essential Japanese greetings and self-introduction phrases.",
        learningObjectives: [
          "Master basic greetings for different times and situations",
          "Introduce yourself using proper Japanese etiquette",
          "Ask and respond to basic personal questions"
        ],
        learningResources: [
          "Textbook: 'Genki I: An Integrated Course in Elementary Japanese'",
          "App: 'Japanese Phrases for Beginners'",
          "Audio: 'Japanese Greetings Pronunciation Guide'"
        ],
        practiceExercises: [
          "Role-play different greeting scenarios",
          "Practice proper bowing techniques with greetings",
          "Self-introduction recording and review"
        ],
        assessmentMethods: [
          "Self-introduction speech in Japanese",
          "Situational response quiz for different social contexts",
          "Peer evaluation of pronunciation accuracy"
        ],
        culturalContext: [
          "Understanding the importance of hierarchy in Japanese greetings",
          "Learning about business card exchange etiquette in Japan",
          "The significance of different bow depths in various situations"
        ],
      ),
      LessonContent(
        title: "Japanese Language",
        level: "Beginner",
        subtopic: "Numbers and Counting",
        duration: "5 hours",
        description: "Learn Japanese number system and counting techniques for various situations.",
        learningObjectives: [
          "Master numbers 1-100 in Japanese",
          "Learn different counting systems for various objects",
          "Use numbers in daily conversations (time, price, age)"
        ],
        learningResources: [
          "Counting practice sheets",
          "App: 'Japanese Numbers Trainer'",
          "Video series: 'Counting in Japanese'"
        ],
        practiceExercises: [
          "Number recognition drills",
          "Shopping role-play with price negotiations",
          "Time-telling practice"
        ],
        assessmentMethods: [
          "Oral counting test",
          "Written quiz on numerical expressions",
          "Practical application: creating a shopping list with quantities"
        ],
        culturalContext: [
          "Understanding Japanese currency and shopping etiquette",
          "Lucky and unlucky numbers in Japanese culture",
          "Age-specific cultural expectations in Japan"
        ],
      ),
      LessonContent(
        title: "Japanese Language",
        level: "Beginner",
        subtopic: "Hiragana Writing System",
        duration: "6 hours",
        description: "Master the basics of the Hiragana writing system.",
        learningObjectives: [
          "Recognize and write all Hiragana characters",
          "Read simple words and sentences written in Hiragana",
          "Understand the stroke order rules"
        ],
        learningResources: [
          "Workbook: 'Hiragana Practice Sheets'",
          "App: 'Hiragana Memory Hint'",
          "Video: 'Hiragana Stroke Order Guide'"
        ],
        practiceExercises: [
          "Character writing practice",
          "Hiragana recognition games",
          "Reading simple texts in Hiragana"
        ],
        assessmentMethods: [
          "Character writing test",
          "Reading comprehension of simple Hiragana texts",
          "Dictation exercises"
        ],
        culturalContext: [
          "Understanding the historical development of Japanese writing systems",
          "Learning about calligraphy and its importance in Japanese culture",
          "The aesthetic principles of Japanese character writing"
        ],
      ),
      LessonContent(
        title: "Japanese Language",
        level: "Beginner",
        subtopic: "Everyday Phrases",
        duration: "8 hours",
        description: "Learn common expressions for shopping, ordering food, and asking directions.",
        learningObjectives: [
          "Master essential phrases for restaurant interactions",
          "Learn vocabulary for shopping and asking about prices",
          "Understand and use directional language for navigation"
        ],
        learningResources: [
          "Phrasebook: 'Survival Japanese'",
          "App: 'Japanese Travel Phrases'",
          "Audio guide: 'Restaurant Japanese'"
        ],
        practiceExercises: [
          "Restaurant ordering role-play",
          "Shopping dialogue construction",
          "Map navigation exercises"
        ],
        assessmentMethods: [
          "Situational role-play evaluation",
          "Phrase matching quiz",
          "Practical task: ordering a meal in Japanese"
        ],
        culturalContext: [
          "Japanese dining etiquette and customs",
          "Understanding polite shopping interactions",
          "Public transportation norms in Japan"
        ],
      ),
      
      // Intermediate Level
      LessonContent(
        title: "Japanese Language",
        level: "Intermediate",
        subtopic: "Grammatical Structures",
        duration: "15 hours",
        description: "Understanding sentence construction and verb tenses in Japanese.",
        learningObjectives: [
          "Master basic verb conjugation patterns",
          "Understand particle usage in constructing sentences",
          "Learn to express past, present, and future actions"
        ],
        learningResources: [
          "Textbook: 'Intermediate Japanese Grammar'",
          "Online course: 'Japanese Sentence Structure'",
          "Practice worksheet collection"
        ],
        practiceExercises: [
          "Sentence construction exercises",
          "Verb conjugation drills",
          "Translation practice from English to Japanese"
        ],
        assessmentMethods: [
          "Written grammar test",
          "Sentence correction exercise",
          "Paragraph composition using target structures"
        ],
        culturalContext: [
          "Understanding levels of formality in Japanese speech",
          "Cultural context of humble and honorific language",
          "Regional variations in grammatical usage"
        ],
      ),
      LessonContent(
        title: "Japanese Language",
        level: "Intermediate",
        subtopic: "Conversation Practice",
        duration: "12 hours",
        description: "Role-playing scenarios to improve fluency and confidence in Japanese conversations.",
        learningObjectives: [
          "Develop conversational flow in various scenarios",
          "Learn contextual vocabulary for specific situations",
          "Master common conversational fillers and responses"
        ],
        learningResources: [
          "Dialogue scripts for different situations",
          "Video series: 'Real Japanese Conversations'",
          "Conversation partner exchange program"
        ],
        practiceExercises: [
          "Guided role-play sessions",
          "Impromptu speaking drills",
          "Recorded conversation analysis"
        ],
        assessmentMethods: [
          "Conversational fluency evaluation",
          "Peer feedback sessions",
          "Real-world task completion"
        ],
        culturalContext: [
          "Non-verbal communication in Japanese conversation",
          "Understanding conversational nuances and context",
          "Age and status-appropriate speech styles"
        ],
      ),
      LessonContent(
        title: "Japanese Language",
        level: "Intermediate",
        subtopic: "Katakana and Basic Kanji",
        duration: "10 hours",
        description: "Master Katakana writing system and learn essential Kanji characters.",
        learningObjectives: [
          "Read and write all Katakana characters",
          "Learn 100 basic Kanji characters and their meanings",
          "Understand compound Kanji formations"
        ],
        learningResources: [
          "Textbook: 'Basic Kanji Book, Vol. 1'",
          "App: 'Katakana and Kanji Trainer'",
          "Flash cards for core Kanji"
        ],
        practiceExercises: [
          "Katakana writing practice",
          "Kanji recognition exercises",
          "Reading practice with mixed scripts"
        ],
        assessmentMethods: [
          "Character writing evaluation",
          "Reading comprehension test",
          "Kanji-to-meaning matching quiz"
        ],
        culturalContext: [
          "The cultural significance of Kanji in Japanese society",
          "Understanding the evolution of Japanese writing systems",
          "The use of Katakana for foreign words and concepts"
        ],
      ),
      
      // Advanced Level
      LessonContent(
        title: "Japanese Language",
        level: "Advanced",
        subtopic: "Cultural Context",
        duration: "10 hours",
        description: "Understanding cultural nuances in Japanese communication.",
        learningObjectives: [
          "Recognize and use culturally appropriate expressions",
          "Understand implicit communication in Japanese context",
          "Learn situation-specific language for business and social settings"
        ],
        learningResources: [
          "Book: 'The Cultural Subtext of Japanese Communication'",
          "Video series: 'Cultural Insights for Japanese Learners'",
          "Case studies of cross-cultural communication"
        ],
        practiceExercises: [
          "Cultural scenario analysis",
          "Appropriate response drills",
          "Business etiquette role-play"
        ],
        assessmentMethods: [
          "Cultural appropriateness evaluation",
          "Situation-based response test",
          "Self-reflection on cultural awareness"
        ],
        culturalContext: [
          "The concept of 'honne' and 'tatemae' in Japanese communication",
          "Group harmony and consensus-building in Japanese society",
          "Regional cultural variations within Japan"
        ],
      ),
      LessonContent(
        title: "Japanese Language",
        level: "Advanced",
        subtopic: "Advanced Grammar",
        duration: "15 hours",
        description: "Complex sentence structures and idiomatic expressions in Japanese.",
        learningObjectives: [
          "Master complex grammatical structures",
          "Understand and use common idiomatic expressions",
          "Develop nuanced expression of thoughts and opinions"
        ],
        learningResources: [
          "Textbook: 'Advanced Japanese: Communication in Context'",
          "Collection of literary passages with analysis",
          "Grammar reference guide for JLPT N2 and N1 levels"
        ],
        practiceExercises: [
          "Advanced sentence construction",
          "Idiom usage practice",
          "Essay writing using complex structures"
        ],
        assessmentMethods: [
          "Grammatical analysis test",
          "Translation of complex passages",
          "Original composition evaluation"
        ],
        culturalContext: [
          "The influence of classical Japanese on modern expressions",
          "Regional dialectical variations in grammar",
          "Literary and formal Japanese in different contexts"
        ],
      ),
      LessonContent(
        title: "Japanese Language",
        level: "Advanced",
        subtopic: "Media and Literature",
        duration: "12 hours",
        description: "Engaging with authentic Japanese media and literary works.",
        learningObjectives: [
          "Comprehend news articles and broadcasts",
          "Analyze excerpts from Japanese literature",
          "Understand colloquial language in entertainment media"
        ],
        learningResources: [
          "Selected news articles from Japanese sources",
          "Short stories by contemporary Japanese authors",
          "Excerpts from popular Japanese shows with analysis"
        ],
        practiceExercises: [
          "News summary and discussion",
          "Literary passage analysis",
          "Media content interpretation"
        ],
        assessmentMethods: [
          "Comprehension questions on authentic materials",
          "Discussion participation and insights",
          "Critical analysis of a chosen media piece"
        ],
        culturalContext: [
          "Current events and social issues in Japan",
          "Literary themes in Japanese culture",
          "The evolution of language in Japanese media"
        ],
      ),
    ],
  };

  // Get lessons for a specific language
  static List<LessonContent> getLessonsForLanguage(String language) {
    // Return lessons for the specified language, or empty list if not found
    return _allLessons[language] ?? [];
  }

  // Get a lesson by index
  static LessonContent getLessonByIndex(String language, int index) {
    final lessons = getLessonsForLanguage(language);
    if (index >= 0 && index < lessons.length) {
      return lessons[index];
    }
    
    // Return a default lesson if language not found or index is out of bounds
    return LessonContent(
      title: "$language Language",
      level: "Beginner",
      subtopic: "Introduction to $language",
      duration: "1 hour",
      description: "Basic introduction to $language for beginners.",
      learningObjectives: [
        "Learn basic greetings in $language", 
        "Introduce yourself in $language"
      ],
      learningResources: [
        "Online language learning platforms", 
        "Basic $language phrase book"
      ],
      practiceExercises: [
        "Practice greeting dialogues", 
        "Record yourself introducing yourself"
      ],
      assessmentMethods: [
        "Pronunciation check of basic phrases", 
        "Simple conversation practice"
      ],
      culturalContext: [
        "Understanding cultural context of greetings in $language-speaking regions", 
        "Learning about cultural etiquette for introductions"
      ],
    );
  }
}
