import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import 'auth_selection_page.dart';

class TermsPage extends StatefulWidget {
  const TermsPage({super.key});

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  bool _locationAccess = false;
  bool _offersUpdates = false;

  bool get _canStart => _locationAccess;

  void _toggleAll() {
    final newVal = !(_locationAccess && _offersUpdates);
    setState(() {
      _locationAccess = newVal;
      _offersUpdates = newVal;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 74, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목 (full width)
                    Text(
                      'Welcome to Naru!\nAgree to the terms below\nand join to Korean taste.',
                      style: AppTextStyles.h2.copyWith(height: 1.2),
                    ),

                    const SizedBox(height: 20),

                    // 마스코트(우측) + Agree to All(top:52 절대배치) + 구분선
                    SizedBox(
                      height: 95,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: Image.asset(
                              'assets/images/terms_mascot.png',
                              width: 115,
                              height: 94,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Divider(color: AppColors.border, thickness: 1, height: 1),
                          ),
                          Positioned(
                            left: 0,
                            top: 52,
                            child: GestureDetector(
                              onTap: _toggleAll,
                              behavior: HitTestBehavior.opaque,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    'assets/images/ic_check_all.svg',
                                    width: 22,
                                    height: 22,
                                    colorFilter: const ColorFilter.mode(
                                      AppColors.primary,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Agree to All',
                                    style: AppTextStyles.title,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Location Access 체크박스
                    _TermsRow(
                      checked: _locationAccess,
                      onTap: () => setState(() => _locationAccess = !_locationAccess),
                      label: 'Enable Location Access (Required)',
                    ),

                    const SizedBox(height: 20),

                    // Offers 체크박스
                    _TermsRow(
                      checked: _offersUpdates,
                      onTap: () => setState(() => _offersUpdates = !_offersUpdates),
                      label: 'Receive Offers & Updates (Optional)',
                      sublabel: 'Get the latest deals and special offers.',
                    ),
                  ],
                ),
              ),
            ),

            // Start 버튼
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: GestureDetector(
                onTap: _canStart
                    ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AuthSelectionPage(),
                          ),
                        )
                    : null,
                child: Container(
                  height: 48,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _canStart ? AppColors.primary : AppColors.inactive,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Start',
                    style: AppTextStyles.h2.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TermsRow extends StatelessWidget {
  final bool checked;
  final VoidCallback onTap;
  final String label;
  final String? sublabel;

  const _TermsRow({
    required this.checked,
    required this.onTap,
    required this.label,
    this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: sublabel != null
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: checked ? const Color(0xFF262626) : Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: checked ? null : Border.all(color: const Color(0xFF626262)),
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/images/checkbox_on.svg',
                width: 13,
                height: 10,
                colorFilter: ColorFilter.mode(
                  checked ? Colors.white : Colors.transparent,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.body),
                if (sublabel != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    sublabel!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
