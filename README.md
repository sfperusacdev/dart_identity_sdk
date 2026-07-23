## JUST PLAY SDK

Para usar el SDK en Android, agrega estas declaraciones dentro del `<manifest>`
de la aplicación host:

```xml
<uses-permission android:name="shared_preferences.permission.WRITE_DATA" />
<uses-permission android:name="shared_preferences.permission.READ_DATA" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
<uses-permission android:name="android.permission.READ_PRIVILEGED_PHONE_STATE" />
<uses-permission android:name="android.permission.VIBRATE" />

<queries>
    <package android:name="com.sfperusac.manager" />
</queries>
<queries>
    <provider android:authorities="com.sfperusac.manager.licencias" />
</queries>
```
