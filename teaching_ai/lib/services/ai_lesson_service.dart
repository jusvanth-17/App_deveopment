import 'package:teaching_ai/models/lesson_content.dart';

class AILessonService {
  // AI teaching lessons
  static final List<LessonContent> _aiLessons = [
    // Beginner Level
    LessonContent(
      title: "Artificial Intelligence",
      level: "Beginner",
      subtopic: "Introduction to AI Concepts",
      duration: "4 hours",
      description: "Learn the fundamental concepts of AI, its history, and its applications in today's world.",
      learningObjectives: [
        "Understand the definition and scope of artificial intelligence",
        "Learn about the historical development of AI",
        "Identify different types of AI (narrow vs. general)"
      ],
      learningResources: [
        "Online course: 'AI For Everyone' by Andrew Ng",
        "Book: 'Artificial Intelligence: A Modern Approach' by Stuart Russell and Peter Norvig",
        "Article: 'A Brief History of Artificial Intelligence'"
      ],
      practiceExercises: [
        "Create a timeline of key AI developments",
        "Identify AI applications in your daily life",
        "Compare and contrast weak vs. strong AI"
      ],
      assessmentMethods: [
        "Quiz on AI fundamentals and history",
        "Short essay on the impact of AI on society",
        "Group discussion on current AI applications"
      ],
      culturalContext: [
        "Understanding AI representation in popular media vs. reality",
        "Exploring how different cultures perceive artificial intelligence",
        "Discussing the global impact of AI advancement"
      ],
    ),
    LessonContent(
      title: "Artificial Intelligence",
      level: "Beginner",
      subtopic: "Machine Learning Basics",
      duration: "5 hours",
      description: "Introduction to machine learning concepts, including supervised and unsupervised learning approaches.",
      learningObjectives: [
        "Understand the difference between AI and machine learning",
        "Learn about supervised, unsupervised, and reinforcement learning",
        "Identify real-world applications of different ML paradigms"
      ],
      learningResources: [
        "Online course: 'Introduction to Machine Learning' on Coursera",
        "Interactive tutorial: 'Machine Learning Playground'",
        "Video series: 'Machine Learning Explained Simply'"
      ],
      practiceExercises: [
        "Classify everyday decisions as supervised or unsupervised learning problems",
        "Identify the type of ML used in common applications like Netflix recommendations",
        "Sketch a simple decision tree for a basic classification problem"
      ],
      assessmentMethods: [
        "Multiple-choice quiz on ML terminology and concepts",
        "Create a flowchart showing the machine learning process",
        "Case study analysis of a real-world ML application"
      ],
      culturalContext: [
        "Discussing how ML algorithms can reflect and amplify cultural biases",
        "Exploring different national approaches to ML development and regulation",
        "Understanding the ethical implications of automated decision making"
      ],
    ),
    LessonContent(
      title: "Artificial Intelligence",
      level: "Beginner",
      subtopic: "Neural Networks Fundamentals",
      duration: "6 hours",
      description: "Understanding the basic structure and function of neural networks in artificial intelligence.",
      learningObjectives: [
        "Understand the biological inspiration for neural networks",
        "Learn about neurons, weights, activation functions, and layers",
        "Comprehend the concept of backpropagation at a high level"
      ],
      learningResources: [
        "Interactive visualization: '3D Neural Network'",
        "Tutorial: 'Neural Networks Demystified'",
        "Article: 'Understanding Neural Networks Through Visualization'"
      ],
      practiceExercises: [
        "Draw and label the components of an artificial neuron",
        "Use an online simulator to observe how changing weights affects output",
        "Trace the information flow in a simple feed-forward network"
      ],
      assessmentMethods: [
        "Diagram-based quiz on neural network architecture",
        "Concept explanation in your own words",
        "Interactive simulation exercise with different network parameters"
      ],
      culturalContext: [
        "Discussing how the brain-inspired approach varies across different research traditions",
        "Exploring the philosophical implications of mimicking human cognition",
        "Understanding historical context of neural network development across different countries"
      ],
    ),

    // Intermediate Level
    LessonContent(
      title: "Artificial Intelligence",
      level: "Intermediate",
      subtopic: "Deep Learning Architectures",
      duration: "6 hours",
      description: "Exploring different deep learning architectures and their applications.",
      learningObjectives: [
        "Understand the differences between CNN, RNN, and Transformer architectures",
        "Learn about feature extraction in deep learning models",
        "Identify appropriate architectures for different AI tasks"
      ],
      learningResources: [
        "Online course: 'Deep Learning Specialization'",
        "Research paper summaries on key architectures",
        "Interactive demos of different network types"
      ],
      practiceExercises: [
        "Analyze the architecture of a pre-trained model",
        "Match architecture types to appropriate use cases",
        "Diagram information flow in different network types"
      ],
      assessmentMethods: [
        "Technical quiz on architecture components and functions",
        "Case study analysis of architecture selection",
        "Compare and contrast essay on different architectures"
      ],
      culturalContext: [
        "Understanding how different research labs contributed to architecture development",
        "Exploring how computational resources influence architectural choices globally",
        "Discussing the environmental impact of training large models"
      ],
    ),
    LessonContent(
      title: "Artificial Intelligence",
      level: "Intermediate",
      subtopic: "Natural Language Processing",
      duration: "5 hours",
      description: "Introduction to NLP concepts and applications, including text processing and language understanding.",
      learningObjectives: [
        "Understand the core challenges of language processing",
        "Learn about tokenization, embeddings, and language models",
        "Explore applications such as sentiment analysis and machine translation"
      ],
      learningResources: [
        "Tutorial: 'Introduction to NLP with Python'",
        "Interactive demo: 'Visualizing Word Embeddings'",
        "Article series: 'NLP From Scratch'"
      ],
      practiceExercises: [
        "Perform basic text preprocessing on a sample document",
        "Analyze sentiment in different text samples",
        "Compare machine translations across different platforms"
      ],
      assessmentMethods: [
        "Practical NLP task implementation",
        "Analysis of a language model's strengths and limitations",
        "Project: building a simple text classifier"
      ],
      culturalContext: [
        "Discussing language diversity and NLP capabilities across different languages",
        "Understanding cultural nuances that challenge machine translation",
        "Exploring the impact of NLP on global communication"
      ],
    ),
    LessonContent(
      title: "Artificial Intelligence",
      level: "Intermediate",
      subtopic: "Computer Vision Fundamentals",
      duration: "5 hours",
      description: "Exploring computer vision concepts and techniques for image recognition and processing.",
      learningObjectives: [
        "Understand how computers process and interpret visual information",
        "Learn about image classification, object detection, and segmentation",
        "Explore the evolution of computer vision techniques"
      ],
      learningResources: [
        "Tutorial series: 'Computer Vision Basics'",
        "Interactive demos of image recognition systems",
        "Case studies of computer vision applications"
      ],
      practiceExercises: [
        "Analyze how filters affect image processing",
        "Use an online platform to test image classification",
        "Compare human vs. computer perception of optical illusions"
      ],
      assessmentMethods: [
        "Technical quiz on computer vision concepts",
        "Analysis of a vision system's performance",
        "Project: proposing a computer vision solution to a real problem"
      ],
      culturalContext: [
        "Discussing visual perception differences across cultures",
        "Understanding ethical concerns in facial recognition technology",
        "Exploring accessibility applications of computer vision"
      ],
    ),

    // Advanced Level
    LessonContent(
      title: "Artificial Intelligence",
      level: "Advanced",
      subtopic: "Reinforcement Learning",
      duration: "7 hours",
      description: "Advanced exploration of reinforcement learning methods and applications.",
      learningObjectives: [
        "Understand the reinforcement learning framework",
        "Learn about Q-learning, policy gradients, and deep RL",
        "Explore applications in gaming, robotics, and optimization"
      ],
      learningResources: [
        "Book: 'Reinforcement Learning: An Introduction' by Sutton and Barto",
        "Research paper collection on recent RL advances",
        "Case studies of RL in industrial applications"
      ],
      practiceExercises: [
        "Design a reward function for a simple RL problem",
        "Analyze the exploration-exploitation tradeoff in different scenarios",
        "Compare RL approaches for different types of environments"
      ],
      assessmentMethods: [
        "Technical implementation of a basic RL algorithm",
        "Analysis of a complex RL system",
        "Research proposal for an RL application"
      ],
      culturalContext: [
        "Discussing ethical implications of autonomous learning systems",
        "Understanding cultural perspectives on machine autonomy",
        "Exploring international governance approaches to AI systems"
      ],
    ),
    LessonContent(
      title: "Artificial Intelligence",
      level: "Advanced",
      subtopic: "AI Ethics and Governance",
      duration: "5 hours",
      description: "Critical examination of ethical considerations in AI development and deployment.",
      learningObjectives: [
        "Understand key ethical challenges in AI including bias, privacy, and transparency",
        "Learn about governance frameworks and regulatory approaches",
        "Develop strategies for responsible AI development"
      ],
      learningResources: [
        "Book: 'Ethics of Artificial Intelligence'",
        "Case studies of ethical failures and successes",
        "Policy papers from different global organizations"
      ],
      practiceExercises: [
        "Ethical analysis of a controversial AI application",
        "Develop a responsible AI checklist for development teams",
        "Compare regulatory approaches across different regions"
      ],
      assessmentMethods: [
        "Position paper on an AI ethics topic",
        "Group debate on ethical dilemmas",
        "Design an ethics-focused improvement to an existing AI system"
      ],
      culturalContext: [
        "Comparing ethical frameworks across different philosophical traditions",
        "Understanding how cultural values shape AI governance approaches",
        "Exploring power dynamics in global AI development"
      ],
    ),
    LessonContent(
      title: "Artificial Intelligence",
      level: "Advanced",
      subtopic: "Generative AI and Creative Applications",
      duration: "6 hours",
      description: "Exploring generative models and their applications in creating content and solving creative problems.",
      learningObjectives: [
        "Understand the architecture and function of generative models",
        "Learn about GANs, VAEs, and diffusion models",
        "Explore applications in art, design, music, and content creation"
      ],
      learningResources: [
        "Research paper summaries on generative model architectures",
        "Gallery of AI-generated art and explanations",
        "Technical demonstrations of text-to-image systems"
      ],
      practiceExercises: [
        "Analyze outputs from different generative systems",
        "Design prompts to test creative AI capabilities",
        "Compare human and AI creative processes"
      ],
      assessmentMethods: [
        "Technical analysis of a generative model",
        "Creative project using AI tools",
        "Critical essay on the future of AI in creative fields"
      ],
      culturalContext: [
        "Discussing concepts of authorship and creativity across different cultures",
        "Understanding the impact of AI generation on creative industries",
        "Exploring how generative AI reflects and challenges cultural norms"
      ],
    ),
  ];

