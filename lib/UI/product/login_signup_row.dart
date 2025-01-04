import 'package:flutter/material.dart';
import 'package:tuttuu_app/UI/product/all_colors.dart';
import 'package:tuttuu_app/UI/product/all_paddings.dart';
import 'package:tuttuu_app/UI/product/all_texts.dart';

// Text we used in row
class TextRow extends StatelessWidget {
  const TextRow({
    super.key,
    required this.text,
  });
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: MainColors().fieldTitleColorL, fontWeight: FontWeight.w300));
  }
}

//TextButton we used in row
class TextButtonRow extends StatelessWidget {
  const TextButtonRow({super.key, required this.text, required this.onPressed});
  final void Function() onPressed;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MainPaddings().inkwellPadding,
      child: InkWell(
        onTap: onPressed,
        child: Text(text,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: MainColors().textFieldFocusedL, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

Row rowForLoginandSignup(BuildContext context, String rowText, nextPage, String rowFirstText) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      TextRow(text: rowFirstText),
      TextButtonRow(
        text: rowText,
        onPressed: () {
          Future.delayed(Durations.long4);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => nextPage),
          );
        },
      ),
    ],
  );
}
