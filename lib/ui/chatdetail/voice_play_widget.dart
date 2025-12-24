import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'dart:async';

class VoicePlayerWidget extends StatefulWidget {
  final String filePath;
  final double height;
  final Color waveColor;
  final Color backgroundColor;

  const VoicePlayerWidget({
    super.key,
    required this.filePath,
    this.height = 2,
    this.waveColor = Colors.blue,
    this.backgroundColor = Colors.grey,
  });

  @override
  State<VoicePlayerWidget> createState() => _VoicePlayerWidgetState();
}

class _VoicePlayerWidgetState extends State<VoicePlayerWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final PlayerController _waveController = PlayerController();

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  StreamSubscription<Duration>? _positionSub;

  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _setupPlayer();
  }

  Future<void> _setupPlayer() async {
    try {
      await _audioPlayer.setFilePath(widget.filePath);
      _duration = _audioPlayer.duration ?? Duration.zero;

      _positionSub = _audioPlayer.positionStream.listen((pos) {
        setState(() {
          _position = pos;
        });
      });

      _audioPlayer.playerStateStream.listen((state) {
        final playing = state.playing;
        final completed = state.processingState == ProcessingState.completed;
        if (completed) {
          _audioPlayer.seek(Duration.zero);
          _audioPlayer.pause(); // ✅ 添加这一行防止再次播放
          setState(() {
            _isPlaying = false;
            _position = Duration.zero;
          });
        } else {
          if (mounted) {
            setState(() {
              _isPlaying = playing;
            });
          }
        }
      });

      _waveController.startPlayer();
    } catch (e) {
      print("音频加载失败: $e");
    }
  }

  String _formatTime(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _onSeek(double value) {
    final newPos = Duration(milliseconds: value.toInt());
    _audioPlayer.seek(newPos);
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _audioPlayer.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalMs = _duration.inMilliseconds.toDouble();
    final posMs = _position.inMilliseconds.toDouble();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: widget.backgroundColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: () async {
              if (_isPlaying) {
                await _audioPlayer.pause();
                _waveController.pausePlayer();
              } else {
                await _audioPlayer.play();
                _waveController.startPlayer();
              }
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AudioFileWaveforms(
                  size: Size(double.infinity, widget.height),
                  playerController: _waveController,
                  waveformType: WaveformType.fitWidth,
                  enableSeekGesture: true,
                  playerWaveStyle: PlayerWaveStyle(
                    fixedWaveColor: widget.waveColor,
                    liveWaveColor: widget.waveColor,
                    showSeekLine: false,
                  ),
                ),
                Slider(
                  min: 0,
                  max: totalMs,
                  value: posMs.clamp(0, totalMs),
                  onChanged: (v) => _onSeek(v),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatTime(_position),
                        style: TextStyle(fontSize: 12)),
                    Text(_formatTime(_duration),
                        style: TextStyle(fontSize: 12)),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
