import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class TermsCheckbox extends StatefulWidget {
  final String label;
  final String? sublabel;
  final bool initialValue;
  final ValueChanged<bool>? onChanged;

  const TermsCheckbox({
    super.key,
    required this.label,
    this.sublabel,
    this.initialValue = false,
    this.onChanged,
  });

  @override
  State<TermsCheckbox> createState() => _TermsCheckboxState();
}

class _TermsCheckboxState extends State<TermsCheckbox> {
  late bool _checked;

  @override
  void initState() {
    super.initState();
    _checked = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _checked = !_checked);
        widget.onChanged?.call(_checked);
      },
      child: Row(
        crossAxisAlignment:
            widget.sublabel != null ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: _checked ? AppColors.primary : Colors.transparent,
              border: _checked
                  ? null
                  : Border.all(color: const Color(0xFF626262)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: _checked
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.label, style: AppTextStyles.body),
                if (widget.sublabel != null) ...[
                  const SizedBox(height: 6),
                  Text(widget.sublabel!,
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.textHint)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
