import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NameTypingDialog extends StatefulWidget {
  final String initialName;
  const NameTypingDialog({super.key, required this.initialName});

  @override
  State<NameTypingDialog> createState() => _NameTypingDialogState();
}

class _NameTypingDialogState extends State<NameTypingDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialName;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(t.editName),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: t.enterName,
              border: const OutlineInputBorder(),
            ),
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, _controller.text);
                },
                child: Text(t.done),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
