import 'package:flutter/material.dart';

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
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: restOfText,
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(fontWeight: FontWeight.normal),
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
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: restOfText,
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(fontWeight: FontWeight.normal),
          ),
        ],
      ),
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
      style: Theme.of(context)
          .textTheme
          .titleMedium!
          .copyWith(fontWeight: FontWeight.bold),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }
}

class TitleMediumText extends StatelessWidget {
  final String text;

  const TitleMediumText({required this.text});

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
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: restOfText,
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(fontWeight: FontWeight.normal),
          ),
        ],
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }
}
