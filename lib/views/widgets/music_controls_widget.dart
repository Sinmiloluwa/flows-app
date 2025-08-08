import 'package:flutter/material.dart';
import 'package:flows/services/audio_player_service.dart';
import 'package:just_audio/just_audio.dart';

class MusicControls extends StatefulWidget {
  final Map<String, dynamic>? song;
  final bool showTimeLabels;
  
  const MusicControls({
    super.key,
    this.song,
    this.showTimeLabels = true,
  });

  @override
  State<MusicControls> createState() => _MusicControlsState();
}

class _MusicControlsState extends State<MusicControls> {
  final AudioPlayerService _audioService = AudioPlayerService();
  bool _isShuffleEnabled = false;
  LoopMode _loopMode = LoopMode.off;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      constraints: const BoxConstraints(
        maxWidth: double.infinity,
      ),
      child: StreamBuilder<ProgressData>(
        stream: _audioService.progressStream,
        builder: (context, snapshot) {
          final progressData = snapshot.data;
          final currentSong = _audioService.currentSong;
          final isCurrentSong = widget.song != null && _audioService.isPlayingSong(widget.song!);
          final isPlaying = progressData?.playerState.playing == true && isCurrentSong;
          
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress Bar
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.greenAccent,
                  inactiveTrackColor: Colors.grey[800],
                  thumbColor: Colors.greenAccent,
                  overlayColor: Colors.green.withOpacity(0.2),
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                  trackShape: const RectangularSliderTrackShape(),
                ),
                child: Slider(
                  value: isCurrentSong 
                      ? (progressData?.progress ?? 0.0) 
                      : 0.0,
                  onChanged: isCurrentSong 
                      ? (value) {
                          final duration = progressData?.duration ?? Duration.zero;
                          final position = duration * value;
                          _audioService.seek(position);
                        }
                      : null,
                ),
              ),

              // Time indicators
              if (widget.showTimeLabels)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isCurrentSong 
                            ? _formatDuration(progressData?.position ?? Duration.zero)
                            : "0:00",
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Text(
                        isCurrentSong 
                            ? _formatDuration(progressData?.duration ?? Duration.zero)
                            : _formatDuration(_getSongDuration()),
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Control Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Shuffle Button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isShuffleEnabled = !_isShuffleEnabled;
                      });
                      _audioService.setShuffleMode(_isShuffleEnabled);
                    },
                    child: Icon(
                      Icons.shuffle,
                      color: _isShuffleEnabled ? Colors.greenAccent : Colors.white,
                      size: 24,
                    ),
                  ),
                  
                  // Previous Button
                  GestureDetector(
                    onTap: isCurrentSong ? () => _audioService.seekToPrevious() : null,
                    child: Icon(
                      Icons.skip_previous,
                      size: 32,
                      color: isCurrentSong ? Colors.white : Colors.grey,
                    ),
                  ),

                  // Play/Pause Button
                  GestureDetector(
                    onTap: () => _handlePlayPause(),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.greenAccent,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.greenAccent.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 32,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  // Next Button
                  GestureDetector(
                    onTap: isCurrentSong ? () => _audioService.seekToNext() : null,
                    child: Icon(
                      Icons.skip_next,
                      size: 32,
                      color: isCurrentSong ? Colors.white : Colors.grey,
                    ),
                  ),
                  
                  // Repeat Button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        switch (_loopMode) {
                          case LoopMode.off:
                            _loopMode = LoopMode.all;
                            break;
                          case LoopMode.all:
                            _loopMode = LoopMode.one;
                            break;
                          case LoopMode.one:
                            _loopMode = LoopMode.off;
                            break;
                        }
                      });
                      _audioService.setLoopMode(_loopMode);
                    },
                    child: Icon(
                      _loopMode == LoopMode.off 
                          ? Icons.repeat
                          : _loopMode == LoopMode.all 
                              ? Icons.repeat 
                              : Icons.repeat_one,
                      color: _loopMode != LoopMode.off ? Colors.greenAccent : Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _handlePlayPause() async {
    try {
      final currentSong = _audioService.currentSong;
      final isCurrentSong = widget.song != null && _audioService.isPlayingSong(widget.song!);
      final isPlaying = _audioService.isPlaying;

      if (widget.song == null) {
        // No song provided, just control current playback
        if (isPlaying) {
          await _audioService.pause();
        } else {
          await _audioService.play();
        }
      } else if (isCurrentSong) {
        // Current song is playing, toggle play/pause
        if (isPlaying) {
          await _audioService.pause();
        } else {
          await _audioService.play();
        }
      } else {
        // Different song, start playing the new song
        await _audioService.playSong(widget.song!);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to play song: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Duration _getSongDuration() {
    if (widget.song == null) return Duration.zero;
    
    // Try to get duration from song data
    final durationValue = widget.song!['duration'];
    if (durationValue != null) {
      if (durationValue is int) {
        return Duration(seconds: durationValue);
      } else if (durationValue is String) {
        // Parse duration string like "4:21" or "261"
        if (durationValue.contains(':')) {
          final parts = durationValue.split(':');
          if (parts.length == 2) {
            final minutes = int.tryParse(parts[0]) ?? 0;
            final seconds = int.tryParse(parts[1]) ?? 0;
            return Duration(minutes: minutes, seconds: seconds);
          }
        } else {
          final seconds = int.tryParse(durationValue) ?? 0;
          return Duration(seconds: seconds);
        }
      }
    }
    
    return const Duration(minutes: 4, seconds: 21); // Default fallback
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}