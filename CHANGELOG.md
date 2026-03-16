## 1.0.0

- Inicial: version inicial

## 1.1.1

- Add companycode

## 1.2.0

- integrations

## 2.0.0

- Desktop integration with identity

## 2.0.1

- update kdialog library

## 2.0.2

- Fix hot reload

## 2.0.3

- Fix no connection error message

## 2.0.4

- Fix: storage de empresa seleccionada
- Fix ui scroll
- Oculta el selector de grupo si solo hay uno

## 2.0.5

- Fix: \_router initialization

## 2.1.0

- Fix: integrations
- Add: name device

## 2.1.1

- update packages

## 3.0.0

- cambia la forma de iniciar el servicio
- Inclusión de managersdk

## 4.0.0

- refactory libary
- add refresh preferences option

## 4.1.0

- Establecer y obtener la sucursal de la empresa seleccionada

## 4.1.1

- add some delay on sync preferences

## 4.2.0

- refactor preferences manager

## 4.2.1

- embebed assets

## 4.2.2

- fix certs

## 4.2.3

- fix getString on application preferences

## 4.2.4

- fix certs

## 4.2.5

- fix getString and readString on application preferences manager

## 5.0.0

- add custom criteria on session validation
- fix session date time zone

## 5.0.1

- use timestamp on session

## 5.0.2

- fix timestamp parse

## 5.1.0

- add getLicenceCode

## 5.2.0

- Refresh session operation

## 5.2.1

- fix intl packages `intl: ">=0.17.0 <0.19.0"`

## 5.2.2

- fix error message

## version: 5.2.3

- fix domain stored value, login form

## version: 5.2.4

- Removed 'created' and 'updated' fields from preferences records for better data management.

## version: 5.2.5

- Add firstOpen flag to SessionManagerSDK, true after login

## version: 5.3.0

- Env variable: LOCAL_IDENTITY_ADDRESS
- Defaults : ["https://localhost:10206", "https://local.identity.sfperusac.com:10206"];

## version: 5.4.0

- Identity store data
- Sync preferencias

## version: 5.5.0

- Sistencia proxy

## version: 5.6.0

- Servidor de logs http://localhost:30069

## version: 5.6.1

- fix: sqflite default factory warning

## version: 5.6.2

- fix: fix log server content type

## version: 5.6.3

- fix: fix log init

## version: 5.6.4

- fix: fix insert log

## version: 5.6.6

- fix: update devapp2

## version: 5.6.7

- fix: update devapp2

## version: 5.6.8

- fix: update libraries

## version: 5.7.0

- refactor: service

## version: 5.7.0

- fix soundpool

## version: 5.7.2

- replace soundpool to audioplayers

## version: 5.7.3

- Change preferencias server

## version: 5.8.0

- Refactorizacion

## version: 5.8.1

- Utilidades checkPermissions, checkAnyPermission y checkPermissionStartsWith

## version: 5.8.2

- Fix: AppPreferences

## version: 5.8.3

- Add onChange on CustomTextFormField

# version: 5.9.0

- Add ControlledText

# version: 5.10.0

- Add TrackedBinaryState

# version: 5.10.1

- TrackedBinaryState, add isEmpty and isNotEmpty

# version: 5.11.0

- Imanges picker, from file or camera

# version: 5.12.0

- add text styles

# version: 5.13.0

- add kdialogs source code

## version: 5.13.1

- implement entry storage using JSON structure under single key

## version: 5.13.2

- fix getEntry

## version: 5.13.3

- fix CustomTextFormField

## version: 5.13.4

- fix select options

## version: 5.13.5

- add dismissKeyboard flag to control auto unfocus behavior

## version: 5.13.6

- add getValueOrNull method to return null if empty and support optional trim

## version: 5.13.7

- add conditional getBytes/getBase64 methods

# version: 5.14.0

- add conditional getBytes/getBase64 methods

## version: 5.14.1

- add showAllowedDatesPicker

## version: 5.14.2

- fix appbar search

# version: 5.15.0

- feat: método download con soporte GET/POST

# version: 5.16.0

- Centraliza la gestión del menú principal y sus elementos, evitando que cada aplicativo maneje la lógica individualmente. Esto permite validar de forma centralizada y propagar las validaciones de manera más consistente

