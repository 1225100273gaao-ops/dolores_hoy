import 'package:dolores_hoy/datos/servicios.dart';
import 'package:dolores_hoy/dominio/excepciones.dart';
import 'package:dolores_hoy/dominio/modelos.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudas.dart';

void main() {
  group('API 1 · Clima (Open-Meteo)', () {
    test('convierte la respuesta en Clima', () async {
      final s = ServicioClima(seguro((req) async {
        expect(req.url.host, 'api.open-meteo.com');
        expect(req.url.queryParameters['latitude'], '21.1561');
        return jsonOk(jsonClima);
      }));
      final c = await s.actual();
      expect(c.temperatura, 24.3);
      expect(c.humedad, 41);
      expect(c.codigo, 1);
    });

    test('rechaza coordenadas fuera de rango', () {
      final s = ServicioClima(seguro((_) async => jsonOk(jsonClima)));
      expect(s.actual(lat: 200), throwsA(isA<EntradaInvalidaException>()));
    });

    test('si falta el bloque current lanza RespuestaInvalida', () {
      final s = ServicioClima(seguro((_) async => jsonOk({'otra': 1})));
      expect(s.actual(), throwsA(isA<RespuestaInvalidaException>()));
    });

    test('describirClima traduce códigos', () {
      expect(describirClima(0).$2, 'Despejado');
      expect(describirClima(63).$2, 'Lluvia');
      expect(describirClima(95).$2, 'Tormenta');
    });
  });
}
