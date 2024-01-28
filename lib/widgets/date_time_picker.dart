import 'package:flutter/material.dart';

class DateTimePicker extends StatefulWidget {
  final TextEditingController controller;
  final DateTime? initialDateTime;
  final String labelText;

  DateTimePicker({
    required this.controller,
    this.initialDateTime,
    required this.labelText,
  });

  @override
  _DateTimePickerState createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  DateTime? selectedDateTime;

  @override
  void initState() {
    super.initState();
    selectedDateTime = widget.initialDateTime;
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: selectedDateTime != null
            ? TimeOfDay.fromDateTime(selectedDateTime!)
            : TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          widget.controller.text = "${_formatDateTime(selectedDateTime!)}";
        });
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} "
        "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _selectDateTime(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: selectedDateTime != null ? widget.labelText : '',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.only(left: 12.0, bottom: 20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.controller.text.isNotEmpty
                  ? widget.controller.text
                  : selectedDateTime != null
                      ? _formatDateTime(selectedDateTime!)
                      : widget.labelText,
            ),
            const Icon(Icons.calendar_today),
            Container(),
          ],
        ),
      ),
    );
  }
}
