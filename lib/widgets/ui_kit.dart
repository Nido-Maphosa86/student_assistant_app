// ignore_for_file: deprecated_member_use

/// File: ui_kit.dart
/// Purpose: Reusable UI building blocks used across all screens. Defines
///          the unique visual language of the system.
library;

import 'package:flutter/material.dart';
import '../app_theme.dart';

/// =========================================================================
/// SECTION LABEL - small monospace tag used to head every section of a
/// screen. Gives the system its "archival / data-driven" feel.
/// =========================================================================
class SectionLabel extends StatelessWidget {
  final String text;
  final String? index; // optional "01" / "02" prefix
  const SectionLabel(this.text, {this.index, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (index != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.accent,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              index!,
              style: const TextStyle(
                fontFamily: AppTheme.fontMono,
                color: AppTheme.canvas,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(text.toUpperCase(), style: AppTheme.label),
        ),
        Container(height: 1, width: 40, color: AppTheme.border),
      ],
    );
  }
}

/// =========================================================================
/// STATUS PILL - capsule that displays an application status with the
/// correct colour. Used in the home list, detail screen, and admin board.
/// =========================================================================
class StatusPill extends StatelessWidget {
  final String status;
  const StatusPill(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = _colorFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        border: Border.all(color: c.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: c,
              fontFamily: AppTheme.fontMono,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  static Color _colorFor(String s) {
    switch (s) {
      case 'approved':
        return AppTheme.approved;
      case 'rejected':
        return AppTheme.rejected;
      default:
        return AppTheme.pending;
    }
  }
}

/// =========================================================================
/// PRIMARY BUTTON - the main call-to-action button. Wide, lime-coloured,
/// dark text, square corners.
/// =========================================================================
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  const PrimaryButton({
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.canvas,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(label.toUpperCase()),
                ],
              ),
      ),
    );
  }
}

/// =========================================================================
/// SECONDARY (OUTLINE) BUTTON - lower-emphasis button.
/// =========================================================================
class OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  const OutlineButton({
    required this.label,
    this.onPressed,
    this.icon,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.textHi;
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: c,
          side: BorderSide(color: c.withOpacity(0.4)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16),
              const SizedBox(width: 8),
            ],
            Text(label.toUpperCase()),
          ],
        ),
      ),
    );
  }
}

/// =========================================================================
/// INFO ROW - "Label . . . . . . . . . . Value" line used on the detail
/// screen. The dotted leader gives a typewritten / index-card feel.
/// =========================================================================
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const InfoRow({required this.label, required this.value, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label.toUpperCase(), style: AppTheme.label),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: AppTheme.mono.copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

/// =========================================================================
/// CORNER ACCENT - small decorative bracket placed at the corner of a card
/// to reinforce the "technical / blueprint" aesthetic. Pure decoration.
/// =========================================================================
class CornerAccent extends StatelessWidget {
  final Alignment alignment;
  final Color? color;
  const CornerAccent({
    this.alignment = Alignment.topLeft,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.accent;
    return Align(
      alignment: alignment,
      child: SizedBox(
        width: 12,
        height: 12,
        child: CustomPaint(painter: _BracketPainter(alignment, c)),
      ),
    );
  }
}

class _BracketPainter extends CustomPainter {
  final Alignment alignment;
  final Color color;
  _BracketPainter(this.alignment, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw an L-bracket at the requested corner.
    if (alignment == Alignment.topLeft) {
      canvas.drawLine(const Offset(0, 0), Offset(size.width, 0), p);
      canvas.drawLine(const Offset(0, 0), Offset(0, size.height), p);
    } else if (alignment == Alignment.topRight) {
      canvas.drawLine(Offset(0, 0), Offset(size.width, 0), p);
      canvas.drawLine(
          Offset(size.width, 0), Offset(size.width, size.height), p);
    } else if (alignment == Alignment.bottomLeft) {
      canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), p);
      canvas.drawLine(Offset(0, 0), Offset(0, size.height), p);
    } else {
      canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), p);
      canvas.drawLine(
          Offset(size.width, 0), Offset(size.width, size.height), p);
    }
  }

  @override
  bool shouldRepaint(_BracketPainter old) => false;
}



