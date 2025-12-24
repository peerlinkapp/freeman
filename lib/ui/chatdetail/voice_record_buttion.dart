import 'dart:async';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:freeman/common.dart';


class VoiceRecorderButton extends StatefulWidget {
  final Function(String path, Duration duration)? onStop;

  const VoiceRecorderButton({super.key, this.onStop});

  @override
  State<VoiceRecorderButton> createState() => _VoiceRecorderButtonState();
}

class _VoiceRecorderButtonState extends State<VoiceRecorderButton> {

  final RecorderController _recorderController = RecorderController();
  Timer? _timer;
  Duration _duration = Duration.zero;
  bool _isRecording = false;
  bool _isCancel = false;
  Offset _startPosition = Offset.zero;
  final double _cancelThreshold = 60;

  @override
  void dispose() {
    _timer?.cancel();
    _recorderController.dispose();
    super.dispose();
  }
  Future<void> _startRecording() async {
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      print('麦克风权限未授予');
      return;
    }

    try {
      String voicePath = await Global.getVoicePath();
      final filePath = '$voicePath/record_${DateTime.now().millisecondsSinceEpoch}.m4a';

      _recorderController
        ..androidEncoder = AndroidEncoder.aac
        ..androidOutputFormat = AndroidOutputFormat.mpeg4
        ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
        ..sampleRate = 16000;

      _recorderController.reset();
      await _recorderController.record(path: filePath);
    } catch (e, stack) {
      print('录音启动失败：$e');
      print(stack);
    }

    _duration = Duration.zero;
    _isCancel = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _duration += const Duration(seconds: 1);
      });

      if (_duration >= const Duration(seconds: 60)) {
        _stopRecording();
      }
    });

    setState(() {
      _isRecording = true;
    });
  }


  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    _timer?.cancel();
    final path = await _recorderController.stop(); // 停止 audio_waveforms

    if (!_isCancel && path != null && widget.onStop != null) {
      widget.onStop!(path, _duration);
    }

    setState(() {
      _isRecording = false;
      _duration = Duration.zero;
    });
  }


  void _checkCancel(Offset currentPosition) {
    final dy = _startPosition.dy - currentPosition.dy;
    if (dy > _cancelThreshold && !_isCancel) {
      setState(() {
        _isCancel = true;
      });
    } else if (dy <= _cancelThreshold && _isCancel) {
      setState(() {
        _isCancel = false;
      });
    }
  }

  String _formatDuration(Duration d) {
    final s = 60 - d.inSeconds;
    return '${(s ~/ 10)}${s % 10}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (details) {
        _startPosition = details.globalPosition;
        _startRecording();
      },
      onLongPressMoveUpdate: (details) {
        _checkCancel(details.globalPosition);
      },
      onLongPressEnd: (_) {
        _stopRecording();
      },
      child: Container(
        width: 220,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _isRecording
              ? (_isCancel ? Colors.red.shade300 : Colors.blue.shade100)
              : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.blueAccent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mic, color: _isCancel ? Colors.red : Colors.blue),
            const SizedBox(width: 8),
            if (_isRecording)
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AudioWaveforms(
                      enableGesture: false,
                      size: const Size(double.infinity, 30),
                      recorderController: _recorderController,
                      waveStyle: const WaveStyle(
                        waveColor: Colors.blue,
                        extendWaveform: true,
                        showMiddleLine: false,
                      ),
                    ),
                    Text(
                      _isCancel ? "松开取消" : "倒计时: ${_formatDuration(_duration)}s",
                      style: TextStyle(
                        color: _isCancel ? Colors.red : Colors.black87,
                        fontSize: 12,
                      ),
                    )
                  ],
                ),
              )
            else
              Text(Global.l10n.chat_voice_push_down, style: TextStyle(color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}
