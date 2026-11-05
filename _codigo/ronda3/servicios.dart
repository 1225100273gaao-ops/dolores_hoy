import '../dominio/excepciones.dart';
import '../dominio/modelos.dart';
import 'cliente_seguro.dart';

class ServicioClima {
  final ClienteSeguro _c;
  ServicioClima(this._c);

  Future<Clima> actual({double lat = 21.1561, double lon = -100.9319}) async {
    if (lat < -90 || lat > 90 || lon < -180 || lon > 180) {
      throw const EntradaInvalidaException('coordenadas fuera de rango');
    }
    final json = await _c.obtenerJson(Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': '$lat',
      'longitude': '$lon',
      'current': 'temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m',
      'timezone': 'America/Mexico_City',
    }));
    return convertir(() => Clima.desdeJson(json as Map<String, dynamic>));
  }
}
