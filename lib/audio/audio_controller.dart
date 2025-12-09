import 'dart:async';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:logging/logging.dart';

class AudioController {
  static final Logger _log = Logger('AudioController');

  SoLoud? _soloud;

  SoundHandle? _musicHandle;

  bool isMuted = false;

  Future<void> initialize() async {
    _soloud = SoLoud.instance;
    await _soloud!.init();
  }

  void dispose() {
    _soloud?.deinit();
  }

  // SOUND EFFECTS
  Future<void> playSound(String assetKey) async {
    if (isMuted) return; // mute applies to sound FX too

    try {
      final source = await _soloud!.loadAsset(assetKey);
      await _soloud!.play(source);
    } on SoLoudException catch (e) {
      _log.severe("Cannot play sound '$assetKey'. Ignoring.", e);
    }
  }

  //  MUSIC PLAYBACK
  Future<void> startMusic() async {
    if (_musicHandle != null &&
        _soloud!.getIsValidVoiceHandle(_musicHandle!)) {
      // If already playing or paused then do nothing
      return;
    }

    final musicSource = await _soloud!.loadAsset(
      'assets/music/background-music.mp3',
      mode: LoadMode.disk,
    );

    musicSource.allInstancesFinished.first.then((_) {
      _soloud!.disposeSource(musicSource);
      _musicHandle = null;
    });

    _log.info('Playing music');
    _musicHandle = await _soloud!.play(
      musicSource,
      volume: 0.3,
      looping: true,
      loopingStartAt: const Duration(seconds: 25, milliseconds: 43),
    );
  }


  //  MUTE / UNMUTE
  Future<void> toggleMute() async {
    isMuted = !isMuted;

    if (_musicHandle == null) return; // nothing playing yet

    const fadeDuration = Duration(seconds: 1); // 1-second fade

    if (isMuted) {
      _log.info("Muting audio (fade out)");
      _soloud!.fadeVolume(_musicHandle!, 0, fadeDuration); // fade volume to 0
      _soloud!.schedulePause(_musicHandle!, fadeDuration); // pause after fade
    } else {
      _log.info("Unmuting audio (fade in)");

      // resume immediately at volume 0
      _soloud!.setVolume(_musicHandle!, 0);
      _soloud!.setPause(_musicHandle!, false);

      // fade volume up to normal
      _soloud!.fadeVolume(_musicHandle!, 0.3, fadeDuration);
    }
  }




  void fadeOutMusic() {
    if (_musicHandle == null) return;
    const length = Duration(seconds: 5);
    _soloud!.fadeVolume(_musicHandle!, 0, length);
    _soloud!.scheduleStop(_musicHandle!, length);
  }

  void applyFilter() {
    _soloud!.filters.echoFilter.activate();
    _soloud!.filters.echoFilter.wet.value = 0.3;
  }

  void removeFilter() {
    _soloud!.filters.echoFilter.deactivate();
  }
}
