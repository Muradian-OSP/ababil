import 'package:flutter/material.dart';

class ParamsPanel extends StatefulWidget {
  final Map<String, String> params;
  final Set<String> disabledParams;
  final VoidCallback onAddParam;
  final ValueChanged<String> onRemoveParam;
  final ValueChanged<MapEntry<String, String>> onParamChanged;
  final ValueChanged<String> onToggleParamEnabled;

  const ParamsPanel({
    super.key,
    required this.params,
    required this.disabledParams,
    required this.onAddParam,
    required this.onRemoveParam,
    required this.onParamChanged,
    required this.onToggleParamEnabled,
  });

  @override
  State<ParamsPanel> createState() => _ParamsPanelState();
}

class _ParamsPanelState extends State<ParamsPanel> {
  // Store ValueNotifiers for each row to persist state across rebuilds
  final Map<String, ValueNotifier<String>> _keyNotifiers = {};
  final Map<String, ValueNotifier<String>> _valueNotifiers = {};

  ValueNotifier<String> _getKeyNotifier(String rowId) {
    return _keyNotifiers.putIfAbsent(rowId, () => ValueNotifier<String>(''));
  }

  ValueNotifier<String> _getValueNotifier(String rowId) {
    return _valueNotifiers.putIfAbsent(rowId, () => ValueNotifier<String>(''));
  }

