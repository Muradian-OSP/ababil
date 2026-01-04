import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/highlight.dart' as highlight;
import 'package:highlight/languages/json.dart';
import 'package:highlight/languages/xml.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:highlight/languages/css.dart';
import 'package:highlight/languages/yaml.dart';

class CustomCodeEditor extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? language;

  const CustomCodeEditor({
    super.key,
    required this.controller,
    this.hintText,
    this.language,
  });

  @override
  State<CustomCodeEditor> createState() => _CustomCodeEditorState();
}

class _CustomCodeEditorState extends State<CustomCodeEditor> {
  late CodeController _codeController;
  String _currentLanguage = 'json';
  bool _isUpdatingFromExternal = false;
  bool _isUpdatingFromCode = false;

  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.language ?? 'json';
    _codeController = CodeController(
      text: widget.controller.text,
      language: _getLanguage(_currentLanguage),
    );

    // Sync with external controller
    widget.controller.addListener(_onExternalControllerChanged);
    _codeController.addListener(_onCodeControllerChanged);
  }

  @override
  void didUpdateWidget(CustomCodeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.language != widget.language) {
      _currentLanguage = widget.language ?? 'json';
      _codeController.language = _getLanguage(_currentLanguage);
    }
    if (oldWidget.controller.text != widget.controller.text &&
        _codeController.text != widget.controller.text &&
        !_isUpdatingFromCode) {
      _isUpdatingFromExternal = true;
      _codeController.text = widget.controller.text;
      _isUpdatingFromExternal = false;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onExternalControllerChanged);
    _codeController.removeListener(_onCodeControllerChanged);
    _codeController.dispose();
    super.dispose();
  }

  void _onExternalControllerChanged() {
    if (_isUpdatingFromCode) return;

    if (_codeController.text != widget.controller.text) {
      _isUpdatingFromExternal = true;
      _codeController.text = widget.controller.text;
      _isUpdatingFromExternal = false;
    }
  }

  void _onCodeControllerChanged() {
    if (_isUpdatingFromExternal) return;

    if (widget.controller.text != _codeController.text) {
      _isUpdatingFromCode = true;
      widget.controller.text = _codeController.text;
      _isUpdatingFromCode = false;
    }
  }

  highlight.Mode _getLanguage(String language) {
    switch (language.toLowerCase()) {
      case 'json':
        return json;
      case 'xml':
        return xml;
      case 'html':
        return xml; // HTML uses XML highlighting
      case 'javascript':
      case 'js':
        return javascript;
      case 'css':
        return css;
      case 'yaml':
      case 'yml':
        return yaml;
      default:
        return json;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CodeTheme(
      data: CodeThemeData(styles: monokaiSublimeTheme),
      child: SizedBox.expand(
        child: SingleChildScrollView(
          child: CodeField(
            controller: _codeController,
            textStyle: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          ),
        ),
      ),
    );
  }
}
