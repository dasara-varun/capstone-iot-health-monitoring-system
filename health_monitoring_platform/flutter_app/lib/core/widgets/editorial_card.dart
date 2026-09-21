import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// White editorial surface with a thin warm border and optional gold top rule.
class EditorialCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool accentTop;
  final bool featured;
  final bool hoverEffect;
  final EdgeInsetsGeometry? margin;

  const EditorialCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(28),
    this.accentTop = false,
    this.featured = false,
    this.hoverEffect = true,
    this.margin,
  });

  @override
  State<EditorialCard> createState() => _EditorialCardState();
}

class _EditorialCardState extends State<EditorialCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final hover = widget.hoverEffect && _hovering;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        margin: widget.margin,
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.featured
              ? const Color(0xFFFBF8F0)
              : hover
                  ? AppTheme.muted.withValues(alpha: 0.35)
                  : AppTheme.card,
          borderRadius: BorderRadius.circular(8),
          border: Border(
            top: BorderSide(
              color: widget.accentTop || widget.featured ? AppTheme.accent : (hover ? AppTheme.borderHover : AppTheme.border),
              width: widget.accentTop || widget.featured ? 2 : 1,
            ),
            left: BorderSide(color: hover ? AppTheme.borderHover : AppTheme.border),
            right: BorderSide(color: hover ? AppTheme.borderHover : AppTheme.border),
            bottom: BorderSide(color: hover ? AppTheme.borderHover : AppTheme.border),
          ),
          boxShadow: hover ? AppTheme.shadowMd : AppTheme.shadowSm,
        ),
        child: widget.child,
      ),
    );
  }
}
