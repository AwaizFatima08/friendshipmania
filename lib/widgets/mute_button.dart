import 'package:flutter/material.dart';

import '../services/app_services.dart';

/// A speaker toggle for the app bar. Renders nothing until the app actually
/// ships audio, so builds without sound assets don't show a dead button.
class MuteButton extends StatelessWidget {
  const MuteButton({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = AppServices.of(context).audio;
    if (!audio.hasAudio) return const SizedBox.shrink();

    return ValueListenableBuilder<bool>(
      valueListenable: audio.mutedListenable,
      builder: (context, muted, _) => IconButton(
        tooltip: muted ? 'Turn sound on' : 'Mute sound',
        icon: Icon(muted ? Icons.volume_off_rounded : Icons.volume_up_rounded),
        onPressed: () => audio.setMuted(!muted),
      ),
    );
  }
}
