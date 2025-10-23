import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

enum StatMode { expense, income }

class ModeDropdown extends StatelessWidget {
  final StatMode mode;
  final Function(StatMode) onModeChanged;
  final GlobalKey modeBtnKey;

  const ModeDropdown({
    super.key,
    required this.mode,
    required this.onModeChanged,
    required this.modeBtnKey,
  });

  String get _modeLabel => mode == StatMode.expense ? 'Expense' : 'Income';
  IconData get _modeIcon =>
      mode == StatMode.expense ? Icons.trending_down : Icons.trending_up;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: modeBtnKey,
      onTap: () async {
        final button =
            modeBtnKey.currentContext!.findRenderObject() as RenderBox;
        final overlay =
            Overlay.of(context).context.findRenderObject() as RenderBox;
        final offset = button.localToGlobal(Offset.zero, ancestor: overlay);
        final size = button.size;
        final position = RelativeRect.fromLTRB(
          offset.dx,
          offset.dy + size.height,
          overlay.size.width - (offset.dx + size.width),
          overlay.size.height - (offset.dy + size.height),
        );

        final opposite =
            mode == StatMode.expense ? StatMode.income : StatMode.expense;
        final newMode = await showMenu<StatMode>(
          context: context,
          position: position,
          elevation: 12,
          color: Colors.white,
          shadowColor: Colors.black.withOpacity(0.15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          constraints: BoxConstraints(
            minWidth: size.width,
            maxWidth: size.width,
          ),
          items: [
            if (opposite == StatMode.expense)
              PopupMenuItem(
                value: StatMode.expense,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.trending_down, color: Colors.red),
                      const SizedBox(width: 10),
                      Text(
                        'Expense',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              PopupMenuItem(
                value: StatMode.income,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.trending_up, color: Colors.green),
                      const SizedBox(width: 10),
                      Text(
                        'Income',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
        if (newMode != null && newMode != mode) {
          onModeChanged(newMode);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _modeIcon,
              color:
                  mode == StatMode.expense
                      ? Colors.red[200]
                      : Colors.green[200],
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              _modeLabel,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }
}