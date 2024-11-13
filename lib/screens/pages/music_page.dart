import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class MusicPage extends StatefulWidget {
  final String songName;
  final String singer;
  final String imagePath;
  final AudioPlayer audioPlayer;
  final bool isPlaying;
  final Function(String) playPauseMusic;
  final Function(String) showLyrics;
  final Function(double) onVolumeChanged;
  final double volume;
  final Duration? duration;
  final Duration? position;

  const MusicPage({
    required this.songName,
    required this.singer,
    required this.imagePath,
    required this.audioPlayer,
    required this.isPlaying,
    required this.playPauseMusic,
    required this.showLyrics,
    required this.onVolumeChanged,
    required this.volume,
    this.duration,
    this.position,
  });

  @override
  _MusicPageState createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> with SingleTickerProviderStateMixin {
  late AnimationController _lyricsPanelController;
  // ignore: unused_field
  bool _isLyricsPanelVisible = false;
  double _currentVolume = 1.0;
  
  late Duration _position;
  late Duration _duration;
  
  late StreamSubscription<Duration> _positionSubscription;
  late StreamSubscription<Duration> _durationSubscription;

  @override
  void initState() {
    super.initState();
    
    _currentVolume = widget.volume;
    _position = widget.position ?? Duration.zero;
    _duration = widget.duration ?? Duration.zero;
    
    _lyricsPanelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _initializeAudio();

    _positionSubscription = widget.audioPlayer.onPositionChanged.listen(
      (Duration position) {
        if (mounted) {
          setState(() {
            _position = position;
          });
        }
      },
    );

    _durationSubscription = widget.audioPlayer.onDurationChanged.listen(
      (Duration duration) {
        if (mounted) {
          setState(() {
            _duration = duration;
          });
        }
      },
    );
  }

  Future<void> _initializeAudio() async {
    try {
      final duration = await widget.audioPlayer.getDuration();
      if (mounted && duration != null) {
        setState(() {
          _duration = duration;
        });
      }

      final position = await widget.audioPlayer.getCurrentPosition();
      if (mounted && position != null) {
        setState(() {
          _position = position;
        });
      }

      widget.audioPlayer.onPlayerComplete.listen((event) {
        if (mounted) {
          setState(() {
            _position = Duration.zero;
          });
        }
      });

    } catch (e) {
      print('Error initializing audio: $e');
    }
  }

  void _adjustVolume(double adjustment) {
    double newVolume = (_currentVolume + adjustment).clamp(0.0, 1.0);
    setState(() {
      _currentVolume = newVolume;
    });
    widget.onVolumeChanged(newVolume);
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    _durationSubscription.cancel();
    _lyricsPanelController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.volume_down, color: Colors.white, size: 20),
                onPressed: () => _adjustVolume(-0.1),
              ),
              Container(
                width: 100,
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 2,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 4),
                  ),
                  child: Slider(
                    value: _currentVolume,
                    min: 0.0,
                    max: 1.0,
                    activeColor: Colors.green,
                    inactiveColor: Colors.grey[800],
                    onChanged: (value) {
                      setState(() {
                        _currentVolume = value;
                      });
                      widget.onVolumeChanged(value);
                    },
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.volume_up, color: Colors.white, size: 20),
                onPressed: () => _adjustVolume(0.1),
              ),
              IconButton(
                icon: Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: AssetImage(widget.imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.songName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              widget.singer,
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.favorite_border, color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 2,
                            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
                          ),
                          child: Slider(
                            value: _position.inSeconds.toDouble().clamp(0, _duration.inSeconds.toDouble()),
                            min: 0,
                            max: _duration.inSeconds.toDouble() == 0 ? 1 : _duration.inSeconds.toDouble(),
                            activeColor: Colors.green,
                            inactiveColor: Colors.grey[800],
                            onChanged: (value) {
                              widget.audioPlayer.seek(Duration(seconds: value.toInt()));
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(_position),
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                              Text(
                                _formatDuration(_duration),
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(Icons.shuffle, color: Colors.white, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.skip_previous, color: Colors.white, size: 24),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () {},
                        ),
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                          ),
                          child: IconButton(
                            icon: Icon(
                              widget.isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 20,
                            ),
                            padding: EdgeInsets.zero,
                            onPressed: () => widget.playPauseMusic(widget.songName),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.skip_next, color: Colors.white, size: 24),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.repeat, color: Colors.white, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: GestureDetector(
                onTap: () => widget.showLyrics(widget.songName),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lyrics, color: Colors.grey[400], size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Lyrics',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}