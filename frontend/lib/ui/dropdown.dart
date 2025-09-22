import 'package:flutter/material.dart';

class Dropdown extends StatefulWidget {
  final List<String> items;
  final int selectedIndex;
  final String label;
  final Function(String) onChanged;

  const Dropdown({
    super.key,
    required this.items,
    this.selectedIndex = 0,
    required this.label,
    required this.onChanged,
  });

  @override
  State<Dropdown> createState() => _DropdownState();
}

class _DropdownState extends State<Dropdown> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _updateSelectedValue();
  }

  @override
  void didUpdateWidget(Dropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync with parent when selectedIndex or items change
    if (oldWidget.selectedIndex != widget.selectedIndex ||
        oldWidget.items != widget.items) {
      _updateSelectedValue();
    }
  }

  void _updateSelectedValue() {
    if (widget.items.isNotEmpty &&
        widget.selectedIndex >= 0 &&
        widget.selectedIndex < widget.items.length) {
      setState(() {
        _selectedValue = widget.items[widget.selectedIndex];
      });
    } else {
      setState(() {
        _selectedValue = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: widget.label,
          border: const OutlineInputBorder(),
        ),
        value: _selectedValue,
        items:
            widget.items.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(
                  option,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              );
            }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedValue = newValue;
            });
            widget.onChanged(newValue);
          }
        },
      ),
    );
  }
}
