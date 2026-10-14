import '../models/cuota_compromiso_model.dart';
import '../models/pago_compromiso_model.dart';
import '../models/frequence_model.dart';

// Modelo para los compromisos
class CompromiseModel {
  final String id;
  final String name;
  final double amount;
  final String date;
  final String? tipoCompromiso;
  final int? idusuario;
  final int? idcuenta;
  final int? idtercero;
  final String? nombreTercero;
  final int? idfrecuencia;
  final double? montoTotal;
  final int? cantidadCuotas;
  final double? montoCuota;
  final int? cuotasPagadas;
  final double? tasaInteres;
  final String? tipoInteres;
  final String? fechaTermino;
  final String? estado;
  final int? estadoEliminar;
  final FrecuenciaModel? frecuencia;
  final double? montoTotalPagado;
  final List<CuotaCompromisoModel> cuotas;
  final List<PagoCompromisoModel> pagos;

  CompromiseModel({
    required this.id,
    required this.name,
    required this.amount, // <-- Se espera un double
    required this.date,
    this.tipoCompromiso,
    this.idusuario,
    this.idcuenta,
    this.idtercero,
    this.nombreTercero,
    this.idfrecuencia,
    this.montoTotal,
    this.cantidadCuotas,
    this.montoCuota,
    this.cuotasPagadas,
    this.tasaInteres,
    this.tipoInteres,
    this.fechaTermino,
    this.estado,
    this.estadoEliminar,
    this.frecuencia,
    this.montoTotalPagado,
    this.cuotas = const [],
    this.pagos = const [],
  });

  factory CompromiseModel.fromJson(Map<String, dynamic> json) {
    double? _toDouble(dynamic value) {
      if (value == null) return null;
      if (value is String) return double.tryParse(value);
      if (value is num) return value.toDouble();
      return null;
    }

    int? _toInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      return int.tryParse(value.toString());
    }

    List<CuotaCompromisoModel> parsedCuotas = [];
    if (json['cuotas'] != null && json['cuotas'] is List) {
      parsedCuotas = (json['cuotas'] as List)
          .map((cuotaJson) => CuotaCompromisoModel.fromJson(cuotaJson))
          .toList();
    }

    List<PagoCompromisoModel> parsedPagos = [];
    if (json['pagos'] != null && json['pagos'] is List) {
      parsedPagos = (json['pagos'] as List)
          .map((pagoJson) => PagoCompromisoModel.fromJson(pagoJson))
          .toList();
    }

    return CompromiseModel(
      id: json['id']?.toString() ?? '',
      name: json['nombre'] as String? ?? 'Sin Nombre',
      amount: _toDouble(json['monto_cuota']) ?? 0.0,
      date: json['fecha_inicio'] as String? ?? '',
      tipoCompromiso: json['tipo_compromiso'] as String?,
      idusuario: _toInt(json['idusuario']),
      idcuenta: _toInt(json['idcuenta']),
      idtercero: _toInt(json['idtercero']),
      nombreTercero: json['tercero'] != null ? json['tercero']['nombre'] : null,
      idfrecuencia: _toInt(json['idfrecuencia']),
      montoTotal: _toDouble(json['monto_total']),
      cantidadCuotas: _toInt(json['cantidad_cuotas']),
      montoCuota: _toDouble(json['monto_cuota']),
      cuotasPagadas: _toInt(json['cuotas_pagadas']),
      montoTotalPagado: _toDouble(json['pagos_sum_monto']),
      tasaInteres: _toDouble(json['tasa_interes']),
      tipoInteres: json['tipo_interes'] as String?,
      fechaTermino: json['fecha_termino'] as String?,
      estado: json['estado'] as String?,
      estadoEliminar: _toInt(json['estado_eliminar']),
      frecuencia: json['frecuencia'] != null
          ? FrecuenciaModel.fromJson(json['frecuencia'])
          : null,
      cuotas: parsedCuotas,
      pagos: parsedPagos,
    );
  }
}