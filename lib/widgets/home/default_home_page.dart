import 'package:dart_identity_sdk/dart_identity_sdk.dart';
import 'package:dart_identity_sdk/kdialogs/src/show_basic_options.dart';
import 'package:dart_identity_sdk/kdialogs/src/show_bottom_alert.dart';
import 'package:dart_identity_sdk/kdialogs/src/show_confirmation.dart';
import 'package:dart_identity_sdk/styles/text.dart';
import 'package:flutter/material.dart';
part 'clip.dart';
part 'home_menu_card.dart';

class DefaultHomePage extends StatefulWidget {
  static const path = '/home';

  final Future<void> Function(BuildContext context)? onDependenciesReady;
  final List<HomeMenuCard> children;

  const DefaultHomePage({
    super.key,
    this.onDependenciesReady,
    required this.children,
  });

  @override
  State<DefaultHomePage> createState() => _DefaultHomePageState();
}

class _DefaultHomePageState extends State<DefaultHomePage> {
  DateTime? backPressTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _handleSessionValidation(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      top: false,
      child: Scaffold(
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
            await _goOut(context);
          },
          child: Stack(
            children: [
              Container(color: Colors.white, height: size.height * 0.4 + 12),
              ClipPath(
                clipper: CustomClip(),
                child: Container(
                  color: Theme.of(context).primaryColor,
                  height: size.height * 0.4,
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Image(
                          image: AssetImage(
                              "packages/dart_identity_sdk/assets/user.png"),
                          width: 80,
                          height: 80,
                          fit: BoxFit.fill),
                      const SizedBox(width: 10.0),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (SessionManagerSDK.getUsername() ?? "")
                                .split(".")
                                .last,
                            style: const BlodTextStyle(
                              color: Colors.white,
                              fontSize: 30,
                            ),
                          ),
                          Container(height: 2, color: Colors.white),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Container(
                padding:
                    EdgeInsets.only(top: size.height * 0.4 + 12, bottom: 80),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: size.width),
                      Wrap(
                        runSpacing: 12.0,
                        spacing: 12.0,
                        children: widget.children,
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  color: Colors.white,
                  height: 80,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image(
                          image: const AssetImage(
                            "packages/dart_identity_sdk/assets/logo-sf.png",
                          ),
                          height: 50,
                          fit: BoxFit.fill,
                          color: Theme.of(context).primaryColor,
                        ),
                        Material(
                          borderRadius: BorderRadius.circular(10.0),
                          elevation: 4.0,
                          child: InkWell(
                            onTap: () => _goOut(context),
                            borderRadius: BorderRadius.circular(10.0),
                            child: Ink(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF6921E),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 6.0, horizontal: 12),
                                child: Row(
                                  children: [
                                    Text(
                                      "SALIR",
                                      style: BlodTextStyle(color: Colors.white),
                                    ),
                                    SizedBox(width: 8),
                                    RotatedBox(
                                      quarterTurns: 2,
                                      child: Icon(
                                        Icons.exit_to_app,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Builder(builder: (context) {
                final sucursal = getSelectedBranch() ?? "";
                return Align(
                  alignment: Alignment.topCenter,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              sucursal.split(".").last,
                              style: const BlodTextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _showSelectSucursalDialog(context),
                            icon: const Icon(Icons.domain),
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              })
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSessionValidation() async {
    try {
      if (!SessionManagerSDK.hasValidSession()) {
        if (mounted) await SessionManagerSDK.logout(context);
        return;
      }

      final ok = await SessionManagerSDK.validateMinimumSessionRequirements(
        context,
      );
      if (!ok) {
        if (mounted) await SessionManagerSDK.logout(context);
        return;
      }

      if (mounted) {
        widget.onDependenciesReady?.call(context);
      }
    } catch (err) {
      if (mounted) {
        await showBottomAlertKDialog(
          context,
          message: err.toString(),
        );
        if (mounted) await SessionManagerSDK.logout(context);
      }
    }
  }

  void _showSelectSucursalDialog(BuildContext context) async {
    final initialSelection = <String>[];
    final current = getSelectedBranch();
    if (current != null && current.isNotEmpty) {
      initialSelection.add(current);
    }
    final selected = await showBasicOptionsKDialog(
      context,
      initialSelection: initialSelection,
      title: "Sucursales",
      options: stringOptionsAdapter(
        SessionManagerSDK.findCompanyBranchs(),
      ),
    );
    if (selected == null || selected.isEmpty) return;
    await setSelectedBranch(selected.first.value);
    setState(() {});
  }

  Future<void> _goOut(BuildContext context, {bool confirm = true}) async {
    if (confirm) {
      final ok = await showConfirmationKDialog(context,
          message: "Estás seguro de cerrar sesión");
      if (!ok) return;
    }
    if (context.mounted) await SessionManagerSDK.logout(context);
  }
}
