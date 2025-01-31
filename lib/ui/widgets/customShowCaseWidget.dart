import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

class CustomShowCaseWidget extends StatelessWidget {
  final GlobalKey globalKey;
  final ShapeBorder? shapeBorder;
  final String description;
  final Widget child;
  const CustomShowCaseWidget(
      {super.key,
      required this.globalKey,
      required this.description,
      this.shapeBorder,
      required this.child,});

  @override
  Widget build(BuildContext context) {
    return Showcase(
        showArrow: false,
        textColor: Theme.of(context).colorScheme.secondary,
        key: globalKey,
        description: description,
        child: child,);
  }
}
