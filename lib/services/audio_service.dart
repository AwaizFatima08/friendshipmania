import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Short UI sounds. The file for each lives in `assets/audio/sfx/`.
enum Sfx {
  tap('audio/sfx/tap.ogg'),
  answer('audio/sfx/answer.ogg'),
  reveal('audio/sfx/reveal.ogg');

  const Sfx(this.assetPath);

  /// Path relative to `assets/`, as `AssetSource` expects.
  final String assetPath;
}

const String musicAssetPath = 'audio/music/loop.ogg';

abstract class AudioService {
  /// True once any audio file is actually bundled with the app. Until then
  /// every method is a no-op and the mute button stays hidden.
  bool get hasAudio;

  ValueListenable<bool> get mutedListenable;

  Future<void> startMusic();
  Future<void> stopMusic();
  Future<void> playSfx(Sfx sfx);
  Future<void> setMuted(bool muted);
}

/// Does nothing — used in tests and as the safe fallback.
class NoopAudioService implements AudioService {
  final ValueNotifier<bool> _muted = ValueNotifier(false);

  @override
  bool get hasAudio => false;

  @override
  ValueListenable<bool> get mutedListenable => _muted;

  @override
  Future<void> startMusic() async {}

  @override
  Future<void> stopMusic() async {}

  @override
  Future<void> playSfx(Sfx sfx) async {}

  @override
  Future<void> setMuted(bool muted) async => _muted.value = muted;
}

/// Plays a quiet looping background track and short sound effects.
///
/// Design choices worth knowing:
///  * Audio mixes with whatever else the phone is playing (no audio-focus
///    grab) — plenty of people have their own music on while using the app.
///  * Music pauses when the app goes to the background and resumes after.
///  * Mute is remembered between launches.
///  * Any playback failure disables audio for the session instead of
///    surfacing an error: sound is decoration, never a reason to crash.
class AppAudioService with WidgetsBindingObserver implements AudioService {
  AppAudioService();

  static const _mutedKey = 'audio_muted';
  static const double _musicVolume = 0.3;

  final ValueNotifier<bool> _muted = ValueNotifier(false);
  final AudioPlayer _music = AudioPlayer();
  final Map<Sfx, AudioPlayer> _sfxPlayers = {};

  bool _hasAudio = false;
  bool _broken = false;
  bool _musicWanted = false;

  @override
  bool get hasAudio => _hasAudio && !_broken;

  @override
  ValueListenable<bool> get mutedListenable => _muted;

  Future<void> init() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      _hasAudio =
          manifest.listAssets().any((a) => a.startsWith('assets/audio/'));
      if (!_hasAudio) return;

      final prefs = await SharedPreferences.getInstance();
      _muted.value = prefs.getBool(_mutedKey) ?? false;

      await AudioPlayer.global.setAudioContext(
        AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers).build(),
      );
      await _music.setReleaseMode(ReleaseMode.loop);
      await _music.setVolume(_musicVolume);
      WidgetsBinding.instance.addObserver(this);
    } catch (_) {
      _broken = true;
    }
  }

  @override
  Future<void> startMusic() async {
    _musicWanted = true;
    if (!hasAudio || _muted.value) return;
    try {
      if (_music.state != PlayerState.playing) {
        await _music.play(AssetSource(musicAssetPath));
      }
    } catch (_) {
      _broken = true;
    }
  }

  @override
  Future<void> stopMusic() async {
    _musicWanted = false;
    try {
      await _music.stop();
    } catch (_) {}
  }

  @override
  Future<void> playSfx(Sfx sfx) async {
    if (!hasAudio || _muted.value) return;
    try {
      final player = _sfxPlayers.putIfAbsent(
        sfx,
        () => AudioPlayer()..setPlayerMode(PlayerMode.lowLatency),
      );
      await player.stop();
      await player.play(AssetSource(sfx.assetPath), volume: 0.8);
    } catch (_) {
      // A missing/undecodable effect just stays silent.
    }
  }

  @override
  Future<void> setMuted(bool muted) async {
    _muted.value = muted;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_mutedKey, muted);
    } catch (_) {}
    if (muted) {
      try {
        await _music.pause();
      } catch (_) {}
    } else if (_musicWanted) {
      await startMusic();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!hasAudio) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _music.pause().catchError((_) {});
    } else if (state == AppLifecycleState.resumed &&
        _musicWanted &&
        !_muted.value) {
      _music.resume().catchError((_) {});
    }
  }
}
