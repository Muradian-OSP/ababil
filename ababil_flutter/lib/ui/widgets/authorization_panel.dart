import 'package:flutter/material.dart';
import 'package:ababil_flutter/domain/models/request_auth.dart';
import 'package:ababil_flutter/domain/models/request_variable.dart';

class AuthorizationPanel extends StatefulWidget {
  final RequestAuth? auth;
  final ValueChanged<RequestAuth?> onAuthChanged;

  const AuthorizationPanel({
    super.key,
    required this.auth,
    required this.onAuthChanged,
  });

  @override
  State<AuthorizationPanel> createState() => _AuthorizationPanelState();
}

class _AuthorizationPanelState extends State<AuthorizationPanel> {
  String? _selectedAuthType;
  final Map<String, Map<String, String>> _authFields = {};
  // Store controllers persistently to prevent cursor reset
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, VoidCallback> _controllerListeners = {};

  TextEditingController _getController(String key, String initialValue) {
    if (!_controllers.containsKey(key)) {
      final controller = TextEditingController(text: initialValue);
      final listener = () {
        final currentValue = controller.text;
        if (_authFields[key]?['value'] != currentValue) {
          _onFieldChanged(key, currentValue);
        }
      };
      controller.addListener(listener);
      _controllers[key] = controller;
      _controllerListeners[key] = listener;
    }
    return _controllers[key]!;
  }

  @override
  void initState() {
    super.initState();
    _selectedAuthType = widget.auth?.type ?? 'noauth';
    _loadAuthFields();
    _initializeControllers();
  }

