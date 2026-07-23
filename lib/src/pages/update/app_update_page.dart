import 'package:dart_identity_sdk/src/services/app_update.dart';
import 'package:flutter/material.dart';

class AppUpdatePage extends StatefulWidget {
  static const path = '/_/app/update';

  const AppUpdatePage({super.key});

  @override
  State<AppUpdatePage> createState() => _AppUpdatePageState();
}

class _AppUpdatePageState extends State<AppUpdatePage>
    with WidgetsBindingObserver {
  final _service = AppUpdateService();

  AppUpdateCheckResult? _check;
  AppRelease? _release;
  String? _apkPath;
  String? _error;
  bool _checking = true;
  bool _downloading = false;
  bool _installing = false;
  bool _needsInstallPermission = false;
  bool _waitingForPermission = false;
  bool _returnedFromPermissionSettings = false;
  int _downloadedBytes = 0;
  int? _totalBytes;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdate());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed ||
        !_waitingForPermission ||
        _apkPath == null ||
        _busy) {
      return;
    }

    _waitingForPermission = false;
    _returnedFromPermissionSettings = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _installDownloadedApk();
    });
  }

  Future<void> _checkForUpdate() async {
    setState(() {
      _checking = true;
      _error = null;
      _needsInstallPermission = false;
      _waitingForPermission = false;
      _returnedFromPermissionSettings = false;
    });

    try {
      final result = await _service.checkForUpdate();
      if (!mounted) return;
      setState(() {
        _check = result;
        _release = result.release;
      });
      final release = result.release;
      if (release != null) {
        final path = await _service.downloadedApkPath(release);
        if (!mounted) return;
        setState(() => _apkPath = path);
      }
    } catch (err) {
      if (!mounted) return;
      setState(() => _error = err.toString());
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _downloadAndInstall() async {
    final release = _release;
    if (release == null) return;

    setState(() {
      _downloading = true;
      _installing = false;
      _needsInstallPermission = false;
      _waitingForPermission = false;
      _returnedFromPermissionSettings = false;
      _error = null;
    });

    try {
      final path = await _service.downloadApk(
        release,
        onProgress: (downloadedBytes, totalBytes) {
          if (!mounted) return;
          setState(() {
            _downloadedBytes = downloadedBytes;
            _totalBytes = totalBytes;
          });
        },
      );
      if (!mounted) return;
      setState(() {
        _apkPath = path;
        _downloading = false;
        _installing = true;
      });
      await _installDownloadedApk();
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _error = err.toString();
        _downloading = false;
        _installing = false;
      });
    }
  }

  Future<void> _installDownloadedApk() async {
    final apkPath = _apkPath;
    if (apkPath == null) return;

    setState(() {
      _installing = true;
      _error = null;
      _needsInstallPermission = false;
    });

    try {
      await _service.installApk(apkPath);
    } on AppUpdateInstallPermissionDenied catch (err) {
      if (!mounted) return;
      setState(() {
        _needsInstallPermission = true;
        _error = err.toString();
      });
      if (!_returnedFromPermissionSettings) {
        _waitingForPermission = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _openInstallPermissionSettings();
        });
      }
    } catch (err) {
      if (!mounted) return;
      setState(() => _error = err.toString());
    } finally {
      if (mounted) setState(() => _installing = false);
    }
  }

  Future<void> _openInstallPermissionSettings() async {
    try {
      await _service.openInstallPermissionSettings();
    } catch (err) {
      _waitingForPermission = false;
      if (!mounted) return;
      setState(() => _error = err.toString());
    }
  }

  double? get _progressValue {
    final total = _totalBytes;
    if (total == null || total == 0) return null;
    return (_downloadedBytes / total).clamp(0.0, 1.0);
  }

  bool get _busy => _checking || _downloading || _installing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Actualizar aplicación')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _buildContent(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_checking) {
      return const _UpdateStatusCard(
        icon: Icons.system_update_alt,
        title: 'Buscando actualización',
        message: 'Estamos verificando la última versión disponible.',
        child: Padding(
          padding: EdgeInsets.only(top: 18),
          child: LinearProgressIndicator(),
        ),
      );
    }

    final release = _release;
    if (release == null && _error == null) {
      return _UpdateStatusCard(
        icon: Icons.check_circle_outline,
        title: 'No hay actualización disponible',
        message: 'Tu aplicación ya está en la última versión disponible.',
        child: _primaryButton(
          label: 'Buscar nuevamente',
          icon: Icons.refresh,
          onPressed: _checkForUpdate,
        ),
      );
    }

    return _UpdateStatusCard(
      icon: _needsInstallPermission
          ? Icons.admin_panel_settings_outlined
          : Icons.system_update_alt,
      title: _title(release),
      message: _message(release),
      error: _error,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_downloading) ...[
            LinearProgressIndicator(value: _progressValue),
            const SizedBox(height: 10),
            Text(
              _progressText,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
          if (_needsInstallPermission && !_busy) ...[
            const SizedBox(height: 8),
            Text(
              _returnedFromPermissionSettings
                  ? 'El permiso aún no está habilitado.'
                  : 'Abriendo la configuración de permisos...',
              textAlign: TextAlign.center,
            ),
          ] else if (!_downloading) ...[
            _primaryButton(
              label: _apkPath == null ? 'Descargar e instalar' : 'Instalar',
              icon: _apkPath == null ? Icons.download : Icons.install_mobile,
              onPressed: _busy
                  ? null
                  : (_apkPath == null
                      ? _downloadAndInstall
                      : _installDownloadedApk),
            ),
            const SizedBox(height: 10),
            _secondaryButton(
              label: 'Buscar nuevamente',
              icon: Icons.refresh,
              onPressed: _busy ? null : _checkForUpdate,
            ),
          ],
        ],
      ),
    );
  }

  String _title(AppRelease? release) {
    if (_downloading) return 'Descargando actualización';
    if (_installing) return 'Abriendo instalador';
    if (_needsInstallPermission) return 'Permiso requerido';
    if (release == null) return 'No se pudo verificar';
    return 'Actualización disponible';
  }

  String _message(AppRelease? release) {
    if (_needsInstallPermission) {
      return 'Android requiere permiso para instalar aplicaciones desde esta app. '
          'Abre la configuración, activa el permiso y vuelve para instalar.';
    }
    if (release == null) return 'Revisa tu conexión e intenta nuevamente.';
    final currentVersion = _check?.currentVersion ?? '';
    final status =
        _apkPath == null ? '' : '\nAPK descargado. Listo para instalar.';
    return 'Versión actual: $currentVersion\nNueva versión: ${release.version}$status';
  }

  String get _progressText {
    final total = _totalBytes;
    if (total == null || total == 0) return _formatBytes(_downloadedBytes);
    final percent = (_downloadedBytes * 100 / total).clamp(0, 100);
    return '${percent.toStringAsFixed(0)}% - '
        '${_formatBytes(_downloadedBytes)} de ${_formatBytes(total)}';
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    final mb = kb / 1024;
    if (mb < 1024) return '${mb.toStringAsFixed(1)} MB';
    final gb = mb / 1024;
    return '${gb.toStringAsFixed(1)} GB';
  }

  Widget _primaryButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }

  Widget _secondaryButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class _UpdateStatusCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? error;
  final Widget child;

  const _UpdateStatusCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.child,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      surfaceTintColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).primaryColor),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (error != null) ...[
              const SizedBox(height: 16),
              Text(
                error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 22),
            child,
          ],
        ),
      ),
    );
  }
}
