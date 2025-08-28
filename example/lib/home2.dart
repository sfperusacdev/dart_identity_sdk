import 'package:dart_identity_sdk/widgets/home/default_home_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainHome extends StatelessWidget {
  const MainHome({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultHomePage(
      children: [
        HomeMenuCard(
          assetImage: "assets/topico.png",
          title: "TOPICO",
          onTab: () {
            context.push("/dialogs");
          },
        ),
        HomeMenuCard(
          assetImage: "assets/topico.png",
          title: "TOPICO",
          onTab: () {
            context.push("/dialogs");
          },
        ),
        HomeMenuCard(
          assetImage: "assets/topico.png",
          title: "TOPICO",
          onTab: () {
            context.push("/dialogs");
          },
        ),
      ],
    );
  }
}
