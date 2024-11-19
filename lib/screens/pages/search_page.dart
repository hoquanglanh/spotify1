import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:spotify/screens/pages/music_page.dart';

class SearchPage extends StatefulWidget {
  final Function(String) playPauseMusic;
  final Function(String) showLyrics;
  final Function(String) toggleFavorite;
  final Set<String> favoriteSongs;
  final String currentPlayingSong;
  final bool isPlaying;
  final double volume;
  final Function(double) onVolumeChanged;
  final Map<String, String> songToImageMap;

  const SearchPage({
    Key? key,
    required this.playPauseMusic,
    required this.showLyrics,
    required this.toggleFavorite,
    required this.favoriteSongs,
    required this.currentPlayingSong,
    required this.isPlaying,
    required this.volume,
    required this.onVolumeChanged,
    required this.songToImageMap,
  }) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<dynamic> allSongs = [];
  List<dynamic> filteredSongs = [];
  bool isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  AudioPlayer? audioPlayer;

  @override
  void initState() {
    super.initState();
    fetchSongs();
    audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchSongs() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('https://spotify-8vgb.onrender.com/api/songs'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        setState(() {
          allSongs = data;
          filteredSongs = data;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load songs');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showError('Không thể tải dữ liệu: $e');
    }
  }

  void filterSongs(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredSongs = allSongs;
      } else {
        filteredSongs = allSongs.where((song) {
          final songName = song['name'].toString().toLowerCase();
          final singerName = (song['singer'] ?? '').toString().toLowerCase();
          final searchLower = query.toLowerCase();
          return songName.contains(searchLower) || singerName.contains(searchLower);
        }).toList();
      }
    });
  }

  void showError(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Lỗi'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('Đóng'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  String getImageFileName(String songName) {
    return 'assets/images/songimg/${widget.songToImageMap[songName] ?? 'default.jpg'}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm bài hát hoặc ca sĩ...',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            filterSongs('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: filterSongs,
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : filteredSongs.isEmpty
                      ? Center(
                          child: Text(
                            'Không tìm thấy bài hát nào',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredSongs.length,
                          itemBuilder: (context, index) {
                            final song = filteredSongs[index];
                            final songName = song['name'] ?? 'Không có tên';

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MusicPage(
                                      songName: songName,
                                      singer: song['singer'] ?? 'Unknown',
                                      imagePath: getImageFileName(songName),
                                      audioPlayer: audioPlayer!,
                                      isPlaying: widget.isPlaying,
                                      playPauseMusic: widget.playPauseMusic,
                                      showLyrics: widget.showLyrics,
                                      onVolumeChanged: widget.onVolumeChanged,
                                      volume: widget.volume,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 8.0,
                                  ),
                                  leading: Container(
                                    width: 50.0,
                                    height: 50.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4.0),
                                      image: DecorationImage(
                                        image: AssetImage(getImageFileName(songName)),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    songName,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Ca sĩ: ${song['singer'] ?? 'Không có ca sĩ'}',
                                        style: TextStyle(color: Colors.grey[400]),
                                      ),
                                      Text(
                                        'Thời lượng: ${song['duration'] ?? 'Không có thông tin'}',
                                        style: TextStyle(color: Colors.grey[400]),
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          widget.favoriteSongs.contains(songName)
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: widget.favoriteSongs.contains(songName)
                                              ? Colors.green
                                              : Colors.grey,
                                        ),
                                        onPressed: () => widget.toggleFavorite(songName),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}