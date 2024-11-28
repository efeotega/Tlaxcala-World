import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageSelectorWidget extends StatefulWidget {
  @override
  _LanguageSelectorWidgetState createState() => _LanguageSelectorWidgetState();
}

class _LanguageSelectorWidgetState extends State<LanguageSelectorWidget> {
  String _selectedLanguage = 'en'; // Default to English

  void _changeLanguage(String languageCode) {
    setState(() {
      _selectedLanguage = languageCode;
    });
    context.setLocale(Locale(languageCode));
    setState((){});
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RadioListTile<String>(
              value: 'en',
              groupValue: _selectedLanguage,
              title: Text('English'),
              onChanged: (value) => _changeLanguage(value!),
            ),
            const SizedBox(width:10),
            RadioListTile<String>(
              value: 'es',
              groupValue: _selectedLanguage,
              title: Text('Español'),
              onChanged: (value) => _changeLanguage(value!),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(tr('Done')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
