import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateInput extends StatefulWidget {
  final Function(DateTime?) onDateSelected;
  final String label;
  final String placeholder;
  final DateTime? selectedDate;

  const DateInput({
    super.key,
    required this.onDateSelected,
    required this.label,
    required this.placeholder,
    this.selectedDate,
  });

  @override
  State<DateInput> createState() => _DateInputState();
}

class _DateInputState extends State<DateInput> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
  }

  @override
  void didUpdateWidget(DateInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _selectedDate = widget.selectedDate;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      widget.onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedDate == null
                  ? widget.placeholder
                  : DateFormat('MMMM dd, yyyy').format(_selectedDate!),
            ),
            const Icon(Icons.calendar_today_outlined),
          ],
        ),
      ),
    );
  }
}
