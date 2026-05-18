abstract interface class ImageRepository {
  /// HU-20 CA-1: sube una imagen al back y devuelve su URL pública.
  /// [filePath] es la ruta local del archivo seleccionado por el usuario.
  Future<String> upload(String filePath);

  /// HU-20 CA-3: elimina una imagen del servidor.
  /// [filename] es el nombre UUID devuelto en la URL (ej. "a1b2c3.jpg").
  /// Solo puede borrarla quien la subió (el back verifica ownership).
  Future<void> delete(String filename);
}