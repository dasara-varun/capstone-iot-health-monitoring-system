import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../state/app_state.dart';

class LoginDialog extends StatefulWidget {
  final AppState state;

  const LoginDialog({super.key, required this.state});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final _usernameController = TextEditingController(text: 'operator');
  final _passwordController = TextEditingController(text: 'operator123');
  bool _isLoading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
      contentPadding: const EdgeInsets.fromLTRB(28, 16, 28, 8),
      actionsPadding: const EdgeInsets.fromLTRB(28, 8, 28, 20),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PLATFORM ACCESS',
            style: GoogleFonts.ibmPlexMono(fontSize: 11, letterSpacing: 1.8, color: AppTheme.accent),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in',
            style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w500, fontSize: 28, color: AppTheme.foreground),
          ),
        ],
      ),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Credentials unlock device configuration and the test fixture harness. Viewers remain read-only.',
              style: GoogleFonts.sourceSans3(fontSize: 14, height: 1.6, color: AppTheme.mutedForeground),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: GoogleFonts.sourceSans3(color: AppTheme.review, fontSize: 13)),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () {
                    _usernameController.text = 'operator';
                    _passwordController.text = 'operator123';
                  },
                  child: const Text('Fill operator'),
                ),
                OutlinedButton(
                  onPressed: () {
                    _usernameController.text = 'viewer';
                    _passwordController.text = 'viewer123';
                  },
                  child: const Text('Fill viewer'),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : () async {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  final ok = await widget.state.login(
                    _usernameController.text.trim(),
                    _passwordController.text.trim(),
                  );
                  setState(() => _isLoading = false);
                  if (ok && mounted) {
                    Navigator.of(context).pop();
                  } else {
                    setState(() => _error = 'Invalid credentials. Try operator / operator123.');
                  }
                },
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text('Sign in'),
        ),
      ],
    );
  }
}
