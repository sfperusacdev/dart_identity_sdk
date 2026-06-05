import 'package:dart_identity_sdk/dart_identity_sdk.dart';

final tableSyncConfig = TableSyncConfig(
  defaultServiceID: "com.sfperusac.tareoapp",
  groups: {
    "datos_generales": TableSyncGroup(
      title: "Datos generales",
      tables: ["descripcion_grupo", "presentacion"],
      every: const Duration(days: 1),
      syncOnStart: true,
    ),
    "supervisores": TableSyncGroup(
      title: "Supervisores",
      tables: ["tareo_supervisor", "tareo_supervisor_trabajador"],
      every: const Duration(days: 1),
      autoSync: false,
      syncOnStart: true,
    ),
    "trabajadores": TableSyncGroup(
      title: "Trabajadores",
      serviceID: "com.sfperusac.contratos",
      tables: ["trabajador"],
      every: const Duration(days: 1),
      syncOnStart: true,
    ),
    "grupos": TableSyncGroup(
      title: "Grupos",
      tables: [
        "grupo",
        "grupo_trabajador",
        "grupo_trabajador_salida",
        "asociacion_grupo",
        "asociacion_trabajador",
        "etiqueta",
      ],
      every: const Duration(minutes: 5),
      syncOnStart: true,
    ),
    "tareos": TableSyncGroup(
      title: "Tareos",
      tables: [
        "tareo",
        "grupo",
        "tareo_trabajador",
        "tareo_grupo",
        "etiqueta",
        "sub_etiqueta",
        "trabajador_tareo_bono",
      ],
      every: const Duration(minutes: 1),
      syncOnStart: true,
    ),
    "etiquetas": TableSyncGroup(
      title: "Etiquetas",
      tables: ["etiqueta", "sub_etiqueta"],
      every: const Duration(days: 1),
      autoSync: false,
    ),
    "consumidores": TableSyncGroup(
      title: "Consumidores",
      tables: ["consumidor"],
      every: const Duration(hours: 1),
      autoSync: false,
    ),
    "lotes": TableSyncGroup(
      title: "Lotes",
      tables: ["lote_nivel", "lote"],
      every: const Duration(days: 1),
      autoSync: false,
    ),
    "actividades": TableSyncGroup(
      title: "Actividades",
      tables: ["actividad", "labor"],
      every: const Duration(days: 1),
      autoSync: false,
    ),
    "cultivos": TableSyncGroup(
      title: "Cultivos",
      tables: ["cultivo", "variedad"],
      every: const Duration(days: 1),
      autoSync: false,
    ),
    "unidades": TableSyncGroup(
      title: "Unidades",
      tables: ["unidad_base", "unidad"],
      every: const Duration(days: 1),
      autoSync: false,
    ),
    "conceptos_bonos_horas": TableSyncGroup(
      title: "Conceptos Bonos y Horas",
      tables: ["concepto_bono", "concepto_horas_extra"],
      every: const Duration(hours: 1),
      autoSync: false,
    ),
    "campania": TableSyncGroup(
      title: "Campaña",
      tables: ["campania", "campania_unidad", "campania_presentacion"],
      every: const Duration(days: 1),
      autoSync: false,
    ),
  },
);