  @override
  void dispose() {
    for (var notifier in _keyNotifiers.values) {
      notifier.dispose();
    }
    for (var notifier in _valueNotifiers.values) {
      notifier.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF3D3D3D)
        : Colors.grey.shade300;

    // Update notifiers with current values
    for (var entry in widget.params.entries) {
      final keyNotifier = _getKeyNotifier(entry.key);
      final valueNotifier = _getValueNotifier(entry.key);
      if (keyNotifier.value != entry.key) keyNotifier.value = entry.key;
      if (valueNotifier.value != entry.value) valueNotifier.value = entry.value;
    }

    return Column(
      children: [
        // Header with actions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Query Params',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Bulk Edit',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: 'Presets',
                    items: const [
                      DropdownMenuItem(
                        value: 'Presets',
                        child: Text('Presets'),
                      ),
                    ],
                    onChanged: (_) {},
                    underline: Container(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Table
        Expanded(
          child: SingleChildScrollView(
            child: Table(
              border: TableBorder(
                horizontalInside: BorderSide(color: borderColor, width: 1),
                verticalInside: BorderSide(color: borderColor, width: 1),
                bottom: BorderSide(color: borderColor, width: 1),
              ),
              columnWidths: const {
                0: FixedColumnWidth(32), // Checkbox column
                1: FlexColumnWidth(2), // Key column
                2: FlexColumnWidth(2), // Value column
                3: FlexColumnWidth(1), // Description column
                4: FixedColumnWidth(40), // Delete button column
              },
              children: [
                // Table header row
                TableRow(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                  ),
                  children: [
                    _TableCell(borderColor: borderColor, child: Container()),
                    _TableCell(
                      borderColor: borderColor,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Key',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodySmall?.color,
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
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ),
                    ),
                    _TableCell(
                      borderColor: borderColor,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ),
                    ),
                    _TableCell(borderColor: borderColor, child: Container()),
                  ],
                ),
                // Data rows
                ...widget.params.entries.map((entry) {
                  final isEnabled = !widget.disabledParams.contains(entry.key);
                  return _buildTableRow(
                    context: context,
                    borderColor: borderColor,
                    rowId: entry.key,
                    paramKey: entry.key,
                    paramValue: entry.value,
                    isNewRow: false,
                    isEnabled: isEnabled,
                    onChanged: (newEntry) {
                      final key = newEntry.$1;
                      final value = newEntry.$2;
                      if (key.isEmpty && value.isEmpty) {
                        widget.onRemoveParam(entry.key);
                      } else if (key != entry.key || value != entry.value) {
                        widget.onRemoveParam(entry.key);
                        if (key.isNotEmpty && value.isNotEmpty) {
                          widget.onParamChanged(MapEntry(key, value));
                        }
                      }
                    },
                    onRemove: () => widget.onRemoveParam(entry.key),
                    onToggleEnabled: () =>
                        widget.onToggleParamEnabled(entry.key),
                  );
                }),
                // Empty row for adding new param
                _buildTableRow(
                  context: context,
                  borderColor: borderColor,
                  rowId: '__empty__',
                  paramKey: '',
                  paramValue: '',
                  isNewRow: true,
                  isEnabled: false,
                  onChanged: (entry) {
                    if (entry.$1.isNotEmpty && entry.$2.isNotEmpty) {
                      widget.onParamChanged(MapEntry(entry.$1, entry.$2));
                      // Clear the empty row notifiers after adding
                      final emptyKeyNotifier = _getKeyNotifier('__empty__');
                      final emptyValueNotifier = _getValueNotifier('__empty__');
                      Future.microtask(() {
                        emptyKeyNotifier.value = '';
                        emptyValueNotifier.value = '';
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  TableRow _buildTableRow({
    required BuildContext context,
    required Color borderColor,
    required String rowId,
    required String paramKey,
    required String paramValue,
    required bool isNewRow,
    required bool isEnabled,
    required ValueChanged<(String, String)> onChanged,
    VoidCallback? onRemove,
    VoidCallback? onToggleEnabled,
  }) {
    final keyNotifier = _getKeyNotifier(rowId);
    final valueNotifier = _getValueNotifier(rowId);

    // For empty rows, always reset to empty
    if (isNewRow) {
      keyNotifier.value = '';
      valueNotifier.value = '';
    } else {
      // Update notifiers if values changed from outside
      if (keyNotifier.value != paramKey) keyNotifier.value = paramKey;
      if (valueNotifier.value != paramValue) valueNotifier.value = paramValue;
    }

    return TableRow(
      children: [
        _TableCell(
          borderColor: borderColor,
          child: _ParamRowWidget(
            rowId: rowId,
            paramKey: paramKey,
            paramValue: paramValue,
            isNewRow: isNewRow,
            isEnabled: isEnabled,
            onChanged: onChanged,
            onRemove: onRemove,
            onToggleEnabled: onToggleEnabled,
            borderColor: borderColor,
            columnIndex: 0,
            keyNotifier: keyNotifier,
            valueNotifier: valueNotifier,
          ),
        ),
        _TableCell(
          borderColor: borderColor,
          child: _ParamRowWidget(
            rowId: rowId,
            paramKey: paramKey,
            paramValue: paramValue,
            isNewRow: isNewRow,
            isEnabled: isEnabled,
            onChanged: onChanged,
            onRemove: onRemove,
            onToggleEnabled: onToggleEnabled,
            borderColor: borderColor,
            columnIndex: 1,
            keyNotifier: keyNotifier,
            valueNotifier: valueNotifier,
          ),
        ),
        _TableCell(
          borderColor: borderColor,
          child: _ParamRowWidget(
            rowId: rowId,
            paramKey: paramKey,
            paramValue: paramValue,
            isNewRow: isNewRow,
            isEnabled: isEnabled,
            onChanged: onChanged,
            onRemove: onRemove,
            onToggleEnabled: onToggleEnabled,
            borderColor: borderColor,
            columnIndex: 2,
            keyNotifier: keyNotifier,
            valueNotifier: valueNotifier,
          ),
        ),
        _TableCell(
          borderColor: borderColor,
          child: _ParamRowWidget(
            rowId: rowId,
            paramKey: paramKey,
            paramValue: paramValue,
            isNewRow: isNewRow,
            isEnabled: isEnabled,
            onChanged: onChanged,
            onRemove: onRemove,
            onToggleEnabled: onToggleEnabled,
            borderColor: borderColor,
            columnIndex: 3,
            keyNotifier: keyNotifier,
            valueNotifier: valueNotifier,
          ),
        ),
        _TableCell(
          borderColor: borderColor,
          child: _ParamRowWidget(
            rowId: rowId,
            paramKey: paramKey,
            paramValue: paramValue,
            isNewRow: isNewRow,
            isEnabled: isEnabled,
            onChanged: onChanged,
            onRemove: onRemove,
            onToggleEnabled: onToggleEnabled,
            borderColor: borderColor,
            columnIndex: 4,
            keyNotifier: keyNotifier,
            valueNotifier: valueNotifier,
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

// Shared state widget for an entire param row
// Uses ValueNotifiers to share state across all cells in the row
class _ParamRowWidget extends StatefulWidget {
  final String rowId;
  final String paramKey;
  final String paramValue;
  final bool isNewRow;
  final bool isEnabled;
  final ValueChanged<(String, String)> onChanged;
  final VoidCallback? onRemove;
  final VoidCallback? onToggleEnabled;
  final Color borderColor;
  final int columnIndex; // 0=checkbox, 1=key, 2=value, 3=description, 4=delete
  final ValueNotifier<String> keyNotifier;
  final ValueNotifier<String> valueNotifier;

  const _ParamRowWidget({
    required this.rowId,
    required this.paramKey,
    required this.paramValue,
    required this.isNewRow,
    required this.isEnabled,
    required this.onChanged,
    this.onRemove,
    this.onToggleEnabled,
    required this.borderColor,
    required this.columnIndex,
    required this.keyNotifier,
    required this.valueNotifier,
  });

  @override
  State<_ParamRowWidget> createState() => _ParamRowWidgetState();
}

class _ParamRowWidgetState extends State<_ParamRowWidget> {
  late TextEditingController _keyController;
  late TextEditingController _valueController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _keyController = TextEditingController(text: widget.paramKey);
    _valueController = TextEditingController(text: widget.paramValue);
    _descController = TextEditingController();
    // Sync controllers with notifiers
    widget.keyNotifier.addListener(_onKeyNotifierChanged);
    widget.valueNotifier.addListener(_onValueNotifierChanged);
  }

  @override
  void didUpdateWidget(_ParamRowWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.keyNotifier != widget.keyNotifier) {
      oldWidget.keyNotifier.removeListener(_onKeyNotifierChanged);
      widget.keyNotifier.addListener(_onKeyNotifierChanged);
    }
    if (oldWidget.valueNotifier != widget.valueNotifier) {
      oldWidget.valueNotifier.removeListener(_onValueNotifierChanged);
      widget.valueNotifier.addListener(_onValueNotifierChanged);
    }
    // Update controllers if values changed from outside
    if (_keyController.text != widget.keyNotifier.value) {
      _keyController.text = widget.keyNotifier.value;
    }
    if (_valueController.text != widget.valueNotifier.value) {
      _valueController.text = widget.valueNotifier.value;
    }
  }

  void _onKeyNotifierChanged() {
    if (_keyController.text != widget.keyNotifier.value) {
      _keyController.text = widget.keyNotifier.value;
    }
  }

  void _onValueNotifierChanged() {
    if (_valueController.text != widget.valueNotifier.value) {
      _valueController.text = widget.valueNotifier.value;
    }
  }

  @override
  void dispose() {
    widget.keyNotifier.removeListener(_onKeyNotifierChanged);
    widget.valueNotifier.removeListener(_onValueNotifierChanged);
    _keyController.dispose();
    _valueController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _notifyChange() {
    final key = _keyController.text;
    final value = _valueController.text;
    widget.keyNotifier.value = key;
    widget.valueNotifier.value = value;
    widget.onChanged((key, value));
  }

  @override
  Widget build(BuildContext context) {
    final isDimmed =
        widget.isNewRow &&
        _keyController.text.isEmpty &&
        _valueController.text.isEmpty;

    switch (widget.columnIndex) {
      case 0: // Checkbox column
        return ValueListenableBuilder<String>(
          valueListenable: widget.keyNotifier,
          builder: (context, keyValue, _) {
            return ValueListenableBuilder<String>(
              valueListenable: widget.valueNotifier,
              builder: (context, valueValue, _) {
                final hasContent = keyValue.isNotEmpty && valueValue.isNotEmpty;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: hasContent
                      ? Checkbox(
                          value: widget.isEnabled,
                          onChanged: widget.onToggleEnabled != null
                              ? (_) => widget.onToggleEnabled?.call()
                              : widget.isNewRow
                              ? null
                              : (_) => widget.onToggleEnabled?.call(),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        )
                      : const SizedBox.shrink(),
                );
              },
            );
          },
        );
      case 1: // Key column
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: TextField(
            controller: _keyController,
            style: TextStyle(
              fontSize: 13,
              color: isDimmed
                  ? Theme.of(context).textTheme.bodySmall?.color
                  : (!widget.isEnabled && !widget.isNewRow)
                  ? Theme.of(context).textTheme.bodySmall?.color
                  : null,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              filled: false,
              hintText: 'Key',
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
            onChanged: (value) {
              widget.keyNotifier.value = value;
              setState(() {}); // Update checkbox visibility
              _notifyChange();
            },
          ),
        );
      case 2: // Value column
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: TextField(
            controller: _valueController,
            style: TextStyle(
              fontSize: 13,
              color: isDimmed
                  ? Theme.of(context).textTheme.bodySmall?.color
                  : (!widget.isEnabled && !widget.isNewRow)
                  ? Theme.of(context).textTheme.bodySmall?.color
                  : null,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              filled: false,
              hintText: 'Value',
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
            onChanged: (value) {
              widget.valueNotifier.value = value;
              setState(() {}); // Update checkbox visibility
              _notifyChange();
            },
          ),
        );
      case 3: // Description column
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: TextField(
            controller: _descController,
            style: TextStyle(
              fontSize: 13,
              color: isDimmed
                  ? Theme.of(context).textTheme.bodySmall?.color
                  : (!widget.isEnabled && !widget.isNewRow)
                  ? Theme.of(context).textTheme.bodySmall?.color
                  : null,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              filled: false,
              hintText: 'Description',
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
        );
      case 4: // Delete button column
        return widget.onRemove != null
            ? IconButton(
                icon: const Icon(Icons.close, size: 16),
                onPressed: widget.onRemove,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: Theme.of(context).textTheme.bodySmall?.color,
              )
            : const SizedBox(width: 40);
      default:
        return const SizedBox.shrink();
    }
  }
}
