import 'package:flutter/material.dart';

class TableSyncSettingsBox extends StatefulWidget {
  final bool autoSync;
  final Duration every;
  final Future<void> Function(bool autoSync, Duration every) onSave;

  const TableSyncSettingsBox({
    super.key,
    required this.autoSync,
    required this.every,
    required this.onSave,
  });

  @override
  State<TableSyncSettingsBox> createState() => _TableSyncSettingsBoxState();
}

class _TableSyncSettingsBoxState extends State<TableSyncSettingsBox> {
  late bool _autoSync;
  late int _everyMinutes;

  @override
  void initState() {
    super.initState();
    _autoSync = widget.autoSync;
    _everyMinutes = widget.every.inMinutes < 1 ? 1 : widget.every.inMinutes;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Sincronizado automatico'),
            trailing: Switch(
              activeThumbColor: Theme.of(context).primaryColor,
              value: _autoSync,
              onChanged: (value) => setState(() => _autoSync = value),
            ),
          ),
          Visibility(
            visible: _autoSync,
            replacement: const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                'Sincronizado automatico desactivado',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            child: DropdownButton<int>(
              isExpanded: true,
              value:
                  _durationOptions.contains(_everyMinutes) ? _everyMinutes : 1,
              items: const [
                DropdownMenuItem(value: 1, child: Text('1 minuto')),
                DropdownMenuItem(value: 2, child: Text('2 minutos')),
                DropdownMenuItem(value: 5, child: Text('5 minutos')),
                DropdownMenuItem(value: 10, child: Text('10 minutos')),
                DropdownMenuItem(value: 15, child: Text('15 minutos')),
                DropdownMenuItem(value: 20, child: Text('20 minutos')),
                DropdownMenuItem(value: 30, child: Text('30 minutos')),
                DropdownMenuItem(value: 60, child: Text('1 hora')),
                DropdownMenuItem(value: 120, child: Text('2 horas')),
                DropdownMenuItem(value: 300, child: Text('5 horas')),
                DropdownMenuItem(value: 720, child: Text('12 horas')),
                DropdownMenuItem(value: 1440, child: Text('1 dia')),
              ],
              onChanged: (value) => setState(() => _everyMinutes = value ?? 1),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                color: Colors.grey,
              ),
              TextButton.icon(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await widget.onSave(
                      _autoSync, Duration(minutes: _everyMinutes));
                },
                icon: const Icon(Icons.save),
                label: const Text('Guardar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

const _durationOptions = [1, 2, 5, 10, 15, 20, 30, 60, 120, 300, 720, 1440];
