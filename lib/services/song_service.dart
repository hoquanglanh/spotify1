import 'dart:convert';

import 'package:spotify/models/song_model.dart';
import 'package:http/http.dart' as http;

class SongService {
  static const String baseUrl = 'http://localhost:8080/api/songs';

  // Helper method để xử lý response
  static dynamic _handleResponse(http.Response response, {bool isCreate = false}) {
    if (response.statusCode == 200 || (isCreate && response.statusCode == 201)) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw Exception('Failed to parse response: $e');
      }
    } else {
      throw Exception('Request failed with status: ${response.statusCode}');
    }
  }

  // Lấy danh sách bài hát
  static Future<List<Song>> getSongs() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      final data = _handleResponse(response);
      
      if (data is! List) {
        throw Exception('Expected list of songs but got ${data.runtimeType}');
      }
      
      return data.map((json) => Song.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch songs: $e');
    }
  }

  // Tạo bài hát mới
  static Future<Song> createSong(Map<String, dynamic> songData) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(songData),
      );
      
      final data = _handleResponse(response, isCreate: true);
      return Song.fromJson(data);
    } catch (e) {
      throw Exception('Failed to create song: $e');
    }
  }

  // Cập nhật bài hát
  static Future<Song> updateSong(String id, Map<String, dynamic> songData) async {
    try {
      final response = await http.put( // Đổi từ PATCH sang PUT nếu server yêu cầu
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(songData),
      );
      
      final data = _handleResponse(response);
      return Song.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update song: $e');
    }
  }

  // Xóa bài hát
  static Future<void> deleteSong(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete song: Status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete song: $e');
    }
  }

  // Lấy lyrics của bài hát
  static Future<String> getLyrics(String songName) async {
    try {
      final encodedName = Uri.encodeComponent(songName);
      final response = await http.get(
        Uri.parse('$baseUrl/lyrics/$encodedName'),
        headers: {
          'Accept': 'application/json',
        },
      );
      
      final data = _handleResponse(response);
      
      if (data is! Map || !data.containsKey('lyrics')) {
        throw Exception('Invalid lyrics response format');
      }
      
      return data['lyrics'] as String;
    } catch (e) {
      throw Exception('Failed to fetch lyrics: $e');
    }
  }

  // Lấy thông tin một bài hát theo ID
  static Future<Song> getSongById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Accept': 'application/json',
        },
      );
      
      final data = _handleResponse(response);
      return Song.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch song: $e');
    }
  }
}