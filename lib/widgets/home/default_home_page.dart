import 'dart:async';

import 'package:dart_identity_sdk/dart_identity_sdk.dart';
import 'package:dart_identity_sdk/info/preferences_dialog.dart';
import 'package:dart_identity_sdk/kdialogs/src/about_dialog.dart';
import 'package:dart_identity_sdk/kdialogs/src/show_async_progress.dart';
import 'package:dart_identity_sdk/kdialogs/src/show_basic_options.dart';
import 'package:dart_identity_sdk/kdialogs/src/show_confirmation.dart';
import 'package:dart_identity_sdk/styles/text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
part 'clip.dart';
part 'home_menu_card.dart';

class DefaultHomePage extends StatefulWidget {
  static const path = '/home';

  /// Called after the current session passes all required validations.
  final Future<void> Function(BuildContext context)? onSessionReady;
  final List<HomeMenuCard> Function(BuildContext context) builder;
  final VoidCallback? onRefreshPreferences;

  /// Preference key used to decide whether the initial sync dialog should open.
  /// If null, the dialog is not shown automatically.
  final String? showSyncDialogPreferenceKey;

  /// Called when session closing is already confirmed and imminent.
  final Future<void> Function(BuildContext context)? onSessionEnding;

  const DefaultHomePage({
    super.key,
    this.onSessionReady,
    required this.builder,
    this.onRefreshPreferences,
    this.showSyncDialogPreferenceKey,
    this.onSessionEnding,
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
      (_) => _handleSessionValidation(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final enabled = hasTableSyncProvider(context);
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
            await goOutSession(
              context,
              onSessionEnding: widget.onSessionEnding,
            );
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
                            "packages/dart_identity_sdk/assets/user.png",
                          ),
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
                        children: [
                          ...widget.builder(context),
                          if (enabled)
                            HomeMenuCard(
                              assetImage: "assets/icons/sincronizar.png",
                              assetPackage: "dart_identity_sdk",
                              title: "SINCRONIZAR",
                              onTab: () => context.push(TableSyncPage.path),
                            ),
                        ],
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
                        InkWell(
                          onTap: () => showCustomAboutDialog(context),
                          child: Image(
                            image: const AssetImage(
                              "packages/dart_identity_sdk/assets/logo-sf.png",
                            ),
                            height: 50,
                            fit: BoxFit.fill,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Material(
                          borderRadius: BorderRadius.circular(10.0),
                          elevation: 4.0,
                          child: InkWell(
                            onTap: () => goOutSession(
                              context,
                              onSessionEnding: widget.onSessionEnding,
                            ),
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
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  "Sucursal: ${sucursal.split(".").last}",
                                  style: const BlodTextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => _showSelectSucursalDialog(
                                  context,
                                ),
                                icon: const Icon(Icons.domain),
                                color: Colors.white,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () => _syncPreferences(context),
                                onLongPress: () async {
                                  await showDomainPreferencesDialog(
                                    context,
                                  );
                                  widget.onRefreshPreferences?.call();
                                },
                                icon: Icon(
                                  Icons.cloud_sync,
                                  color: Theme.of(context).colorScheme.surface,
                                ),
                              )
                            ],
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

  Future<void> _syncPreferences(BuildContext context) async {
    await AppPreferences.syncPreferencesWithLoaderIndicator(
      context,
    );
    setState(() {});
  }

  Future<void> _handleSessionValidation(BuildContext context) async {
    await showAsyncProgressKDialog<bool>(
      context,
      retryable: true,
      doProcess: () async {
        await _prepareSession(context);
        return true;
      },
      onSuccess: (_) {
        if (!context.mounted) return;
        _showInitialSyncDialogIfNeeded(context);
      },
    );
  }

  Future<void> _prepareSession(BuildContext context) async {
    try {
      if (!SessionManagerSDK.hasValidSession()) {
        if (context.mounted) await SessionManagerSDK.logout(context);
        return;
      }

      final ok = await SessionManagerSDK.validateMinimumSessionRequirements(
        context,
      );
      if (!ok) {
        if (context.mounted) await SessionManagerSDK.logout(context);
        return;
      }

      if (context.mounted) {
        await widget.onSessionReady?.call(context);
      }
      if (context.mounted) {
        LOG.printInfo(['TABLE_SYNC', 'home startConfiguredGroups']);
        await maybeTableSyncBloc(context)?.startConfiguredGroups();
      }
    } catch (err) {
      if (context.mounted) {
        await SessionManagerSDK.logout(context);
      }
      rethrow;
    }
  }

  Future<void> _showInitialSyncDialogIfNeeded(BuildContext context) async {
    final preferenceKey = widget.showSyncDialogPreferenceKey;
    final tableSyncBloc = maybeTableSyncBloc(context);
    if (preferenceKey == null || preferenceKey.trim().isEmpty) return;
    if (tableSyncBloc == null) return;

    final enabled = AppPreferences.readBool(preferenceKey);
    final firstOpen = SessionManagerSDK.ifFirstOpen;
    if (!enabled || !firstOpen) return;

    LOG.printInfo(['TABLE_SYNC', 'home show initial sync dialog']);
    await showTableSyncDialog(context);
  }

  void _showSelectSucursalDialog(BuildContext context) async {
    final initialSelection = <String>[];
    final current = getSelectedBranch();
    if (current != null && current.isNotEmpty) {
      initialSelection.add(current.split(".").last);
    }
    final selected = await showBasicOptionsKDialog(
      context,
      initialSelection: initialSelection,
      title: "Sucursales",
      options: stringOptionsAdapter(
        SessionManagerSDK.findCompanyBranchs()
            .map((elm) => elm.split(".").last)
            .toList(),
      ),
    );
    if (selected == null || selected.isEmpty) return;
    await setSelectedBranch(selected.first.value);
    setState(() {});
  }
}

Future<void> goOutSession(
  BuildContext context, {
  bool confirm = true,
  Future<void> Function(BuildContext context)? onSessionEnding,
}) async {
  final tableSyncBloc = maybeTableSyncBloc(context);
  if (confirm) {
    final ok = await showConfirmationKDialog(context,
        message: "Estás seguro de cerrar sesión");
    if (!ok) return;
  }
  if (context.mounted) {
    LOG.printInfo(['TABLE_SYNC', 'session ending stopAll']);
    await tableSyncBloc?.stopAll();
    if (!context.mounted) return;
    await SessionManagerSDK.logout(
      context,
      onSessionEnding: onSessionEnding,
    );
  }
}
