# Contenido Personalizado

`showKDialogContent` permite construir un dialogo con contenido propio.

## Uso basico

```dart
final saved = await showKDialogContent<bool>(
  context,
  title: 'Editar nombre',
  saveBtnText: 'Guardar',
  onSave: () async {
    if (controller.text.trim().isEmpty) return false;
    await repository.saveName(controller.text.trim());
    return true;
  },
  builder: (context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(labelText: 'Nombre'),
    );
  },
);

if (saved != true) return;
```

## Cierre y titulo

```dart
await showKDialogContent(
  context,
  hideTitleBar: true,
  closeOnOutsideTap: true,
  allowBackButtonToClose: true,
  builder: (context) {
    return const Text('Contenido simple');
  },
);
```

## onSave

`onSave` puede ser sincrono o asincrono. Si retorna `true`, el dialogo se cierra con `true`. Si retorna `false`, el dialogo permanece abierto.

Cuando el dialogo usa un tipo distinto de `bool`, se puede indicar el resultado con `getSaveResult`.

```dart
final result = await showKDialogContent<String>(
  context,
  title: 'Crear codigo',
  getSaveResult: () => controller.text.trim(),
  onSave: () {
    return controller.text.trim().isNotEmpty;
  },
  builder: (context) {
    return TextField(controller: controller);
  },
);
```
