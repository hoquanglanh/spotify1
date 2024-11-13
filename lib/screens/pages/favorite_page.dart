import 'package:flutter/material.dart';

class FavoritePage extends StatefulWidget {
  final List<FavoriteSong> favoriteSongs;
  final Function(String) onPlayPause;
  final Function(String) showLyrics;
  final Function(String) toggleFavorite;
  final String currentPlayingSong;
  final bool isPlaying;
  final double volume;
  final Function(double) onVolumeChanged;
  final Map<String, String> songToImageMap;

  const FavoritePage({
    Key? key,
    required this.favoriteSongs,
    required this.onPlayPause,
    required this.showLyrics,
    required this.toggleFavorite,
    required this.currentPlayingSong,
    required this.isPlaying,
    required this.volume,
    required this.onVolumeChanged,
    required this.songToImageMap,
  }) : super(key: key);

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  late List<FavoriteSong> localFavoriteSongs;

  @override
  void initState() {
    super.initState();
    localFavoriteSongs = List.from(widget.favoriteSongs);
  }

  @override
  void didUpdateWidget(FavoritePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.favoriteSongs != oldWidget.favoriteSongs) {
      localFavoriteSongs = List.from(widget.favoriteSongs);
    }
  }

  void handlePlayPause(String songName) {
    widget.onPlayPause(songName);
  }

  String getImageFileName(String songName) {
    return 'assets/images/songimg/${widget.songToImageMap[songName] ?? 'default.jpg'}';
  }

  void _handleRemoveFromFavorites(String songName) {
    widget.toggleFavorite(songName);
    setState(() {
      localFavoriteSongs.removeWhere((song) => song.name == songName);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã xóa "$songName" khỏi danh sách yêu thích'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Thêm hàm để đảm bảo giá trị volume hợp lệ
  double _validateVolume(double value) {
    if (value.isNaN) return 0.0;
    if (value.isInfinite) return 1.0;
    return value.clamp(0.0, 1.0);
  }

  void _handleVolumeChange(double newVolume) {
    final validVolume = _validateVolume(newVolume);
    widget.onVolumeChanged(validVolume);
  }

  @override
  Widget build(BuildContext context) {
    // Đảm bảo giá trị volume hiện tại hợp lệ
    final currentVolume = _validateVolume(widget.volume);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Bài Hát Yêu Thích',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: localFavoriteSongs.isEmpty
          ? const Center(
              child: Text(
                'Chưa có bài hát yêu thích nào',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: localFavoriteSongs.length,
              itemBuilder: (context, index) {
                final song = localFavoriteSongs[index];
                final isThisSongPlaying =
                    widget.currentPlayingSong == song.name;

                return Container(
                  height: 72,
                  margin:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4.0),
                          child: Image.asset(
                            getImageFileName(song.name),
                            width: 40.0,
                            height: 40.0,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              song.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Ca sĩ: ${song.singer}',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (isThisSongPlaying && widget.isPlaying)
                        SizedBox(
                          width: 140,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.volume_down,
                                    color: Colors.white, size: 18),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                    minWidth: 24, minHeight: 24),
                                onPressed: () =>
                                    _handleVolumeChange(currentVolume - 0.1),
                              ),
                              Expanded(
                                child: Slider(
                                  value: currentVolume,
                                  min: 0.0,
                                  max: 1.0,
                                  activeColor: Colors.green,
                                  inactiveColor: Colors.grey,
                                  onChanged: _handleVolumeChange,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.volume_up,
                                    color: Colors.white, size: 18),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                    minWidth: 24, minHeight: 24),
                                onPressed: () =>
                                    _handleVolumeChange(currentVolume + 0.1),
                              ),
                            ],
                          ),
                        ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              (isThisSongPlaying && widget.isPlaying)
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_filled,
                              color: Colors.white,
                              size: 22,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minWidth: 24, minHeight: 24),
                            onPressed: () => handlePlayPause(song.name),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.queue_music,
                              color: Colors.white,
                              size: 18,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minWidth: 24, minHeight: 24),
                            onPressed: () => widget.showLyrics(song.name),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.favorite,
                              color: Colors.green,
                              size: 18,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minWidth: 24, minHeight: 24),
                            onPressed: () =>
                                _handleRemoveFromFavorites(song.name),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class FavoriteSong {
  final String name;
  final String singer;
  final String duration;
  final bool isFavorite;

  FavoriteSong({
    required this.name,
    required this.singer,
    required this.duration,
    required this.isFavorite,
  });
}