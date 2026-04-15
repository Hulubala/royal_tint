import 'package:flutter/material.dart';

class HoverableCard extends StatefulWidget {
  const HoverableCard({required this.child});
  final Widget child;

  @override
  State<HoverableCard> createState() => HoverableCardState();
}

class HoverableCardState extends State<HoverableCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        scale: _hover ? 1.01 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: widget.child,
      ),
    );
  }
}