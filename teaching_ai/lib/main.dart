// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'dart:io';
// import 'screens/language_selector_screen.dart';
// import 'services/firebase_service.dart';
// import 'firebase_options.dart';

// // Flag to control automatic backend launch
// // Set to true to automatically launch backend when frontend starts
// const bool AUTO_LAUNCH_BACKEND = true;

// /// Launch the backend server if it's not already running
// Future<void> launchBackend() async {
//   try {
//     if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
//       print('Starting backend server...');
//       // Get the app's root directory
//       final String pythonExecutable = Platform.isWindows ? 'python' : 'python3';
//       final result = await Process.run(
//         pythonExecutable,
//         ['launch_backend.py'],
//         workingDirectory: Directory.current.path,
//       );
      
//       if (result.exitCode != 0) {
//         print('Error starting backend: ${result.stderr}');
//       } else {
//         print('Backend initialized: ${result.stdout}');
//       }
//     }
//   } catch (e) {
//     print('Failed to start backend: $e');
//   }
// }

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Start the backend server only if AUTO_LAUNCH_BACKEND is true
//   if (AUTO_LAUNCH_BACKEND) {
//     await launchBackend();
//   } else {
//     print('Auto backend launch disabled. Backend not started.');
//   }

//   try {
//     // Properly handle Firebase initialization
//     FirebaseApp? app;
//     if (Firebase.apps.isEmpty) {
//       app = await Firebase.initializeApp(
//         options: DefaultFirebaseOptions.currentPlatform,
//       );
//       print('Firebase initialized successfully');
//     } else {
//       app = Firebase.app();
//       print('Using existing Firebase app');
//     }
    
//     // Initialize Firebase Auth with anonymous authentication
//     await FirebaseService.initializeAuth();
//     print('Firebase Auth initialized');
//   } catch (e) {
//     print('Error initializing Firebase: $e');
//     // Continue with the app even if Firebase fails
//   }

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Language Learning',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: const LanguageSelectorScreen(),
//     );
//   }
// }
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'dart:io';
import 'firebase_options.dart';
import 'screens/language_selector_screen.dart';
import 'screens/voice_chat_screen.dart';
import 'services/firebase_service.dart';
import 'services/lesson_service.dart';

/// Control whether to auto-launch backend
const bool AUTO_LAUNCH_BACKEND = true;

/// Launch backend server (if using Python FastAPI or similar)
Future<void> launchBackend() async {
  try {
    if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
      print('Starting backend server...');
      final String pythonExecutable = Platform.isWindows ? 'python' : 'python3';
      
      // Use dart:io Process to run the command
      try {
        final result = await Process.run(
          pythonExecutable,
          ['launch_backend.py'],
          workingDirectory: Directory.current.path,
        );
        
        if (result.exitCode != 0) {
          print('Error starting backend: ${result.stderr}');
        } else {
          print('Backend initialized: ${result.stdout}');
        }
      } catch (e) {
        print('Process.run error: $e');
      }
    }
  } catch (e) {
    print('Failed to start backend: $e');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Optional: start backend automatically
  if (AUTO_LAUNCH_BACKEND) {
    await launchBackend();
  } else {
    print('Auto backend launch disabled.');
  }

  // Firebase initialization
  try {
    FirebaseApp app;
    if (Firebase.apps.isEmpty) {
      app = await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Firebase initialized successfully');
    } else {
      app = Firebase.app();
      print('Using existing Firebase app');
    }

    // Initialize Firebase Auth if needed
    await FirebaseService.initializeAuth();
    print('Firebase Auth initialized');
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;
  Widget? _initialScreen;

  @override
  void initState() {
    super.initState();
    _checkForSavedState();
  }

  // Check if there's a saved state and determine initial screen
  Future<void> _checkForSavedState() async {
    try {
      final hasState = await FirebaseService.hasUserAppState();
      
      if (hasState) {
        final savedState = await FirebaseService.getUserAppState();
        
        if (savedState != null) {
          final selectedLanguage = savedState['selectedLanguage'] as String;
          final currentLessonIndex = savedState['currentLessonIndex'] as int;
          final messages = savedState['messages'] as List<String>;
          
          print('✅ Restoring previous session: $selectedLanguage (Lesson $currentLessonIndex)');
          
          // If we have messages, navigate directly to the VoiceChatScreen
          if (messages.isNotEmpty) {
            _initialScreen = VoiceChatScreen(
              language: selectedLanguage,
              initialLessonIndex: currentLessonIndex,
              savedMessages: messages,
            );
          } else {
            // If we have just a language but no messages, go to LanguageSelectorScreen
            // with pre-selected language
            _initialScreen = LanguageSelectorScreen(
              initialLanguage: selectedLanguage,
            );
          }
        }
      }
    } catch (e) {
      print('Error checking for saved state: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while checking for saved state
    if (_isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Language Learning',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 17, 84, 125),
          brightness: Brightness.light,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'NotoSans',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        // Basic colors and properties
        primaryColor: const Color.fromARGB(255, 17, 84, 125),
        scaffoldBackgroundColor: Colors.grey[50],
        cardColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
      home: _initialScreen ?? const LanguageSelectorScreen(),
    );
  }
}
