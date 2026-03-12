class Cliente {
  final String id;
  final String nombre;
  final String apellido;
  final String telefono;
  final String? email;
  final String? direccion;
  final String? dpi;
  final String? fotoPath;
  final DateTime fechaRegistro;
  final bool activo;

  const Cliente({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.telefono,
    this.email,
    this.direccion,
    this.dpi,
    this.fotoPath,
    required this.fechaRegistro,
    this.activo = true,
  });

  String get nombreCompleto => '$nombre $apellido';

  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      apellido: map['apellido'] as String,
      telefono: map['telefono'] as String,
      email: map['email'] as String?,
      direccion: map['direccion'] as String?,
      dpi: map['dpi'] as String?,
      fotoPath: map['foto_path'] as String?,
      fechaRegistro: DateTime.parse(map['fecha_registro'] as String),
      activo: (map['activo'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'telefono': telefono,
      'email': email,
      'direccion': direccion,
      'dpi': dpi,
      'foto_path': fotoPath,
      'fecha_registro': fechaRegistro.toIso8601String(),
      'activo': activo ? 1 : 0,
    };
  }

  Cliente copyWith({
    String? id,
    String? nombre,
    String? apellido,
    String? telefono,
    String? email,
    String? direccion,
    String? dpi,
    String? fotoPath,
    DateTime? fechaRegistro,
    bool? activo,
  }) {
    return Cliente(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      direccion: direccion ?? this.direccion,
      dpi: dpi ?? this.dpi,
      fotoPath: fotoPath ?? this.fotoPath,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      activo: activo ?? this.activo,
    );
  }
}
