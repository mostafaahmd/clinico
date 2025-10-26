import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'voice_assistant.dart';
import 'intents_engine.dart';

class VoiceButton extends StatefulWidget {
  const VoiceButton({super.key, this.localeId = 'ar_SA'});
  final String localeId;

  @override
  State<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends State<VoiceButton> {
  final _va = VoiceAssistant();
  final _engine = IntentsEngine();
  bool _busy = false;

  Future<void> _action() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final text = await _va.listenOnce(localeId: widget.localeId);
      if (text == null) {
        await _va.speak('مسمعتش كويس. كرر لو سمحت.');
        return;
      }
      final intent = _engine.parse(text);
      final reply = await handleIntent(intent, GoRouter.of(context));
      await _va.speak(reply);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Voice error: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: _action,
      label: Text(_busy ? 'Listening…' : 'Talk'),
      icon: Icon(_busy ? Icons.hearing : Icons.mic),
    );
  }
}
