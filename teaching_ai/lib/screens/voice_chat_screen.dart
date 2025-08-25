import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/lesson_service.dart';
import '../services/firebase_service.dart';
import '../models/lesson_content.dart';

class VoiceChatScreen extends StatefulWidget {
  final String language; // The language to teach (e.g., "Spanish", "French")
  final int initialLessonIndex; // The lesson index to start with
  final List<String>? savedMessages; // Previously saved messages

  const VoiceChatScreen({
    super.key, 
    required this.language, 
    this.initialLessonIndex = 0,
    this.savedMessages,
  });

  @override
  State<VoiceChatScreen> createState() => _VoiceChatScreenState();
}

class _VoiceChatScreenState extends State<VoiceChatScreen> {
  final _messages = <String>[];
  final _speech = stt.SpeechToText();
  final _player = AudioPlayer();

  bool _isListening = false;
  String _recognizedText = "";
  
  // Text controller for typed input
  final TextEditingController _textController = TextEditingController();
  
  // Track conversation state
  bool _isInitialGreeting = true;
  int _messageCount = 0;
  int _currentLessonIndex = 0;
  List<LessonContent> _languageLessons = [];
  bool _isRestoredSession = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize with saved state if available
    _isRestoredSession = widget.savedMessages != null && widget.savedMessages!.isNotEmpty;
    _currentLessonIndex = widget.initialLessonIndex;
    
    _loadLanguageLessons();
  }

  /// Load the language lessons from the service
  void _loadLanguageLessons() {
    // Get all lessons for the selected language
    _languageLessons = LessonService.getLessonsForLanguage(widget.language);
    
    // Restore saved messages if available
    if (_isRestoredSession && widget.savedMessages != null) {
      setState(() {
        _messages.addAll(widget.savedMessages!);
        _messageCount = widget.savedMessages!.length;
        _isInitialGreeting = false;
      });
    } 
    // Otherwise start a new conversation
    else if (_languageLessons.isNotEmpty) {
      _greetAndStartLanguageConversation();
    } else {
      // Fallback if no lessons found
      setState(() {
        _messages.add("🤖 Tutor: Sorry, no lessons are available for ${widget.language} right now. Please try again later.");
      });
    }
  }

  /// Step 1: Tutor greets user and starts language conversation using our lesson content
Future<void> _greetAndStartLanguageConversation() async {
  // Get the current lesson
  final currentLesson = _languageLessons[_currentLessonIndex];
  
  final greetingPrompt = """
You are a friendly language tutor conducting a 1:1 real-time conversation to teach ${widget.language}.
You will be teaching directly from a structured curriculum on ${currentLesson.subtopic}.

LESSON DETAILS:
Title: ${currentLesson.title}
Level: ${currentLesson.level}
Subtopic: ${currentLesson.subtopic}
Duration: ${currentLesson.duration}
Description: ${currentLesson.description}

LEARNING OBJECTIVES:
${currentLesson.learningObjectives.map((obj) => "- $obj").join("\n")}

RESOURCES TO MENTION:
${currentLesson.learningResources.map((res) => "- $res").join("\n")}

PRACTICE EXERCISES TO SUGGEST:
${currentLesson.practiceExercises.map((ex) => "- $ex").join("\n")}

CULTURAL CONTEXT TO INCORPORATE:
${currentLesson.culturalContext.map((ctx) => "- $ctx").join("\n")}

IMPORTANT GUIDELINES:
1. Start by warmly greeting the student and introducing yourself as their ${widget.language} tutor.
2. Explain that today's lesson will focus on ${currentLesson.subtopic}.
3. Keep your responses conversational, friendly and concise (1-3 sentences maximum).
4. Teach EXACTLY the content provided in this lesson plan, not general information.
5. Use the specific learning objectives as your teaching guide.
6. After teaching a word or phrase, encourage the student to practice it.
7. Incorporate cultural context to make the language learning more meaningful.

Begin the lesson by introducing the topic and the first learning objective.
  """;

  await _sendToAI(greetingPrompt, role: "system");
}

