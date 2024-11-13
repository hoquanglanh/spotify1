class Song {
  final String? id;
  final String name;
  final String singer;
  final String album;
  final String albumArtist;
  final String duration;
  final String lyrics;
  final String audioFile;
  final String avatar;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int views;
  final bool isActive;
  final List<String> tags;

  Song({
    this.id,
    required this.name,
    required this.singer,
    required this.album,
    required this.albumArtist,
    required this.duration,
    required this.lyrics,
    required this.audioFile,
    required this.avatar,
    required this.createdAt,
    required this.updatedAt,
    required this.views,
    required this.isActive,
    required this.tags,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['_id'],
      name: json['name'],
      singer: json['singer'],
      album: json['album'],
      albumArtist: json['albumArtist'],
      duration: json['duration'],
      lyrics: json['lyrics'],
      audioFile: json['audioFile'] ?? '',
      avatar: json['avatar'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      views: json['views'] ?? 0,
      isActive: json['isActive'] ?? true,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'singer': singer,
      'album': album,
      'albumArtist': albumArtist,
      'duration': duration,
      'lyrics': lyrics,
      'audioFile': audioFile,
      'avatar': avatar,
      'tags': tags,
    };
  }
}