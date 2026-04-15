import 'package:flutter/material.dart';

class HoverableWidget extends StatefulWidget {
  final Widget child;
  final MouseCursor cursor;

  const HoverableWidget({
    super.key,
    required this.child,
    this.cursor = SystemMouseCursors.click,
  });

  @override
  State<HoverableWidget> createState() => _HoverableWidgetState();
}

class _HoverableWidgetState extends State<HoverableWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.cursor,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: _isHovered ? 0.8 : 1.0,
        child: widget.child,
      ),
    );
  }
}