  // Get all AI lessons
  static List<LessonContent> getAllLessons() {
    return _aiLessons;
  }

  // Get lessons by level
  static List<LessonContent> getLessonsByLevel(String level) {
    return _aiLessons.where((lesson) => lesson.level == level).toList();
  }

  // Get a lesson by index
  static LessonContent getLessonByIndex(int index) {
    if (index >= 0 && index < _aiLessons.length) {
      return _aiLessons[index];
    }
    
    // Return a default lesson if index is out of bounds
    return LessonContent(
      title: "Artificial Intelligence",
      level: "Beginner",
      subtopic: "Introduction to AI",
      duration: "1 hour",
      description: "Basic introduction to AI concepts for beginners.",
      learningObjectives: [
        "Understand what AI is", 
        "Learn about basic AI applications"
      ],
      learningResources: [
        "Online AI learning platforms", 
        "Basic AI introduction videos"
      ],
      practiceExercises: [
        "Identify AI in your daily life", 
        "Discuss potential future AI applications"
      ],
      assessmentMethods: [
        "Quiz on basic AI concepts", 
        "Short reflection on AI's impact"
      ],
      culturalContext: [
        "Understanding different perspectives on AI across cultures", 
        "Exploring ethical considerations in AI development"
      ],
    );
  }
}
