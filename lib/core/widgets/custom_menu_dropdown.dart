import 'package:flutter/material.dart';

class MenuItem<T> {
  final T value;
  final String label;
  final Widget? leading;
  const MenuItem({
    required this.value,
    required this.label,
    this.leading,
  });
}

class MenuDropdown<T> extends StatefulWidget {
  final String label;
  final IconData icon;
  final String hint;
  final T? value;
  final List<MenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final bool enabled;
  final double? width;
  final double menuMaxHeight;
  final bool showItemLeading;

  const MenuDropdown({
    super.key,
    required this.label,
    required this.icon,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.enabled = true,
    this.width,
    this.menuMaxHeight = 320,
    this.showItemLeading = true,
  });

  @override
  State<MenuDropdown<T>> createState() => _MenuDropdownState<T>();
}

class _MenuDropdownState<T> extends State<MenuDropdown<T>> {
  final MenuController _controller = MenuController();

  bool _hovered = false;
  bool _focused = false;

  double? _anchorWidth;

  bool get _enabled => widget.enabled;

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFFFD700);

    final selectedLabel = widget.items
        .where((e) => e.value == widget.value)
        .map((e) => e.label)
        .cast<String?>()
        .firstWhere((e) => e != null, orElse: () => null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: gold,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Focus(
          onFocusChange: (v) => setState(() => _focused = v),
          child: MouseRegion(
            onEnter: (_) => setState(() => _hovered = true),
            onExit: (_) => setState(() => _hovered = false),
            child: MenuAnchor(
              controller: _controller,
              style: MenuStyle(
                backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
                elevation: const WidgetStatePropertyAll(14),
                padding: const WidgetStatePropertyAll(EdgeInsets.zero),
              ),
              builder: (context, controller, child) {
                final isOpen = controller.isOpen;

                final borderColor = !_enabled
                    ? gold.withOpacity(0.25)
                    : (isOpen || _focused || _hovered)
                        ? const Color(0xFFFFC700)
                        : gold;

                final fillColor = !_enabled
                    ? Colors.black.withOpacity(0.5)
                    : (isOpen || _focused || _hovered)
                        ? const Color(0xFF111111)
                        : Colors.black;

                return LayoutBuilder(
                  builder: (context, constraints) {
      
                    final effectiveWidth = widget.width ?? constraints.maxWidth;
                    _anchorWidth ??= effectiveWidth;

                    if (_anchorWidth != effectiveWidth) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        if (_anchorWidth == effectiveWidth) return;
                        setState(() => _anchorWidth = effectiveWidth);
                      });
                    }

                    return InkWell(
                      onTap: !_enabled
                          ? null
                          : () {
                              controller.isOpen
                                  ? controller.close()
                                  : controller.open();
                            },
                      borderRadius: BorderRadius.circular(8),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        width: effectiveWidth,
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: fillColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderColor, width: 2),
                          boxShadow: [
                            if (_enabled && (isOpen || _focused || _hovered))
                              BoxShadow(
                                color: gold.withOpacity(0.12),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(widget.icon, color: gold, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                selectedLabel ?? widget.hint,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: (selectedLabel == null)
                                      ? gold.withOpacity(0.45)
                                      : gold,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Icon(
                              isOpen
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: gold,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              menuChildren: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: _anchorWidth ?? 0,
                    maxWidth: _anchorWidth ?? double.infinity,
                    maxHeight: widget.menuMaxHeight,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A0A0A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: gold, width: 2),
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(6),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(widget.items.length, (index) {
                              final item = widget.items[index];
                              final isSelected =
                                  widget.value != null && item.value == widget.value;

                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: !_enabled
                                      ? null
                                      : () {
                                          widget.onChanged(item.value);
                                          _controller.close();
                                        },
                                  borderRadius: BorderRadius.circular(10),
                                  hoverColor: gold.withOpacity(0.12),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: isSelected
                                          ? gold.withOpacity(0.10)
                                          : Colors.transparent,
                                    ),
                                    child: Row(
                                      children: [
                                        if (widget.showItemLeading && item.leading != null) ...[
                                          item.leading!,
                                          const SizedBox(width: 10),
                                        ],
                                        Expanded(
                                          child: Text(
                                            item.label,
                                            style: const TextStyle(
                                              color: gold,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        if (isSelected)
                                          const Icon(Icons.check, color: gold, size: 18),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}