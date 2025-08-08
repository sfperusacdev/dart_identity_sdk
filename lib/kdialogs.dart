import 'package:kdialogs/kdialogs.dart';

void initKDialogStrings() {
  setKDialogStrings(
    KDialogStrings(
      acceptButtonText: "ACEPTAR",
      confirmButtonText: "CONFIRMAR",
      cancelButtonText: "CANCELAR",
      saveButtonText: "Guardar",
      confirmationMessage:
          "¿Estás seguro de que deseas continuar con esta operación?",
      errorRetryText: "REINTENTAR",
      searchLabelInputText: "Buscar",
      bottomErrorAlertTitle: "Error, algo salió mal...",
      confirmDialogText: "Antes de continuar, confirma esta acción.",
      defaultDialogTitle: "¡Título!",
      loadingDialogMessage: "Cargando, por favor espera...",
    ),
  );
}
