import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BodyMedium extends StatelessWidget {
  final String text;

  const BodyMedium({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF050404).withOpacity(0.9),
          ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }
}

class BodyMediumText extends StatelessWidget {
  final String text;

  const BodyMediumText({required this.text});

  @override
  Widget build(BuildContext context) {
    final List<String> parts = text.split(':');
    final String prefix = parts.length > 1 ? '${parts[0]}:' : '';
    final String restOfText =
        parts.length > 1 ? parts.sublist(1).join(':') : text;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: prefix,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF050404).withOpacity(0.9),
                ),
          ),
          TextSpan(
            text: restOfText,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.normal,
                  color: const Color(0xFF050404).withOpacity(0.9),
                ),
          ),
        ],
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }
}

class BodyMediumOver extends StatelessWidget {
  final String text;

  const BodyMediumOver({required this.text});

  @override
  Widget build(BuildContext context) {
    final List<String> parts = text.split(':');
    final String prefix = parts.length > 1 ? '${parts[0]}:' : '';
    final String restOfText =
        parts.length > 1 ? parts.sublist(1).join(':') : text;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: prefix,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF050404).withOpacity(0.9),
                ),
          ),
          TextSpan(
            text: restOfText,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.normal,
                  color: const Color(0xFF050404).withOpacity(0.9),
                ),
          ),
        ],
      ),
    );
  }
}

class BodyMediumOver2 extends StatelessWidget {
  final String text;

  const BodyMediumOver2({required this.text});

  @override
  Widget build(BuildContext context) {
    final List<String> parts = text.split(':');
    final String prefix = parts.length > 1 ? '${parts[0]}:' : '';
    final String restOfText =
        parts.length > 1 ? parts.sublist(1).join(':') : text;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: prefix,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF050404).withOpacity(0.9),
                ),
          ),
          TextSpan(
            text: restOfText,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.normal,
                  color: const Color(0xFF050404).withOpacity(0.9),
                ),
          ),
        ],
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
    );
  }
}

class TitleMedium extends StatelessWidget {
  final String text;

  const TitleMedium({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF050404).withOpacity(0.9),
          ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }
}

class TitleMediumText extends StatelessWidget {
  final String text;
  final int? checkColor;

  const TitleMediumText({required this.text, this.checkColor});

  @override
  Widget build(BuildContext context) {
    final List<String> parts = text.split(':');
    final String prefix = parts.length > 1 ? '${parts[0]}:' : '';
    final String restOfText =
        parts.length > 1 ? parts.sublist(1).join(':') : text;

    if (checkColor != null && checkColor! <= 3) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFd41111).withOpacity(0.8),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(fontWeight: FontWeight.bold, color: Colors.white),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      );
    } else if (checkColor != null && checkColor! >= 4 && checkColor! <= 7) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFff8c00).withOpacity(0.8),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(fontWeight: FontWeight.bold, color: Colors.white),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      );
    }

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: prefix,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF050404).withOpacity(0.9),
                ),
          ),
          TextSpan(
            text: restOfText,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.normal,
                  color: const Color(0xFF050404).withOpacity(0.9),
                ),
          ),
        ],
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }
}

class TitleMediumOver extends StatelessWidget {
  final String text;
  final int? checkColor;

  const TitleMediumOver({required this.text, this.checkColor});

  @override
  Widget build(BuildContext context) {
    final List<String> parts = text.split(':');
    final String prefix = parts.length > 1 ? '${parts[0]}:' : '';
    final String restOfText =
        parts.length > 1 ? parts.sublist(1).join(':') : text;

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: prefix,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF050404).withOpacity(0.9),
                ),
          ),
          TextSpan(
            text: restOfText,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.normal,
                  color: const Color(0xFF050404).withOpacity(0.9),
                ),
          ),
        ],
      ),
    );
  }
}

class TitleLarge extends StatelessWidget {
  final String text;

  const TitleLarge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF050404).withOpacity(0.9),
          ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }
}

class LoginTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final bool obscureText;

  const LoginTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.obscureText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      cursorColor: const Color(0xFF050404),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        hintStyle: TextStyle(
          color: const Color(0xFF050404).withOpacity(0.6),
        ),
        labelStyle: TextStyle(
          color: const Color(0xFF050404).withOpacity(0.7),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF050404)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF050404)),
        ),
      ),
    );
  }
}

class EditTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  // final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const EditTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    // this.obscureText = false,
    this.keyboardType,
    this.maxLines,
    this.inputFormatters,
    this.validator,
    this.onChanged,
  }) : super(key: key);

  @override
  _EditTextFieldState createState() => _EditTextFieldState();
}

class _EditTextFieldState extends State<EditTextField> {
  // late bool _obscureText;

  @override
  void initState() {
    super.initState();
    // _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      // obscureText: _obscureText,
      cursorColor: const Color(0xFF050404),
      keyboardType: widget.keyboardType,
      maxLines: widget.maxLines,
      inputFormatters: widget.inputFormatters,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: const Color(0xFF050404).withOpacity(0.6),
        ),
        labelStyle: TextStyle(
          color: const Color(0xFF050404).withOpacity(0.7),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF050404)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF050404)),
        ),
        // suffixIcon: widget.obscureText
        //     ? IconButton(
        //         icon: Icon(
        //           _obscureText ? Icons.visibility_off : Icons.visibility,
        //           color: const Color(0xFF050404),
        //         ),
        //         onPressed: () {
        //           setState(() {
        //             _obscureText = !_obscureText;
        //           });
        //         },
        //       )
        //     : null,
      ),
      validator: widget.validator,
      onChanged: widget.onChanged,
    );
  }
}
