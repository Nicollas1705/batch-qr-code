import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/utils.dart';

typedef LineNumberBuilder = Text Function(BuildContext context, int index, TextStyle style);

class NumberedTextField extends StatefulWidget {
  const NumberedTextField({
    super.key,
    this.controller,
    this.scrollController,
    this.onChanged,
    this.verticalDivider = const VerticalDivider(width: 1),
    this.textStyle = const TextStyle(fontFamily: 'Courier', fontSize: 14),
    this.textHeight = 20,
    this.textFieldRestorationId,
    this.lineNumberTextBuilder = defaultLineNumberTextBuilder,
    this.lineNumberBackgroundColor,
    this.lineNumberHorizontalPadding = const EdgeInsets.symmetric(horizontal: 4),
    this.autofocus = false,
    this.focusNode,
    this.keyboardType,
    this.maxLengthEnforcement,
    this.maxLength,
    this.autocorrect = true,
    this.readOnly = false,
    this.enabled,
    this.onSubmitted,
    this.onTap,
    this.onTapOutside,
    this.undoController,
    this.scrollPhysics,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.contentPadding = const EdgeInsets.all(4),
  }) : hasHorizontalScroll = true; // TODO: 'false' not available yet

  final TextEditingController? controller;
  final ScrollController? scrollController;
  final ValueChanged<String>? onChanged;
  final Widget? verticalDivider;
  final bool hasHorizontalScroll;
  final TextStyle textStyle;
  final double textHeight;
  final String? textFieldRestorationId;
  final LineNumberBuilder lineNumberTextBuilder;
  final Color? lineNumberBackgroundColor;
  final EdgeInsets lineNumberHorizontalPadding;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final int? maxLength;
  final bool autocorrect;
  final bool readOnly;
  final bool? enabled;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final TapRegionCallback? onTapOutside;
  final UndoHistoryController? undoController;
  final ScrollPhysics? scrollPhysics;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final EdgeInsets contentPadding;

  static Text defaultLineNumberTextBuilder(BuildContext context, int index, TextStyle style) {
    return Text(
      '${index + 1}',
      style: style.copyWith(color: style.color?.withValues(alpha: .5)),
      textAlign: TextAlign.end,
    );
  }

  @override
  State<NumberedTextField> createState() => _NumberedTextFieldState();
}

class _NumberedTextFieldState extends State<NumberedTextField> {
  late final TextEditingController controller;
  late final ScrollController textFieldScrollController;
  final lineNumberScrollController = ScrollController();
  final lineCountNotifier = ValueNotifier<int>(1);
  late TextStyle style;

  @override
  void initState() {
    super.initState();

    controller = widget.controller ?? TextEditingController();
    textFieldScrollController = widget.scrollController ?? ScrollController();

    controller.addListener(() {
      final lines = controller.text.split('\n');
      lineCountNotifier.value = lines.length;
    });

    lineCountNotifier.addListener(() {
      if (!lineNumberScrollController.hasClients) return;
      // Force 'lineNumberScrollController' update when there are too many lines and cursor in the end:
      textFieldScrollController.jumpTo(textFieldScrollController.offset + 1);
    });

    textFieldScrollController.addListener(() {
      if (!lineNumberScrollController.hasClients) return;
      lineNumberScrollController.jumpTo(textFieldScrollController.offset);
    });

    final fontSize = widget.textStyle.fontSize;
    style = widget.textStyle.copyWith(
      height: fontSize == null ? null : widget.textHeight / fontSize,
    );
  }

  @override
  void dispose() {
    if (widget.controller == null) controller.dispose();
    if (widget.scrollController == null) textFieldScrollController.dispose();
    lineNumberScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final textField = TextField(
      restorationId: widget.textFieldRestorationId,
      controller: controller,
      scrollController: textFieldScrollController,
      maxLines: null,
      style: style,
      expands: true,
      decoration: InputDecoration(
        isDense: true,
        border: InputBorder.none,
        contentPadding: widget.contentPadding,
      ),
      textAlignVertical: TextAlignVertical.top,
      onChanged: widget.onChanged,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      keyboardType: widget.keyboardType,
      maxLength: widget.maxLength,
      maxLengthEnforcement: widget.maxLengthEnforcement,
      autocorrect: widget.autocorrect,
      enabled: widget.enabled,
      onSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      onTapOutside: widget.onTapOutside,
      readOnly: widget.readOnly,
      undoController: widget.undoController,
      scrollPhysics: widget.scrollPhysics,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      textAlign: widget.textAlign,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color:
              widget.lineNumberBackgroundColor ?? theme.secondaryHeaderColor.withValues(alpha: .5),
          padding: EdgeInsets.only(
            left: widget.lineNumberHorizontalPadding.left,
            right: widget.lineNumberHorizontalPadding.right,
          ),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(scrollbars: false, physics: const NeverScrollableScrollPhysics()),
            child: ValueListenableBuilder(
              valueListenable: lineCountNotifier,
              builder: (context, value, child) {
                return SizedBox(
                  width: Utils.textPainter(text: '$value', style: style, maxLines: 1).width + 1,
                  child: ListView.builder(
                    controller: lineNumberScrollController,
                    padding: EdgeInsets.only(
                      top: widget.contentPadding.top,
                      bottom: widget.contentPadding.bottom,
                    ),
                    itemCount: value,
                    itemBuilder:
                        (context, index) => widget.lineNumberTextBuilder(context, index, style),
                  ),
                );
              },
            ),
          ),
        ),
        if (widget.verticalDivider != null) widget.verticalDivider!,
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return widget.hasHorizontalScroll
                  ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: IntrinsicWidth(stepWidth: constraints.maxWidth, child: textField),
                  )
                  : textField;
            },
          ),
        ),
      ],
    );
  }
}
