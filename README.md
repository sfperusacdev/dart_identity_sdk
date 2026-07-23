## JUST PLAY SDK

### Actualizacion de APK desde Login

El SDK agrega una pantalla de actualizacion desde el login. La pantalla busca la
ultima release del servicio configurado, compara contra `ApplicationInfo.appVersion`,
descarga el APK con progreso y abre el instalador de Android. Si el APK ya fue
descargado completo, la pantalla muestra directamente la opcion de instalar.

Si la app host necesita un instalador propio, puede pasar un callback opcional:

```dart
await initializeIdentityDependencies(
  appID: 'tareo.app',
  appName: 'Tareo',
  logPort: 10200,
  apkInstaller: (apkPath) async {
    // Abrir o instalar el APK con el mecanismo de la app host.
  },
);
```

Si no se configura `apkInstaller`, el SDK usa el instalador por defecto basado en
`open_file`. Si Android bloquea la instalacion, la pantalla permite abrir la
configuracion de permiso para instalar apps desconocidas desde la app host.
El permiso se abre automaticamente cuando Android lo solicita y, al regresar a
la aplicacion, el SDK intenta abrir nuevamente el instalador.
Despues de agregar o actualizar este SDK, la app host debe recompilarse por
completo (`flutter clean`, `flutter pub get` y volver a instalar la app) para
registrar los plugins nativos usados por el flujo de actualizacion.

La app Android host debe permitir instalacion de paquetes:

```xml
<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />
```
