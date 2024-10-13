import 'package:flutter/material.dart';

/// Returns a custom formfield with optional [hint], [existingValue] and [onChanged]
/// function. [enabled] dictates the form's interactability
class CustomForm extends StatelessWidget {
  final String? hint, existingValue;
  final Function(String)? onChanged;
  final bool enabled;

  const CustomForm({this.hint, this.existingValue, this.onChanged, this.enabled = true, super.key});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        decoration: InputDecoration(
            border: const OutlineInputBorder(gapPadding: 0, borderSide: BorderSide.none),
            hintText: existingValue == null ? hint : null),
        initialValue: existingValue,
        enabled: enabled,
        onChanged: onChanged != null ? (value) => onChanged!(value) : null,
        validator: enabled
            ? (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a value';
                }
                return null;
              }
            : null);
  }
}
