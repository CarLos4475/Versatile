import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../shared/widgets/motion.dart';

class NumberInputWidget extends StatefulWidget {
  const NumberInputWidget({
    super.key,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
    this.onChanged,
    this.suffix,
    this.isDouble = false,
  });

  final num value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final ValueChanged<num>? onChanged;
  final String? suffix;
  final bool isDouble;

  @override
  State<NumberInputWidget> createState() => _NumberInputWidgetState();
}

class _NumberInputWidgetState extends State<NumberInputWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _format(widget.value));
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(NumberInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_focusNode.hasFocus) {
      _controller.text = _format(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _format(num val) {
    if (widget.isDouble) {
      return FormatUtils.weight(val.toDouble());
    }
    return val.toInt().toString();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _submit(_controller.text);
    } else {
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    }
  }

  void _submit(String text) {
    if (text.isEmpty) {
      _controller.text = _format(widget.value);
      return;
    }
    final val = num.tryParse(text);
    if (val != null) {
      widget.onChanged?.call(val);
    } else {
      _controller.text = _format(widget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: context.colors.fieldBg,
        border: Border.all(color: context.colors.hairline, width: 0.6),
      ),
      child: Row(
        children: [
          _Btn(icon: Icons.remove, onTap: widget.onDecrement),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.numberWithOptions(
                decimal: widget.isDouble,
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: context.colors.ink900,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              cursorColor: context.colors.accent,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              inputFormatters: [
                if (widget.isDouble)
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
                else
                  FilteringTextInputFormatter.digitsOnly,
              ],
              onSubmitted: _submit,
              onTapOutside: (_) => _focusNode.unfocus(),
            ),
          ),
          if (widget.suffix != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                widget.suffix!,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: context.colors.ink500,
                ),
              ),
            ),
          _Btn(icon: Icons.add, onTap: widget.onIncrement),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        margin: const EdgeInsets.all(2),
        color: Colors.transparent,
        child: Icon(icon, size: 14, color: context.colors.ink400),
      ),
    );
  }
}
