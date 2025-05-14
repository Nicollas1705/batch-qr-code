import 'package:flutter/material.dart';

import '../../core/app_settings.dart';

class TextMetaData extends StatelessWidget {
  const TextMetaData({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('${text.split('\n').length}'),
        SizedBox(width: AppSettings.spacing.small),
        const Icon(Icons.format_list_numbered_rounded),
        const Spacer(),
        const Icon(Icons.abc_rounded),
        SizedBox(width: AppSettings.spacing.small),
        Text('${text.length}'),
      ],
    );
  }
}
