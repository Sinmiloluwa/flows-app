import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:rxdart/rxdart.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  final AudioPlayer _player = AudioPlayer();
  
  // Current song info
  Map<String, dynamic>? _currentSong;
  List<Map<String, dynamic>> _playlist = [];
  int _currentIndex = 0;

  // Getters for current state
  AudioPlayer get player => _player;
  Map<String, dynamic>? get currentSong => _currentSong;
  List<Map<String, dynamic>> get playlist => _playlist;
  int get currentIndex => _currentIndex;
  
  // Stream for UI updates
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  
  // Combined stream for progress
  Stream<ProgressData> get progressStream => Rx.combineLatest3<Duration, Duration?, PlayerState, ProgressData>(
    positionStream,
    durationStream,
    playerStateStream,
    (position, duration, playerState) => ProgressData(
      position: position,
      duration: duration ?? Duration.zero,
      playerState: playerState,
    ),
  );

  Future<void> initialize() async {
    try {
      // Initialize audio session
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      
      // Handle audio interruptions (phone calls, etc.)
      session.interruptionEventStream.listen((event) {
        if (event.begin) {
          switch (event.type) {
            case AudioInterruptionType.duck:
              _player.setVolume(0.5);
              break;
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              _player.pause();
              break;
          }
        } else {
          switch (event.type) {
            case AudioInterruptionType.duck:
              _player.setVolume(1.0);
              break;
            case AudioInterruptionType.pause:
              _player.play();
              break;
            case AudioInterruptionType.unknown:
              break;
          }
        }
      });

      // Handle becoming noisy (headphones unplugged)
      session.becomingNoisyEventStream.listen((_) {
        _player.pause();
      });
      
      print('AudioPlayerService initialized successfully');
    } catch (error) {
      print('Error initializing AudioPlayerService: $error');
    }
  }

  // Play a single song
  Future<void> playSong(Map<String, dynamic> song) async {
    try {
      _currentSong = song;
      
      String? audioUrl = song['audio_url'] ?? song['stream_url'] ?? song['url'];
      if (audioUrl == null || audioUrl.isEmpty) {
        throw Exception('No audio URL found for this song');
      }

      print('Playing song: ${song['title'] ?? 'Unknown'} from URL: $audioUrl');
      await _player.setAudioSource(AudioSource.uri(Uri.parse(audioUrl)));
      await _player.play();
      
    } catch (error) {
      print('Error playing song: $error');
      throw Exception('Failed to play song: $error');
    }
  }

  // Play a playlist starting from a specific index
  Future<void> playPlaylist(List<Map<String, dynamic>> songs, {int startIndex = 0}) async {
    if (songs.isEmpty) {
      throw Exception('Playlist is empty');
    }

    _playlist = songs;
    _currentIndex = startIndex.clamp(0, songs.length - 1);
    
    // Create a concatenating audio source for seamless playlist playback
    final audioSources = <AudioSource>[];
    
    for (var song in songs) {
      String? audioUrl = song['audio_url'] ?? song['stream_url'] ?? song['url'];
      if (audioUrl != null && audioUrl.isNotEmpty) {
        audioSources.add(AudioSource.uri(Uri.parse(audioUrl)));
      }
    }

    if (audioSources.isEmpty) {
      throw Exception('No playable songs in playlist');
    }

    final concatenatingSource = ConcatenatingAudioSource(children: audioSources);
    await _player.setAudioSource(concatenatingSource, initialIndex: _currentIndex);
    _currentSong = songs[_currentIndex];
    await _player.play();
  }

  // Playback controls
  Future<void> play() async {
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
    _currentSong = null;
  }

  Future<void> seekToNext() async {
    if (_playlist.isNotEmpty && _currentIndex < _playlist.length - 1) {
      _currentIndex++;
      _currentSong = _playlist[_currentIndex];
      await _player.seekToNext();
    }
  }

  Future<void> seekToPrevious() async {
    if (_playlist.isNotEmpty && _currentIndex > 0) {
      _currentIndex--;
      _currentSong = _playlist[_currentIndex];
      await _player.seekToPrevious();
    }
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume.clamp(0.0, 1.0));
  }

  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed.clamp(0.5, 2.0));
  }

  // Shuffle and repeat
  Future<void> setShuffleMode(bool enabled) async {
    await _player.setShuffleModeEnabled(enabled);
  }

  Future<void> setLoopMode(LoopMode loopMode) async {
    await _player.setLoopMode(loopMode);
  }

  // Check if currently playing a specific song
  bool isPlayingSong(Map<String, dynamic> song) {
    if (_currentSong == null) return false;
    return _currentSong!['id'] == song['id'] || _currentSong!['_id'] == song['_id'];
  }

  // Check if player is currently playing
  bool get isPlaying => _player.playing;

  // Dispose
  Future<void> dispose() async {
    await _player.dispose();
  }
}

// Helper class for progress data
class ProgressData {
  final Duration position;
  final Duration duration;
  final PlayerState playerState;

  ProgressData({
    required this.position,
    required this.duration,
    required this.playerState,
  });

  double get progress => duration.inMilliseconds > 0 
      ? position.inMilliseconds / duration.inMilliseconds 
      : 0.0;
}