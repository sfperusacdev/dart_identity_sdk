# Textos Configurables

Los textos por defecto viven en la variable global `strings` y se pueden reemplazar con `setKDialogStrings`.

```dart
setKDialogStrings(
  KDialogStrings(
    acceptButtonText: 'ACEPTAR',
    confirmButtonText: 'CONFIRMAR',
    cancelButtonText: 'CANCELAR',
    saveButtonText: 'Guardar',
    confirmationMessage: 'Esta seguro de continuar?',
    errorRetryText: 'REINTENTAR',
    searchLabelInputText: 'Buscar',
    bottomErrorAlertTitle: 'Ocurrio un error',
    confirmDialogText: 'Confirme la accion para continuar.',
    defaultDialogTitle: 'Titulo',
    loadingDialogMessage: 'Cargando, por favor espere...',
  ),
);
```

## Recomendacion

Configurar estos textos una sola vez durante el arranque de la app, antes de mostrar cualquier dialogo.
