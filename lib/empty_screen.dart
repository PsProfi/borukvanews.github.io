import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';

// ─── Empty State Screen ──────────────────────────────────────────────────────

class EmptyScreen extends StatefulWidget {
  const EmptyScreen({super.key});

  @override
  State<EmptyScreen> createState() => _EmptyScreenState();
}

class _EmptyScreenState extends State<EmptyScreen> {
  final AudioPlayer _player = AudioPlayer();

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _playSound() async {
    try {
      // For asset sound
      await _player.play(AssetSource('sounds/puk-v-ekho.wav'));

      // OR for network sound
      // await _player.play(UrlSource('https://example.com/sound.mp3'));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Image.asset('assets/pictures/bg/backg.png', fit: BoxFit.cover),

          // Dark overlay for readability
          Container(color: Colors.black.withOpacity(0.35)),

          // Content
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Empty message
                Text(
                  'Тут нічого',
                  style: GoogleFonts.tapestry(
                    fontSize: 48,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'немає',
                  style: GoogleFonts.tapestry(
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                    letterSpacing: 4,
                  ),
                ),

                const SizedBox(height: 40),

                // Back button with sound
                OutlinedButton(
                  onPressed: () async {
                    await _playSound();
                    // Add your navigation logic here if needed
                    // context.go('/RULE34');
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white, width: 1.8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                    foregroundColor: Colors.white,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        "assets/pictures/hy.jpg",
                        width: 30,
                        height: 30,
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