/// Handle user response based on conversation state and current lesson
Future<void> _handleUserResponse(String userText) async {
  _messageCount++;
  
  // Get the current lesson
  final currentLesson = _languageLessons[_currentLessonIndex];
  
  // For the first few exchanges, guide the conversation with more structure
  if (_messageCount < 3) {
    final nextPrompt = """
The student said: "$userText"

You are teaching ${widget.language} focused on ${currentLesson.subtopic}. 

Continue the conversation naturally while teaching from the lesson plan:
1. Acknowledge their response
2. Teach vocabulary or phrases related to these objectives: ${currentLesson.learningObjectives.join(", ")}
3. Provide clear pronunciation guidance and examples
4. Ask the student to practice using what you just taught
5. Incorporate cultural context: ${currentLesson.culturalContext.join(", ")}

Remember to stick to the specific content from this lesson plan.
  """;
    
    await _sendToAI(nextPrompt, role: "system");
  } else if (_messageCount % 5 == 0) {
    // Every 5 messages, check if we should progress to the next lesson
    if (_currentLessonIndex < _languageLessons.length - 1) {
      // Suggest moving to the next topic
      final nextPrompt = """
The student said: "$userText"

You've been teaching ${widget.language} about ${currentLesson.subtopic}.

Now it's time to transition to the next lesson:
1. Acknowledge their response and provide any corrections if needed
2. Summarize the key vocabulary and phrases they've learned in this lesson
3. Tell them you'll be moving on to a new topic in the next message
4. Ask if they're ready to continue to the next topic
  """;
      
      await _sendToAI(nextPrompt, role: "system");
      
      // Prepare to move to the next lesson next time
      _currentLessonIndex++;
    } else {
      // We've reached the end of all lessons
      await _sendToAI(userText, role: "user");
    }
  } else {
    // For regular conversation flow, still refer to the current lesson
    final regularPrompt = """
The student said: "$userText"

Continue teaching ${widget.language} about ${currentLesson.subtopic}. 

Focus on these learning objectives: ${currentLesson.learningObjectives.join(", ")}

Use these specific practice exercises: ${currentLesson.practiceExercises.join(", ")}

Incorporate these cultural contexts: ${currentLesson.culturalContext.join(", ")}

IMPORTANT:
1. Correct any mistakes in the student's language use gently
2. Provide positive reinforcement when they use the language correctly
3. Keep teaching the content from the structured lesson plan
4. Keep responses short and conversational
  """;
    
    await _sendToAI(regularPrompt, role: "system");
  }
}

  /// Step 2: Send user input or system prompt to OpenAI
  Future<void> _sendToAI(String text, {String role = "user"}) async {
    // Don't show system prompts to the user
    if (role == "user") {
      setState(() => _messages.add("🧑 You: $text"));
    }

    try {
      // Get the current lesson for context
      final currentLesson = _languageLessons[_currentLessonIndex];
      
      final response = await http.post(
        Uri.parse("https://api.openai.com/v1/chat/completions"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $openaiApiKey",
        },
        body: jsonEncode({
          "model": "gpt-4o-mini",
          "messages": [
            {
              "role": "system", 
              "content": """
You are an excellent ${widget.language} language tutor teaching from a structured curriculum.
Current lesson: ${currentLesson.subtopic} (${currentLesson.level} level)
Description: ${currentLesson.description}

Learning objectives for this lesson:
${currentLesson.learningObjectives.map((obj) => "- $obj").join("\n")}

Cultural context for this lesson:
${currentLesson.culturalContext.map((ctx) => "- $ctx").join("\n")}

Keep responses SHORT and CONVERSATIONAL - maximum 1-3 sentences.
Be encouraging, friendly, and helpful.
Introduce ${widget.language} vocabulary and phrases from the lesson content.
Correct student errors gently and provide correct forms.
Always teach the language in English, explaining pronunciations and meanings in English.
"""
            },
            {"role": role, "content": text}
          ],
          "temperature": 0.7
        }),
      );

      final aiText = jsonDecode(response.body)['choices'][0]['message']['content'];
      setState(() => _messages.add("🤖 Tutor: $aiText"));

      await _speakWithElevenLabs(aiText);

    } catch (e) {
      setState(() => _messages.add("❌ AI Error: $e"));
    }
  }

  /// Step 3: ElevenLabs TTS
  Future<void> _speakWithElevenLabs(String text) async {
    try {
      final response = await http.post(
        Uri.parse("https://api.elevenlabs.io/v1/text-to-speech/$elevenLabsVoiceId"),
        headers: {
          "Content-Type": "application/json",
          "xi-api-key": elevenLabsApiKey,
        },
        body: jsonEncode({
          "text": text,
          "voice_settings": {"stability": 0.7, "similarity_boost": 0.9}
        }),
      );

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final file = Uint8List.fromList(bytes);
        await _player.play(BytesSource(file));
      }
    } catch (e) {
      debugPrint("TTS Error: $e");
    }
  }

  /// Step 4: Start/Stop listening
  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      if (mounted) {
        setState(() => _isListening = false);
      }
    } else {
      final available = await _speech.initialize();
      if (available && mounted) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (result) {
          if (mounted) {
            setState(() => _recognizedText = result.recognizedWords);
          }
        });
      }
    }
  }

  /// Step 5: Send user speech to AI
  Future<void> _sendSpeechInput() async {
    if (_recognizedText.isNotEmpty) {
      final userText = _recognizedText;
      setState(() => _recognizedText = "");
      
      if (_isInitialGreeting) {
        await _sendToAI(userText);
        _isInitialGreeting = false;
      } else {
        await _handleUserResponse(userText);
      }
    }
  }
  
  /// Step 6: Send text input to AI
  Future<void> _sendTextInput() async {
    if (_textController.text.isNotEmpty) {
      final userText = _textController.text;
      _textController.clear();
      
      if (_isInitialGreeting) {
        await _sendToAI(userText);
        _isInitialGreeting = false;
      } else {
        await _handleUserResponse(userText);
      }
    }
  }

  // Save the current state when leaving the screen
  Future<void> _saveCurrentState() async {
    // Only save if we have messages
    if (_messages.isEmpty) return;
    
    try {
      await FirebaseService.saveUserAppState(
        selectedLanguage: widget.language,
        currentLessonIndex: _currentLessonIndex,
        messages: _messages,
      );
      debugPrint('✅ Saved conversation state: ${widget.language}, lesson: $_currentLessonIndex, messages: ${_messages.length}');
    } catch (e) {
      debugPrint('🔥 Error saving state: $e');
    }
  }

  @override
  void dispose() {
    // Save current state before disposing
    _saveCurrentState();
    
    // Make sure to cancel any ongoing speech recognition
    _speech.stop();
    _speech.cancel();
    // Dispose of controllers
    _textController.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("1:1 ${widget.language} Tutor"),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _buildMessageBubble(i),
            ),
          ),
          
          // User input area
          _buildInputArea(),
        ],
      ),
    );
  }
  
  // Build a chat message bubble
  Widget _buildMessageBubble(int index) {
    final message = _messages[index];
    final isUser = message.startsWith("🧑 You:");
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser 
              ? Theme.of(context).colorScheme.primary 
              : Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isUser ? "You" : "Tutor",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isUser 
                    ? Theme.of(context).colorScheme.onPrimary 
                    : Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              // Remove the prefix from the message
              message.replaceFirst(isUser ? "🧑 You: " : "🤖 Tutor: ", ""),
              style: TextStyle(
                color: isUser 
                    ? Theme.of(context).colorScheme.onPrimary 
                    : Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Build the user input area
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Recognized text display
          if (_recognizedText.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12.0),
              margin: const EdgeInsets.only(bottom: 8.0),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "🗣️ $_recognizedText", 
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                ),
              ),
            ),
          
          // Text input field
          if (_recognizedText.isEmpty)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendTextInput(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.send,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    onPressed: _sendTextInput,
                  ),
                ),
              ],
            ),
          
          const SizedBox(height: 8),
          
          // Voice and other controls
          Row(
            children: [
              // Voice input button
              Container(
                decoration: BoxDecoration(
                  color: _isListening 
                      ? Theme.of(context).colorScheme.primary 
                      : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: _isListening 
                        ? Theme.of(context).colorScheme.onPrimary 
                        : Colors.black87,
                  ),
                  onPressed: _toggleListening,
                ),
              ),
              
              if (_recognizedText.isNotEmpty) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendSpeechInput,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
              
              const Spacer(),
              
              // Tip button
              IconButton(
                icon: const Icon(Icons.lightbulb_outline),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Tips for Learning ${widget.language}"),
                      content: const Text(
                        "• Practice pronunciation by repeating phrases\n"
                        "• Ask for examples of vocabulary in sentences\n"
                        "• Request clarification when you don't understand\n"
                        "• Try to form complete sentences in your responses\n"
                        "• Ask about cultural context for deeper understanding"
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  );
                },
                color: Colors.amber[700],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
