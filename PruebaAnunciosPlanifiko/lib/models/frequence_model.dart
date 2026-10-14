// Modelo para las frecuencias
class FrecuenciaModel {
  final int id;
  final String nombre;

  FrecuenciaModel({
    required this.id,
    required this.nombre,
  });

  factory FrecuenciaModel.fromJson(Map<String, dynamic> json) {
    return FrecuenciaModel(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? 'Sin Nombre',
    );
  }
}