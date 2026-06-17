# KDialogs

Documentacion de los helpers disponibles en `lib/kdialogs`.

## Import

```dart
import 'package:dart_identity_sdk/kdialogs/kdialogs.dart';
```

## Guias

- [Procesos asincronos](async-progress.md)
- [Confirmaciones y alertas](confirmations-and-alerts.md)
- [Opciones](options.md)
- [Contenido personalizado](custom-content.md)
- [Textos configurables](strings.md)

## Helpers principales

- `showAsyncProgressKDialog`: ejecuta un proceso asincrono con loading, manejo de errores, retry opcional, confirmacion y validacion previa opcional.
- `executeAsyncWithErrorDialog`: ejecuta un proceso asincrono sin loading y muestra un dialogo de error si falla.
- `showConfirmationKDialog`: muestra una confirmacion y retorna `true` o `false`.
- `showBottomAlertKDialog`: muestra una alerta inferior, util para errores.
- `showBasicOptionsKDialog`: muestra un selector de opciones sin carga asincrona.
- `showAsyncOptionsDialog`: carga opciones asincronamente y luego muestra el selector.
- `showKDialogContent`: muestra un dialogo con contenido custom.
- `showKDialogWithLoadingIndicator` y `showKDialogWithLoadingMessage`: muestran loadings manuales y retornan una funcion para cerrarlos.

## Convenciones

- Todos los helpers reciben un `BuildContext`.
- Cuando el flujo puede cerrar una pantalla o esperar una operacion, validar `context.mounted` antes de seguir usando el contexto.
- Los helpers que retornan `T?` devuelven `null` cuando el usuario cancela, el contexto deja de estar montado o ocurre un error manejado.
