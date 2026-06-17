# Procesos Asincronos

`showAsyncProgressKDialog` es el helper recomendado para ejecutar procesos que pueden tardar y necesitan feedback visual.

## Uso basico

```dart
final result = await showAsyncProgressKDialog<String>(
  context,
  doProcess: () async {
    return service.loadValue();
  },
);

if (result == null) return;
```

## Loading con mensaje

```dart
await showAsyncProgressKDialog(
  context,
  loadingMessage: 'Procesando informacion...',
  doProcess: () async {
    await service.process();
  },
);
```

## Confirmacion antes de ejecutar

```dart
await showAsyncProgressKDialog(
  context,
  confirmationRequired: true,
  confirmationTitle: 'Eliminar registro',
  confirmationMessage: 'Esta accion no se puede deshacer.',
  doProcess: () async {
    await repository.delete();
  },
);
```

## Validacion previa

`validateBeforeProcess` corre antes de `doProcess` y tambien muestra loading mientras se ejecuta. Si la validacion hace `throw`, se muestra una confirmacion con el mensaje del error. Si el usuario confirma, el proceso continua; si cancela, retorna `null`.

```dart
await showAsyncProgressKDialog(
  context,
  loadingMessage: 'Validando...',
  validateBeforeProcess: () async {
    final hasWarnings = await service.hasWarnings();
    if (hasWarnings) {
      throw 'Se encontraron advertencias. Desea continuar?';
    }
  },
  validationErrorTitle: 'Validacion',
  validationConfirmText: 'Continuar',
  validationCancelText: 'Cancelar',
  doProcess: () async {
    await service.process();
  },
);
```

## Errores y retry

Si `doProcess` lanza un error, se muestra `showBottomAlertKDialog`. Con `retryable: true`, el usuario puede reintentar el proceso.

```dart
await showAsyncProgressKDialog(
  context,
  retryable: true,
  bottomErrorAlertTitle: 'No se pudo completar',
  errorRetryText: 'Reintentar',
  doProcess: () async {
    await api.sync();
  },
  onError: (message) {
    logger.warning(message);
  },
);
```

En retry se reintenta `doProcess`; no se vuelve a ejecutar la confirmacion inicial ni la validacion previa.

## Exito

```dart
await showAsyncProgressKDialog(
  context,
  showSuccessSnackBar: true,
  successMessage: 'Operacion completada',
  doProcess: () async {
    return repository.save();
  },
  onSuccess: (value) {
    debugPrint('Guardado: $value');
  },
);
```

`onSuccess` solo se llama cuando el resultado no es `null`.
