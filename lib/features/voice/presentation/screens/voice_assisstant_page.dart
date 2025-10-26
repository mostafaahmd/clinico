import 'package:clinico/core/theming/app_colors.dart';
import 'package:clinico/core/voice/intents_engine.dart';
import 'package:clinico/core/voice/voice_assistant.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VoiceAssistantPage extends StatefulWidget {
  const VoiceAssistantPage({super.key});

  @override
  State<VoiceAssistantPage> createState() => _VoiceAssistantPageState();
}

class _VoiceAssistantPageState extends State<VoiceAssistantPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  final _va = VoiceAssistant();
  final _engine = IntentsEngine();

  bool _busy = false;
  String? _lastHeard;
  String? _lastReply;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(); // نبضات لا نهائية
    _va.init(ttsLang: 'ar-SA');
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _listen() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _lastHeard = null;
      _lastReply = null;
    });

    try {
      final heard = await _va.listenOnce(localeId: 'ar_SA');
      setState(() => _lastHeard = heard ?? '—');

      if (heard == null) {
        await _va.speak('مسمعتش كويس. حاول تاني.');
        setState(() => _lastReply = 'مسمعتش كويس. حاول تاني.');
      } else {
        final intent = _engine.parse(heard);
        final reply = await handleIntent(intent, GoRouter.of(context));
        setState(() => _lastReply = reply);
        await _va.speak(reply);
      }
    } catch (e) {
      final msg = 'Voice error: $e';
      setState(() => _lastReply = msg);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Voice Assistant'),
        backgroundColor: AppColors.bg,
        surfaceTintColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          children: [
            const SizedBox(height: 12),
            // دائرة المايك مع نبضات
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 240,
                  height: 240,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _PulseCircle(controller: _c, delay: 0.0),
                      _PulseCircle(controller: _c, delay: 0.33),
                      _PulseCircle(controller: _c, delay: 0.66),

                      // زرّ المايك
                      Material(
                        color: Colors.white,
                        elevation: 10,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: _busy ? null : _listen,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 92,
                            height: 92,
                            decoration: BoxDecoration(
                              color: _busy ? AppColors.primary : Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x1A000000),
                                  blurRadius: 16,
                                  offset: Offset(0, 8),
                                )
                              ],
                            ),
                            child: Icon(
                              _busy ? Icons.hearing : Icons.mic,
                              size: 34,
                              color: _busy ? Colors.white : AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // نص “استمعنا/الرد”
            if (_lastHeard != null || _lastReply != null) ...[
              const SizedBox(height: 8),
              _Bubble(
                title: 'You said',
                text: _lastHeard ?? '',
                alignStart: true,
                bg: Colors.white,
              ),
              const SizedBox(height: 10),
              _Bubble(
                title: 'Assistant',
                text: _lastReply ?? '',
                alignStart: false,
                bg: const Color(0xFFF2F6FF),
              ),
            ],

            const SizedBox(height: 16),
            // زر بديل تحت
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _busy ? null : _listen,
                icon: const Icon(Icons.mic),
                label: Text(_busy ? 'Listening…' : 'Tap to talk'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// دائرة نابضة بسيطة (سكيل + اوباسيتي)
class _PulseCircle extends StatelessWidget {
  const _PulseCircle({required this.controller, required this.delay});
  final AnimationController controller;
  final double delay;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: controller,
      curve: Interval(delay, 1.0, curve: Curves.easeOut),
    );

    return AnimatedBuilder(
      animation: curved,
      builder: (_, __) {
        final t = curved.value; // 0..1
        final scale = 1.0 + (t * 1.6); // يكبر
        final opacity = (1.0 - t).clamp(0.0, 1.0);
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.title,
    required this.text,
    required this.alignStart,
    required this.bg,
  });
  final String title;
  final String text;
  final bool alignStart;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    const txt = TextStyle(color: Color(0xFF475569));
    return Align(
      alignment: alignStart ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE9EEF9)),
        ),
        child: Column(
          crossAxisAlignment:
              alignStart ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
            const SizedBox(height: 4),
            Text(text, style: txt),
          ],
        ),
      ),
    );
  }
}
