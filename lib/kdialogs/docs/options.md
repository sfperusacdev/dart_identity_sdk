# Opciones

Los selectores trabajan con objetos que implementan `SelectOption`.

```dart
class UserOption implements SelectOption {
  const UserOption(this.id, this.name);

  final String id;
  final String name;

  @override
  String getID() => id;

  @override
  String getLabel() => name;
}
```

## Opciones basicas

```dart
final selected = await showBasicOptionsKDialog<UserOption>(
  context,
  title: 'Usuarios',
  options: users,
  initialSelection: ['user-1'],
  allowMultipleSelection: true,
  searchInput: true,
);

if (selected == null) return;
```

## Opciones desde strings

```dart
final selected = await showBasicOptionsKDialog<StringOption>(
  context,
  options: stringOptionsAdapter(['Activo', 'Inactivo']),
);
```

## Opciones asincronas

`showAsyncOptionsDialog` carga las opciones con `showAsyncProgressKDialog` y luego muestra el selector.

```dart
final selected = await showAsyncOptionsDialog<UserOption>(
  context,
  title: 'Seleccionar usuario',
  getOptions: () async {
    return repository.getUsers();
  },
  allowMultipleSelection: false,
  searchInput: true,
);
```

Si la carga falla, se muestra el manejo de error de `showAsyncProgressKDialog` y el helper retorna `null` sin abrir el selector.
