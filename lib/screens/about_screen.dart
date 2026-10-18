import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../config.dart';
import '../services/app_services.dart';
import '../utils/open_url.dart';
import '../widgets/cropped_art.dart';
import '../widgets/gradient_page.dart';
import '../widgets/mute_button.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<String> _version() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return 'v${info.version} (${info.buildNumber})';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final white = Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: Colors.white.withValues(alpha: 0.95),
    );

    return GradientPage(
      appBar: AppBar(
        title: const Text('About & credits ✨'),
        actions: const [MuteButton()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Center(
            child: CroppedArt(
              asset: mascotAsset,
              height: 130,
              semanticLabel: 'friendshipmania detective mascot',
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'friendshipmania',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: Colors.white),
            ),
          ),
          Center(
            child: FutureBuilder<String>(
              future: _version(),
              builder: (context, snap) => Text(snap.data ?? '', style: white),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'A lie detector for your friendships. Totally unscientific, '
            'deeply accurate, legally unqualified. Made with chaos by HomiLabs.',
            textAlign: TextAlign.center,
            style: white,
          ),
          const SizedBox(height: 24),
          _LinkTile(
            icon: Icons.privacy_tip_rounded,
            label: 'Privacy policy',
            onTap: () => openUrl(context, privacyUrl),
          ),
          _LinkTile(
            icon: Icons.gavel_rounded,
            label: 'Terms of use',
            onTap: () => openUrl(context, termsUrl),
          ),
          // GDPR: users in the EEA/UK must be able to change their ad
          // consent at any time. Shown only where Google's UMP requires it.
          FutureBuilder<bool>(
            future: AppServices.of(context).ads.privacyOptionsRequired(),
            builder: (context, snap) => snap.data == true
                ? _LinkTile(
                    icon: Icons.tune_rounded,
                    label: 'Privacy & ad choices',
                    external: false,
                    onTap: () =>
                        AppServices.of(context).ads.showPrivacyOptions(),
                  )
                : const SizedBox.shrink(),
          ),
          _LinkTile(
            icon: Icons.delete_forever_rounded,
            label: 'Delete my account & data',
            onTap: () => openUrl(context, deleteAccountUrl),
          ),
          _LinkTile(
            icon: Icons.mail_rounded,
            label: 'Contact support',
            onTap: () => openUrl(
              context,
              'mailto:$supportEmail?subject=friendshipmania',
            ),
          ),
          if (attributionLines.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Credits',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            for (final line in attributionLines)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $line', style: white),
              ),
          ],
        ],
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.external = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// Opens a web page / mail app (shows the "leaves the app" icon).
  final bool external;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: Colors.white,
        child: ListTile(
          leading: Icon(icon, color: const Color(0xFF5636C4)),
          title: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          trailing: Icon(
            external ? Icons.open_in_new_rounded : Icons.chevron_right_rounded,
            size: external ? 18 : 24,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
