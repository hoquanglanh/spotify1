import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:spotify/screens/pages/favorite_page.dart';
import 'package:spotify/screens/pages/music_page.dart';
import 'package:spotify/screens/pages/profile_page.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> albums = [];
  List<dynamic> songs = [];
  Set<String> favoriteSongs = {};
  bool isLoading = true;
  AudioPlayer? audioPlayer;
  bool isPlaying = false;
  String currentPlayingSong = '';
  StreamSubscription? playerStateSubscription;
  StreamSubscription? playerCompleteSubscription;
  double _volume = 1.0;
  int _selectedIndex = 0;
  final storage = FlutterSecureStorage();
  String? userEmail;

  final ScrollController _albumScrollController = ScrollController();
  Timer? _autoScrollTimer;
  bool _isScrolling = true;

  final songToAudioMap = {
    'Standing Next to You': 'standing_next_to_you.mp3',
    'Đánh Đổi': 'danh_doi.mp3',
    'Who': 'who.mp3',
    'Die With A Smile': 'die_with_a_smile.mp3',
    'I will Be There': 'i_will_be_there.mp3',
    'Closer Than This': 'closer_than_this.mp3',
    '3D': '3d.mp3',
    'Bình Yên': 'binh_yen.mp3',
    'Ai Cũng Phải Bắt Đầu Từ Đâu Đó': 'ai_cung_phai_bat_dau_tu_dau_do.mp3',
    'NGÂN': 'ngan.mp3',
    'APT': 'apt.mp3',
  };

  final songToImageMap = {
    '3D': '3d.jpg',
    'Standing Next to You': 'standing_next_to_you.jpg',
    'Đánh Đổi': 'danh_doi.jpg',
    'Who': 'who.jpg',
    'Die With A Smile': 'die_with_a_smile_lady.jpg',
    'I will Be There': 'i_will_be_there.jpg',
    'Closer Than This': 'closer_than_this.jpg',
    'Bình Yên': 'binh_yen.jpg',
    'Ai Cũng Phải Bắt Đầu Từ Đâu Đó': 'ai_cung_phai_bat_dau_tu_dau_do.jpg',
    'NGÂN': 'ngan.jpg',
    'APT': 'apt.jpg',
  };

  final albumToImageMap = {
    'Standing Next to You': 'standing_next_to_you.jpg',
    'Đánh Đổi': 'danh_doi.jpg',
    'Who': 'who.jpg',
    'Die With A Smile': 'die_with_a_smile_lady.jpg',
    'I will Be There': 'i_will_be_there.jpg',
    'MUSE': 'muse.jpg',
    'GOLDEN': 'golden.jpg',
    'Bảo Tàng Của Nuối Tiếc': 'bao_tang_cua_tiec_nuoi.jpg',
    'Ai Cũng Phải Bắt Đầu Từ Đâu Đó': 'ai_cung_phai_bat_dau_tu_dau_do.jpg',
    'FLVR': 'flvr.jpg',
    'APT': 'aptt.jpg',
  };

  @override
  void initState() {
    super.initState();
    initializeAudioPlayer();
    fetchData();
    setupAutoScroll();
    loadFavorites();
    loadUserEmail(); // Thêm hàm load email
  }


  // Thêm hàm loadUserEmail
  Future<void> loadUserEmail() async {
    final storage = FlutterSecureStorage();
    String? email = await storage.read(key: 'user_email');
    setState(() {
      userEmail = email;
    });
  }

  void initializeAudioPlayer() {
    audioPlayer = AudioPlayer();
    audioPlayer?.setVolume(_volume);
    setupAudioPlayerListeners();
  }

  Future<void> loadFavorites() async {
    try {
      String? favoritesJson = await storage.read(key: 'favorites');
      if (favoritesJson != null) {
        setState(() {
          favoriteSongs = Set<String>.from(json.decode(favoritesJson));
        });
      }
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  Future<void> saveFavorites() async {
    try {
      await storage.write(
        key: 'favorites',
        value: json.encode(favoriteSongs.toList()),
      );
    } catch (e) {
      print('Error saving favorites: $e');
    }
  }

  void toggleFavorite(String songName) {
    setState(() {
      if (favoriteSongs.contains(songName)) {
        favoriteSongs.remove(songName);
      } else {
        favoriteSongs.add(songName);
      }
    });
    saveFavorites();
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      // Library tab
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FavoritePage(
            favoriteSongs: songs
                .where((song) => favoriteSongs.contains(song['name']))
                .map((song) => FavoriteSong(
                      name: song['name'],
                      singer: song['singer'] ?? 'Unknown',
                      duration: song['duration'] ?? 'Unknown',
                      isFavorite: true,
                    ))
                .toList(),
            onPlayPause: playPauseMusic,
            showLyrics: _showLyrics,
            toggleFavorite: toggleFavorite,
            currentPlayingSong: currentPlayingSong,
            isPlaying: isPlaying,
            volume: _volume,
            onVolumeChanged: setVolume,
            songToImageMap: songToImageMap,
          ),
        ),
      );
    } else if (index == 3) {
      // Profile tab
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(
            email: userEmail ?? 'Unknown User',
          ),
        ),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }


  Future<void> setVolume(double volume) async {
    if (volume >= 0 && volume <= 1) {
      await audioPlayer?.setVolume(volume);
      if (mounted) {
        setState(() {
          _volume = volume;
        });
      }
    }
  }

  void setupAudioPlayerListeners() {
    playerStateSubscription?.cancel();
    playerCompleteSubscription?.cancel();

    playerStateSubscription =
        audioPlayer?.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) {
        setState(() {
          isPlaying = state == PlayerState.playing;
        });
      }
    });

    playerCompleteSubscription = audioPlayer?.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          isPlaying = false;
          currentPlayingSong = '';
        });
      }
    });
  }

  @override
  void dispose() {
    playerStateSubscription?.cancel();
    playerCompleteSubscription?.cancel();
    _autoScrollTimer?.cancel();
    _albumScrollController.dispose();
    audioPlayer?.dispose();
    super.dispose();
  }

  void setupAutoScroll() {
    _autoScrollTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!_isScrolling || !mounted) return;

      if (_albumScrollController.hasClients) {
        final double maxScroll =
            _albumScrollController.position.maxScrollExtent;
        final double currentScroll = _albumScrollController.offset;
        final double delta = 184.0;

        if (currentScroll >= maxScroll) {
          _albumScrollController.animateTo(
            0,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        } else {
          _albumScrollController.animateTo(
            currentScroll + delta,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }

  Future<void> fetchData() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:8080/api/songs'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        final uniqueAlbums = data.map((song) => song['album']).toSet().toList();

        if (mounted) {
          setState(() {
            albums = uniqueAlbums.map((album) {
              final albumArtist = data
                  .firstWhere((song) => song['album'] == album)['albumArtist'];
              return {
                'name': album,
                'artist': albumArtist,
                'image':
                    'assets/images/albumimg/${albumToImageMap[album] ?? 'default.jpg'}',
              };
            }).toList();
            songs = data;
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        showError('Không thể tải dữ liệu: $e');
      }
    }
  }

  Future<String> fetchLyricsByName(String songName) async {
    final response = await http
        .get(Uri.parse('http://localhost:8080/api/songs/lyrics/$songName'));

    if (response.statusCode == 200) {
      return json.decode(response.body)['lyrics'];
    } else {
      throw Exception('Failed to load lyrics');
    }
  }

  Future<void> playPauseMusic(String songName) async {
    try {
      if (audioPlayer == null) {
        initializeAudioPlayer();
      }

      if (currentPlayingSong == songName && isPlaying) {
        await audioPlayer?.pause();
        if (mounted) {
          setState(() {
            isPlaying = false;
          });
        }
      } else if (currentPlayingSong == songName && !isPlaying) {
        await audioPlayer?.resume();
        if (mounted) {
          setState(() {
            isPlaying = true;
          });
        }
      } else {
        await audioPlayer?.stop();

        final audioFile = songToAudioMap[songName];
        if (audioFile == null) {
          throw Exception('Không tìm thấy file audio cho bài hát này');
        }

        await audioPlayer?.setSourceAsset('audio/$audioFile');
        await audioPlayer?.resume();

        if (mounted) {
          setState(() {
            currentPlayingSong = songName;
            isPlaying = true;
          });
        }
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MusicPage(
              songName: songName,
              singer: songs.firstWhere((song) => song['name'] == songName)['singer'] ?? 'Unknown',
              imagePath: getImageFileName(songName),
              audioPlayer: audioPlayer!,
              isPlaying: isPlaying,
              playPauseMusic: playPauseMusic,
              showLyrics: _showLyrics,
              onVolumeChanged: setVolume,
              volume: _volume,
            ),
          ),
        );
      }

    } catch (e) {
      print('Error playing audio: $e');
      if (mounted) {
        setState(() {
          isPlaying = false;
          currentPlayingSong = '';
        });
        showError('Không thể phát bài hát: $e');
      }
    }
}

  void showError(String message) {
    if (!mounted) return;

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

  void _showLyrics(String songName) async {
    try {
      String lyrics = await fetchLyricsByName(songName);
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(songName),
            content: SingleChildScrollView(
              child: Text(lyrics),
            ),
            actions: [
              TextButton(
                child: Text('Đóng'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      showError('Không thể tải lời bài hát');
    }
  }

  String getImageFileName(String songName) {
    return 'assets/images/songimg/${songToImageMap[songName] ?? 'default.jpg'}';
  }

  String getAlbumImageFileName(String albumName) {
    return 'assets/images/albumimg/${albumToImageMap[albumName] ?? 'default.jpg'}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Container(
              alignment: Alignment.center,
              child: Image.asset(
                'assets/images/spo.png',
                height: 40,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          SizedBox(width: 80),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Danh Sách Album',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _isScrolling ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _isScrolling = !_isScrolling;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      controller: _albumScrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: albums.length,
                      itemBuilder: (context, index) {
                        final album = albums[index];
                        return Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 160.0,
                                height: 160.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                  image: DecorationImage(
                                    image: AssetImage(
                                      getAlbumImageFileName(album['name']),
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(height: 12.0),
                              Container(
                                width: 160.0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      album['name'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4.0),
                                    Text(
                                      album['artist'],
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 14.0,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 32.0),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Danh Sách Bài Hát',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      final song = songs[index];
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
                                audioPlayer: audioPlayer ?? AudioPlayer(),
                                isPlaying: isPlaying,
                                playPauseMusic: playPauseMusic,
                                showLyrics: _showLyrics,
                                onVolumeChanged: setVolume,
                                volume: _volume,
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
                                horizontal: 16.0, vertical: 8.0),
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
                            leading: Container(
                              width: 50.0,
                              height: 50.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.0),
                                image: DecorationImage(
                                  image: AssetImage(
                                    getImageFileName(songName),
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                favoriteSongs.contains(songName)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: favoriteSongs.contains(songName)
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                              onPressed: () => toggleFavorite(songName),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border(
            top: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              activeIcon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite),
              label: 'Library',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.black,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