  @override
  void didUpdateWidget(AuthorizationPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.auth != widget.auth ||
        oldWidget.auth?.type != widget.auth?.type) {
      _selectedAuthType = widget.auth?.type ?? 'noauth';
      _loadAuthFields();
      _updateControllers();
    }
  }

  @override
  void dispose() {
    // Remove listeners and dispose controllers
    for (var entry in _controllers.entries) {
      final listener = _controllerListeners[entry.key];
      if (listener != null) {
        entry.value.removeListener(listener);
      }
      entry.value.dispose();
    }
    _controllers.clear();
    _controllerListeners.clear();
    super.dispose();
  }

  void _initializeControllers() {
    for (var entry in _authFields.entries) {
      final key = entry.key;
      final value = entry.value['value'] ?? '';
      _getController(key, value);
    }
  }

  void _updateControllers() {
    // Update existing controllers and create new ones for new fields
    final currentKeys = _authFields.keys.toSet();
    final controllerKeys = _controllers.keys.toSet();

    // Remove controllers for fields that no longer exist
    for (var key in controllerKeys) {
      if (!currentKeys.contains(key)) {
        final listener = _controllerListeners[key];
        if (listener != null) {
          _controllers[key]?.removeListener(listener);
        }
        _controllers[key]?.dispose();
        _controllers.remove(key);
        _controllerListeners.remove(key);
      }
    }

    // Create controllers for new fields (don't update existing ones to preserve cursor)
    for (var entry in _authFields.entries) {
      final key = entry.key;
      final value = entry.value['value'] ?? '';
      if (!_controllers.containsKey(key)) {
        _getController(key, value);
      }
    }
  }

  void _loadAuthFields() {
    _authFields.clear();
    final auth = widget.auth;
    if (auth == null) return;

    switch (_selectedAuthType) {
      case 'bearer':
        if (auth.bearer != null) {
          for (final variable in auth.bearer!) {
            _authFields[variable.key] = {'value': variable.value};
          }
        }
        break;
      case 'basic':
        if (auth.basic != null) {
          for (final variable in auth.basic!) {
            _authFields[variable.key] = {'value': variable.value};
          }
        }
        break;
      case 'digest':
        if (auth.digest != null) {
          for (final variable in auth.digest!) {
            _authFields[variable.key] = {'value': variable.value};
          }
        }
        break;
      case 'awsv4':
        if (auth.awsv4 != null) {
          for (final variable in auth.awsv4!) {
            _authFields[variable.key] = {'value': variable.value};
          }
        }
        break;
      case 'hawk':
        if (auth.hawk != null) {
          for (final variable in auth.hawk!) {
            _authFields[variable.key] = {'value': variable.value};
          }
        }
        break;
      case 'oauth1':
        if (auth.oauth1 != null) {
          for (final variable in auth.oauth1!) {
            _authFields[variable.key] = {'value': variable.value};
          }
        }
        break;
      case 'oauth2':
        if (auth.oauth2 != null) {
          for (final variable in auth.oauth2!) {
            _authFields[variable.key] = {'value': variable.value};
          }
        }
        break;
      case 'ntlm':
        if (auth.ntlm != null) {
          for (final variable in auth.ntlm!) {
            _authFields[variable.key] = {'value': variable.value};
          }
        }
        break;
    }
  }

  void _onAuthTypeChanged(String? newType) {
    // Dispose old controllers
    for (var entry in _controllers.entries) {
      final listener = _controllerListeners[entry.key];
      if (listener != null) {
        entry.value.removeListener(listener);
      }
      entry.value.dispose();
    }
    _controllers.clear();
    _controllerListeners.clear();

    setState(() {
      _selectedAuthType = newType ?? 'noauth';
      _authFields.clear();
      _initializeAuthFields();
      _initializeControllers();
    });
    _notifyAuthChanged();
  }

  void _initializeAuthFields() {
    switch (_selectedAuthType) {
      case 'bearer':
        _authFields['Token'] = {'value': ''};
        break;
      case 'basic':
        _authFields['Username'] = {'value': ''};
        _authFields['Password'] = {'value': ''};
        break;
      case 'digest':
        _authFields['Username'] = {'value': ''};
        _authFields['Password'] = {'value': ''};
        _authFields['Realm'] = {'value': ''};
        _authFields['Nonce'] = {'value': ''};
        _authFields['Algorithm'] = {'value': 'MD5'};
        _authFields['Qop'] = {'value': ''};
        _authFields['Nonce Count'] = {'value': ''};
        _authFields['Client Nonce'] = {'value': ''};
        _authFields['Opaque'] = {'value': ''};
        break;
      case 'awsv4':
        _authFields['Access Key ID'] = {'value': ''};
        _authFields['Secret Access Key'] = {'value': ''};
        _authFields['AWS Region'] = {'value': ''};
        _authFields['Service Name'] = {'value': ''};
        break;
      case 'hawk':
        _authFields['Hawk Auth ID'] = {'value': ''};
        _authFields['Hawk Auth Key'] = {'value': ''};
        _authFields['Algorithm'] = {'value': 'sha256'};
        break;
      case 'oauth1':
        _authFields['Consumer Key'] = {'value': ''};
        _authFields['Consumer Secret'] = {'value': ''};
        _authFields['Token'] = {'value': ''};
        _authFields['Token Secret'] = {'value': ''};
        _authFields['Signature Method'] = {'value': 'HMAC-SHA1'};
        _authFields['Timestamp'] = {'value': ''};
        _authFields['Nonce'] = {'value': ''};
        _authFields['Version'] = {'value': '1.0'};
        _authFields['Realm'] = {'value': ''};
        break;
      case 'oauth2':
        _authFields['Grant Type'] = {'value': 'authorization_code'};
        _authFields['Access Token URL'] = {'value': ''};
        _authFields['Client ID'] = {'value': ''};
        _authFields['Client Secret'] = {'value': ''};
        _authFields['Scope'] = {'value': ''};
        _authFields['Client Authentication'] = {'value': 'header'};
        _authFields['Access Token'] = {'value': ''};
        break;
      case 'ntlm':
        _authFields['Username'] = {'value': ''};
        _authFields['Password'] = {'value': ''};
        _authFields['Domain'] = {'value': ''};
        _authFields['Workstation'] = {'value': ''};
        break;
    }
  }

  void _onFieldChanged(String key, String value) {
    setState(() {
      _authFields[key] = {'value': value};
    });
    _notifyAuthChanged();
  }

  void _notifyAuthChanged() {
    RequestAuth? newAuth;

    if (_selectedAuthType == 'noauth') {
      newAuth = RequestAuth(type: 'noauth', noauth: {});
    } else {
      final variables = _authFields.entries
          .where((e) => e.value['value']?.isNotEmpty ?? false)
          .map(
            (e) => RequestVariable(key: e.key, value: e.value['value'] ?? ''),
          )
          .toList();

      if (variables.isEmpty) {
        newAuth = null;
      } else {
        switch (_selectedAuthType) {
          case 'bearer':
            newAuth = RequestAuth(type: 'bearer', bearer: variables);
            break;
          case 'basic':
            newAuth = RequestAuth(type: 'basic', basic: variables);
            break;
          case 'digest':
            newAuth = RequestAuth(type: 'digest', digest: variables);
            break;
          case 'awsv4':
            newAuth = RequestAuth(type: 'awsv4', awsv4: variables);
            break;
          case 'hawk':
            newAuth = RequestAuth(type: 'hawk', hawk: variables);
            break;
          case 'oauth1':
            newAuth = RequestAuth(type: 'oauth1', oauth1: variables);
            break;
          case 'oauth2':
            newAuth = RequestAuth(type: 'oauth2', oauth2: variables);
            break;
          case 'ntlm':
            newAuth = RequestAuth(type: 'ntlm', ntlm: variables);
            break;
          default:
            newAuth = null;
        }
      }
    }

    widget.onAuthChanged(newAuth);
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF3D3D3D)
        : Colors.grey.shade300;

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Authorization',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
              ),
            ],
          ),
        ),
        // Auth type selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: DropdownButtonFormField<String>(
            value: _selectedAuthType,
            decoration: InputDecoration(
              labelText: 'Type',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: borderColor),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'noauth', child: Text('No Auth')),
              DropdownMenuItem(value: 'bearer', child: Text('Bearer Token')),
              DropdownMenuItem(value: 'basic', child: Text('Basic Auth')),
              DropdownMenuItem(value: 'digest', child: Text('Digest Auth')),
              DropdownMenuItem(value: 'awsv4', child: Text('AWS Signature')),
              DropdownMenuItem(
                value: 'hawk',
                child: Text('Hawk Authentication'),
              ),
              DropdownMenuItem(value: 'oauth1', child: Text('OAuth 1.0')),
              DropdownMenuItem(value: 'oauth2', child: Text('OAuth 2.0')),
              DropdownMenuItem(
                value: 'ntlm',
                child: Text('NTLM Authentication'),
              ),
            ],
            onChanged: _onAuthTypeChanged,
          ),
        ),
        // Auth fields
        if (_selectedAuthType != 'noauth')
          Expanded(
            child: SingleChildScrollView(
              child: Table(
                border: TableBorder(
                  horizontalInside: BorderSide(color: borderColor, width: 1),
                  verticalInside: BorderSide(color: borderColor, width: 1),
                  bottom: BorderSide(color: borderColor, width: 1),
                ),
                columnWidths: const {
                  0: FlexColumnWidth(2), // Key column
                  1: FlexColumnWidth(3), // Value column
                },
                children: [
                  // Table header row
                  TableRow(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                    ),
                    children: [
                      _TableCell(
                        borderColor: borderColor,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'Key',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                context,
                              ).textTheme.bodySmall?.color,
                            ),
                          ),
                        ),
                      ),
                      _TableCell(
                        borderColor: borderColor,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'Value',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                context,
                              ).textTheme.bodySmall?.color,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Data rows
                  ..._authFields.entries.map((entry) {
                    return _buildAuthFieldRow(
                      context: context,
                      borderColor: borderColor,
                      key: entry.key,
                      value: entry.value['value'] ?? '',
                      onChanged: (value) => _onFieldChanged(entry.key, value),
                    );
                  }),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_open,
                    size: 48,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No authorization required',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  TableRow _buildAuthFieldRow({
    required BuildContext context,
    required Color borderColor,
    required String key,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    // Get persistent controller (already created in _initializeControllers or _updateControllers)
    final controller = _controllers[key] ?? _getController(key, value);

    return TableRow(
      children: [
        _TableCell(
          borderColor: borderColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Text(
              key,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ),
        ),
        _TableCell(
          borderColor: borderColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextField(
              controller: controller,
              style: const TextStyle(fontSize: 13),
              obscureText:
                  key.toLowerCase().contains('password') ||
                  key.toLowerCase().contains('secret') ||
                  key.toLowerCase().contains('key'),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter ${key.toLowerCase()}',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                isDense: true,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TableCell extends StatelessWidget {
  final Widget child;
  final Color borderColor;

  const _TableCell({required this.child, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: child,
    );
  }
}
