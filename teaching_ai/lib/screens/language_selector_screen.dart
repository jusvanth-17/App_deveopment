import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ Firebase Firestore
import 'package:firebase_analytics/firebase_analytics.dart'; // ✅ Firebase Analytics
import 'voice_chat_screen.dart';
import '../services/api_service.dart';
import '../services/firebase_service.dart';
import '../services/lesson_service.dart';
import '../models/lesson_content.dart';

class LanguageSelectorScreen extends StatefulWidget {
  final String? initialLanguage;
  
  const LanguageSelectorScreen({super.key, this.initialLanguage});

  @override
  State<LanguageSelectorScreen> createState() => _LanguageSelectorScreenState();
}

class _LanguageSelectorScreenState extends State<LanguageSelectorScreen> {
  String? _selectedLanguage;
  String? _syllabusMarkdown;
  String? _elaboratedSyllabusMarkdown;
  bool _isLoadingSyllabus = false;
  bool _showElaborated = false; // Toggle between normal and elaborated view

  final String _username = "to language learning";

  final List<String> _languages = ["Spanish", "French", "German", "Japanese"];
  
  @override
  void initState() {
    super.initState();
    
    // If we have an initial language from restored state, use it
    if (widget.initialLanguage != null) {
      _selectedLanguage = widget.initialLanguage;
      _loadSyllabus(_selectedLanguage!);
    }
  }

  /// 🔹 Store syllabus in Firebase Firestore using anonymous authentication
  Future<void> _saveSyllabusToFirebase(
    String subject, 
    String syllabus, 
    {String? elaboratedSyllabus}
  ) async {
    try {
      // Use the enhanced Firebase service with anonymous auth
      final success = await FirebaseService.saveSyllabus(
        subject, 
        syllabus, 
        elaboratedSyllabusMarkdown: elaboratedSyllabus
      );
      
      if (success) {
        debugPrint("✅ Syllabus for $subject successfully stored in Firebase.");
        if (elaboratedSyllabus != null) {
          debugPrint("✅ Elaborated syllabus also stored.");
        }
      } else {
        debugPrint("⚠️ Failed to save syllabus to Firebase, but continuing with local version.");
      }
    } catch (e) {
      // Just log the error but continue with app function since we have the syllabus in memory
      debugPrint("🔥 Error saving syllabus: $e");
      debugPrint("🔹 Continuing with syllabus in memory even though Firebase save failed");
    }
  }

  /// 🔹 Generate language syllabus content from OpenAI
  Future<void> _loadSyllabus(String language) async {
    setState(() {
      _isLoadingSyllabus = true;
      _syllabusMarkdown = null;
      _elaboratedSyllabusMarkdown = null;
    });

    // Call API service to generate syllabus using OpenAI
    final result = await ApiService.generateSyllabus(language);
    
    if (mounted) {
      setState(() {
        _isLoadingSyllabus = false;
        
        if (result["status"] == "success") {
          _syllabusMarkdown = result["syllabus_markdown"];
          _elaboratedSyllabusMarkdown = result["elaborated_syllabus_markdown"];
          
          /// ✅ Save directly to Firebase after generating
          _saveSyllabusToFirebase(
            language, 
            _syllabusMarkdown!,
            elaboratedSyllabus: _elaboratedSyllabusMarkdown
          );
        } else {
          _syllabusMarkdown = null;
          _elaboratedSyllabusMarkdown = null;
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error generating syllabus: ${result["message"] ?? "Unknown error"}"),
              action: SnackBarAction(
                label: "Retry",
                onPressed: () => _loadSyllabus(language),
              ),
            ),
          );
        }
      });
    }
  }

  void _startLearning() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => VoiceChatScreen(language: _selectedLanguage!)),
      );
  }

  void _showSyllabus() {
    if (_syllabusMarkdown == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a language to view its syllabus")),
      );
      return;
    }
    
    // Log syllabus view event
    FirebaseAnalytics.instance.logEvent(
      name: 'view_syllabus',
      parameters: {
        'language': _selectedLanguage ?? 'unknown',
      },
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Toggle switch for Normal/Elaborated
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Syllabus View",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Switch(
                        value: _showElaborated,
                        onChanged: (value) {
                          setState(() {
                            _showElaborated = value;
                          });
                          
                          // Also update the parent state to remember the selection
                          this.setState(() {
                            _showElaborated = value;
                          });
                          
                          // Log which syllabus version is being viewed
                          FirebaseAnalytics.instance.logEvent(
                            name: 'toggle_syllabus_view',
                            parameters: {
                              'language': _selectedLanguage ?? 'unknown',
                              'view_type': value ? 'elaborated' : 'normal',
                            },
                          );
                        },
                        activeColor: const Color.fromARGB(255, 17, 84, 125),
                      ),
                      Text(
                        _showElaborated ? "Elaborated" : "Normal",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Syllabus content
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: MarkdownBody(
                        data: _showElaborated && _elaboratedSyllabusMarkdown != null
                            ? _elaboratedSyllabusMarkdown!
                            : _syllabusMarkdown!,
                        styleSheet: MarkdownStyleSheet(
                          h1: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                          h2: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.blue),
                          p: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                          listBullet: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- HEADER ----------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Syllabus button
                  InkWell(
                    onTap: _showSyllabus,
                    borderRadius: BorderRadius.circular(30),
                    child: Row(
                      children: [
                        const FaIcon(FontAwesomeIcons.bookOpen, size: 18, color: Color.fromARGB(255, 17, 84, 125)),
                        const SizedBox(width: 6),
                        Text(
                          "Syllabus",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Subject dropdown
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      icon: const FaIcon(FontAwesomeIcons.language, size: 18, color: Color.fromARGB(255, 17, 84, 125)),
                      hint: Text(
                        "Select Language",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                      value: _selectedLanguage,
                      items: _languages.map((language) {
                        return DropdownMenuItem(
                          value: language,
                          child: Text(
                            language,
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedLanguage = val;
                          });
                          _loadSyllabus(val); // ✅ auto-generate & save
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ---------- WELCOME TEXT ----------
            Center(
              child: Text(
                "Welcome, $_username 👋",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: const Color.fromARGB(255, 17, 84, 125),
                ),
              ),
            ),

            const Spacer(),

            const Spacer(),

            if (_isLoadingSyllabus)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              ),

            // ---------- START LEARNING BUTTON ----------
            Center(
              child: InkWell(
                onTap: _selectedLanguage == null ? null : _startLearning,
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _selectedLanguage == null
                        ? const LinearGradient(colors: [Colors.grey, Colors.grey])
                        : const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 17, 84, 125),
                              Color.fromARGB(255, 30, 100, 150),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                  child: Text(
                    "Start\nLearning",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}
