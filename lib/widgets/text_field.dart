import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//Unused CustomTextField
class CustomTextField extends StatelessWidget {
  final String labelText;
  final String hintText;

  const CustomTextField({
    Key? key,
    required this.labelText,
    required this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
          vertical: 4.0), // Set your desired margin here
      child: TextField(
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(fontSize: 15.0),
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40.0),
          ),
        ),
      ),
    );
  }
}

class SetDeliveryText extends StatelessWidget {
  final String labelText;
  final String hintText;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  SetDeliveryText({
    required this.labelText,
    required this.hintText,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: const TextStyle(fontSize: 15.0),
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          validator: validator,
        ),
      ),
    );
  }
}

class SetDeliveryTextNumber extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final int maxLength;

  SetDeliveryTextNumber({
    required this.labelText,
    required this.controller,
    this.validator,
    this.maxLength = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: const TextStyle(fontSize: 15.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          validator: validator,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(maxLength),
          ],
        ),
      ),
    );
  }
}
