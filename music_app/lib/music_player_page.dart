import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'lyrics_page.dart';

class MusicPlayerPage extends StatefulWidget {
  const MusicPlayerPage({super.key});

  @override
  State<MusicPlayerPage> createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  final AudioPlayer _player = AudioPlayer();
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  Duration? _dragPosition;
  bool _isReady = false;
  bool _isPlaying = false;
  bool _isBusy = false;
  bool _hasCompleted = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _subscriptions.addAll([
      _player.onDurationChanged.listen((duration) {
        if (mounted) setState(() => _duration = duration);
      }),
      _player.onPositionChanged.listen((position) {
        if (mounted && !_hasCompleted) setState(() => _position = position);
      }),
      _player.onPlayerStateChanged.listen((state) {
        if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
      }),
      _player.onPlayerComplete.listen((_) {
        if (mounted) {
          setState(() {
            _isPlaying = false;
            _hasCompleted = true;
            _position = Duration.zero;
          });
        }
      }),
    ]);

    _loadSong();
  }

  Future<void> _loadSong() async {
    try {
      // Keep the source available so Play can restart it after completion.
      await _player.setReleaseMode(ReleaseMode.stop);
      if (!mounted) return;
      await _player.setSource(
        AssetSource('music/Total_Eclipse_Of_The_Heart.mp3'),
      );
      if (!mounted) return;
      final duration = await _player.getDuration();
      if (!mounted) return;
      setState(() {
        _duration = duration ?? _duration;
        _isReady = true;
      });
    } catch (_) {
      if (mounted) setState(() => _errorMessage = 'Could not load the song.');
    }
  }

  Future<void> _togglePlayback() async {
    if (!_isReady || _isBusy) return;
    final wasPlaying = _isPlaying;
    setState(() => _isBusy = true);

    try {
      if (wasPlaying) {
        await _player.pause();
      } else {
        if (_hasCompleted) {
          await _player.seek(Duration.zero);
          _hasCompleted = false;
        }
        await _player.resume();
      }
      if (mounted) setState(() => _isPlaying = !wasPlaying);
    } catch (_) {
      if (mounted) setState(() => _errorMessage = 'Could not play the song.');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _seekTo(Duration position) async {
    try {
      await _player.seek(position);
      if (mounted) {
        setState(() {
          _position = position;
          _dragPosition = null;
          _hasCompleted = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _dragPosition = null;
          _errorMessage = 'Could not seek in the song.';
        });
      }
    }
  }

  String _formatTime(Duration value) {
    final minutes = value.inMinutes;
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _openLyrics() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const LyricsPage()));
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    unawaited(_player.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF1DB954);
    final shownPosition = _dragPosition ?? _position;
    final durationMs = _duration.inMilliseconds;
    final sliderValue = shownPosition.inMilliseconds
        .clamp(0, durationMs)
        .toDouble();

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final artworkSize = min(
              constraints.maxWidth - 48,
              constraints.maxHeight * 0.43,
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 40,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/images/bonnie_tyler.jpg',
                          width: artworkSize,
                          height: artworkSize,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Total Eclipse of the Heart',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Bonnie Tyler',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 28),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: green,
                        inactiveTrackColor: Colors.white30,
                        thumbColor: green,
                        overlayColor: green.withValues(alpha: 0.2),
                      ),
                      child: Slider(
                        min: 0,
                        max: durationMs > 0 ? durationMs.toDouble() : 1,
                        value: sliderValue,
                        onChanged: _isReady && durationMs > 0
                            ? (value) {
                                setState(() {
                                  _dragPosition = Duration(
                                    milliseconds: value.round(),
                                  );
                                });
                              }
                            : null,
                        onChangeEnd: _isReady && durationMs > 0
                            ? (value) =>
                                  _seekTo(Duration(milliseconds: value.round()))
                            : null,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatTime(shownPosition)),
                          Text(_formatTime(_duration)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const IconButton(
                          onPressed: null,
                          icon: Icon(Icons.skip_previous),
                          tooltip: 'Previous unavailable',
                          iconSize: 36,
                        ),
                        IconButton.filled(
                          onPressed: _isReady && !_isBusy
                              ? _togglePlayback
                              : null,
                          icon: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                          ),
                          tooltip: _isPlaying ? 'Pause' : 'Play',
                          iconSize: 38,
                          style: IconButton.styleFrom(
                            backgroundColor: green,
                            foregroundColor: Colors.black,
                            minimumSize: const Size(76, 76),
                          ),
                        ),
                        const IconButton(
                          onPressed: null,
                          icon: Icon(Icons.skip_next),
                          tooltip: 'Next unavailable',
                          iconSize: 36,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF242424),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Lyrics',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _openLyrics,
                            icon: const Icon(Icons.chevron_right, size: 18),
                            label: const Text('See full lyrics'),
                          ),
                        ],
                      ),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
