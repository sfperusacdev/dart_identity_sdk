import 'package:dart_identity_sdk/widgets/home/default_home_page.dart';
import 'package:flutter/material.dart';

class BasePage extends StatefulWidget {
  final Widget Function(BuildContext context) body;

  const BasePage({
    super.key,
    required this.body,
  });

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  DateTime? backPressTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          final now = DateTime.now();
          if (backPressTime == null) {
            backPressTime = now;
          } else if (now.difference(backPressTime!) >
              const Duration(milliseconds: 500)) {
            backPressTime = now;
          }
          await goOutSession(context);
        },
        child: widget.body(context),
      ),
    );
  }
}