## version: 5.16.1

- fix package

## version: 5.16.2

- fix sync preferences
- define default theme

## version: 5.16.3

- fix prefs

## version: 5.16.5

- fix authority, en el query de licencias

## version: 5.16.6

- fix authority,esta es la buena

## version: 5.16.7

- Implemented type-safe read methods for bool, int, double, string, stringList, json, and raw
- Added normalization for boolean parsing using PostgreSQL-compatible values
- Handled values stored as JSON-encoded strings for all supported types
- Ensured single scalar values are wrapped in list for readStringList
- Removed unnecessary jsonDecode from native SharedPreferences types

## version: 5.16.8

- add script para generar keys de las preferencias

## version: 5.16.9

- fix preferences keys value

## version: 5.16.10

- fix input

# version: 5.17.0

- fix loading dialogs

# version: 5.17.1

- Uses HardwareKeyboard to capture key events from physical scanners
- Configurable scan timing, character filtering, and propagation control
- Triggers callback when valid scan is detected
- Supports Zebra TC15 and similar devices

# version: 5.17.2

- fix tracked bytes

# version: 5.17.3

- add X-Origin header

# version: 5.17.5

- fix null en preferencias
- la lectura de preferencias ahora devuelve un valor no null

# version: 5.17.6

- on refresh preferences event

# version: 5.18.0

- fix validacion de permisos
- about dialog

# version: 5.19.0

- fix sql upgrade

# version: 5.20.0

- add onSuffixIconLogTab

# version: 5.20.1

- fix api response error

# version: 5.20.2

- integracion url con manager sdk

# version: 5.20.3

- remove dotenv

# version: 5.21.0

- add InternetService for checking real internet connectivity

## 5.22.0

- Added database manager screen with support for listing, exporting (ZIP), and deleting local SQLite databases, including WAL/SHM files.
- Added bulk action to delete all local databases with confirmation.

## 5.22.1

- fix camera qr scan

## 5.22.2

- Agrega callback `onInputSettled` para ejecutar acciones cuando el input queda estable (debounce).
- Ejecuta `onInputSettled` también al perder foco y al hacer submit (incluye escaneo por PDA/QR).
- Dispara `onInputSettled` al inicio del widget (post-frame) para exponer el estado inicial.
- Permite configurar el delay vía `inputSettledDelay` (default: 500ms).
- Limpieza interna: cancelación de timers y listeners para evitar ejecuciones duplicadas y leaks.

## 5.22.3

- Permite copierar error

## 5.22.4

- fix exporta db name

## 5.22.5

- add service-id flag and improve error logging

## 5.22.6

- add base home page

## 5.22.7

- Se agregó soporte para queries con parámetros en `QueryController`.
- `QueryController` ahora utiliza dos genéricos `<T, Q>` para manejar el tipo de datos y el tipo de query.
- Se añadió soporte para `initialQuery`, `updateQuery` y `refetch`.
- `QueryView` fue actualizado para soportar el nuevo `QueryController<T, Q>`.
- Mejora en la flexibilidad del controlador para manejar requests dinámicos.

## 5.22.7

- QueryController recive un FutureOr

## 5.23.0

- Se añadió soporte para manejar `TimeOfDay` en `TextEditingCController`
- Se agregó el constructor `TextEditingCController.withTime`
- Se implementaron los métodos `setTime` y `getTimeOrNull`
- Las horas ahora se muestran al usuario en formato de 12 horas (`hh:mm AM/PM`)
- El valor interno de hora se almacena en formato `HH:mm`
- `getDatetimeOrNull` ahora puede interpretar valores de hora y devolver un `DateTime` con la fecha actual y la hora del controller
- Refactorización del controller para reducir duplicación de código y mejorar legibilidad

## 5.23.1

- fix

## 5.23.2

- fix

## 5.23.3

- Refactor `ControlledText` using `CustomTextControllerObserver`
- Extract controller text listening into reusable widget

## 5.23.4

- add setSelectOption method to CustomTextControllerObserver

## 5.24.0

- sqlite in memory

## 5.24.1

- fix Scaffold
