# Confirmaciones Y Alertas

## Confirmacion

`showConfirmationKDialog` muestra un dialogo bloqueante y retorna `true` si el usuario confirma.

```dart
final confirmed = await showConfirmationKDialog(
  context,
  title: 'Confirmar',
  message: 'Desea continuar?',
  acceptText: 'Si',
  cancelText: 'No',
);

if (!confirmed) return;
```

## Confirmacion con callback

```dart
await showConfirmationKDialogWithCallback(
  context,
  message: 'Desea guardar los cambios?',
  onConfirm: () {
    controller.save();
  },
);
```

## Alerta inferior

`showBottomAlertKDialog` se usa principalmente para errores. Retorna `true` cuando el usuario elige retry y `false` cuando acepta o cierra el flujo.

```dart
final retry = await showBottomAlertKDialog(
  context,
  title: 'Error',
  message: 'No fue posible conectar con el servidor.',
  retryable: true,
  retryText: 'Reintentar',
  acceptText: 'Aceptar',
  errorSound: true,
);

if (retry) {
  await loadAgain();
}
```

La alerta incluye una accion para copiar el mensaje al portapapeles.
