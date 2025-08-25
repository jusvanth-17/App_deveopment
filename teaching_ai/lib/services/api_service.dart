import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // 🔹 Using localhost with the correct port
  static const String backendUrl = "http://127.0.0.1:8080";

  /// Generate syllabus from backend (OpenAI → FastAPI)
  static Future<Map<String, dynamic>> generateSyllabus(String language) async {
    try {
      final response = await http.post(
        Uri.parse("$backendUrl/api/syllabus"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"language": language}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          "status": "success",
          "language": data["language"] ?? language,
          "syllabus_markdown": data["syllabus_markdown"] ?? "",
          "elaborated_syllabus_markdown": data["elaborated_syllabus_markdown"] ?? ""
        };
      } else {
        return {
          "status": "error",
          "code": response.statusCode,
          "message": response.body
        };
      }
    } catch (e) {
      return {
        "status": "error",
        "message": "Failed to connect: $e"
      };
    }
  }
}
