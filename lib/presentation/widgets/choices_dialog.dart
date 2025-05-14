import 'package:flutter/material.dart';

class ChoicesDialog<T> extends StatefulWidget {
  const ChoicesDialog({
    super.key,
    required this.title,
    required this.valueLabelMapper,
    this.description,
    this.initialValue,
    this.toggleable = false,
  }) : hasMultipleChoices = false,
       initialValues = null;

  const ChoicesDialog.multi({
    super.key,
    required this.title,
    required this.valueLabelMapper,
    this.description,
    this.initialValues,
  }) : hasMultipleChoices = true,
       initialValue = null,
       toggleable = false;

  final String title;
  final String? description;
  final Map<T, Widget> valueLabelMapper;
  final bool hasMultipleChoices;
  final List<T>? initialValues;
  final T? initialValue;
  final bool toggleable;

  /// If using single value, it will return a list with this unique value.
  Future<List<T>?> show(BuildContext context) =>
      showDialog<List<T>>(context: context, builder: (context) => this);

  @override
  State<ChoicesDialog<T>> createState() => _ChoicesDialogState<T>();
}

class _ChoicesDialogState<T> extends State<ChoicesDialog<T>> {
  late List<T> multiValues;
  late T? value;

  @override
  void initState() {
    super.initState();
    value = widget.initialValue;
    multiValues = widget.initialValues ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        children: [
          Text(widget.title),
          if (widget.description != null) ...[
            const SizedBox(height: 10),
            Text(widget.description!),
          ],
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children:
              widget.valueLabelMapper.entries.map((entry) {
                if (widget.hasMultipleChoices) {
                  return CheckboxListTile(
                    title: entry.value,
                    value: multiValues.contains(entry.key),
                    onChanged: (value) => onCheckboxButtonTap(value, entry.key),
                  );
                }

                return RadioListTile<T>(
                  title: entry.value,
                  value: entry.key,
                  toggleable: widget.toggleable,
                  groupValue: value,
                  onChanged: onRadioButtonTap,
                );
              }).toList(),
        ),
      ),
      actions: [FilledButton(onPressed: onConfirmButtonTap, child: const Icon(Icons.check_rounded))],
    );
  }

  void onCheckboxButtonTap(bool? value, T choice) {
    if (value == null) return;
    setState(() {
      value ? multiValues.add(choice) : multiValues.remove(choice);
    });
  }

  void onRadioButtonTap(T? choice) {
    setState(() {
      value = choice;
    });
  }

  void onConfirmButtonTap() {
    if (!widget.hasMultipleChoices && value != null) multiValues.add(value as T);
    Navigator.of(context).pop<List<T>?>(multiValues);
  }
}
