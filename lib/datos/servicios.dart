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

class ServicioCambio {
  final ClienteSeguro _c;
  ServicioCambio(this._c);

  Future<TipoCambio> deMxn() async {
    final json = await _c.obtenerJson(Uri.https('api.frankfurter.dev', '/v1/latest', {
      'base': 'MXN',
      'symbols': 'USD,EUR',
    }));
    return convertir(() => TipoCambio.desdeJson(json as Map<String, dynamic>));
  }
}

class ServicioFestivos {
  final ClienteSeguro _c;
  ServicioFestivos(this._c);

  Future<List<Festivo>> proximos({int? anio, DateTime? hoy, int cuantos = 3}) async {
    final ahora = hoy ?? DateTime.now();
    final a = anio ?? ahora.year;
    if (a < 2000 || a > 2100) {
      throw const EntradaInvalidaException('año fuera de rango');
    }
    final json = await _c.obtenerJson(Uri.https('date.nager.at',
        '/api/v3/PublicHolidays/$a/MX'));
    final todos = convertir(() => (json as List)
        .map((e) => Festivo.desdeJson(e as Map<String, dynamic>))
        .toList());
    final dia = DateTime(ahora.year, ahora.month, ahora.day);
    final futuros = todos.where((f) => !f.fecha.isBefore(dia)).toList()
      ..sort((x, y) => x.fecha.compareTo(y.fecha));
    return futuros.take(cuantos).toList();
  }
}

class ServicioWikipedia {
  final ClienteSeguro _c;
  ServicioWikipedia(this._c);

  static String normalizarTema(String tema) {
    final t = tema.trim();
    if (t.isEmpty) throw const EntradaInvalidaException('escribe un tema');
    if (t.length > 80) throw const EntradaInvalidaException('tema demasiado largo');
    if (t.contains(RegExp(r'[\x00-\x1F]'))) {
      throw const EntradaInvalidaException('caracteres no permitidos');
    }
    return t.replaceAll(' ', '_');
  }

  Future<ResumenWiki> resumen(String tema) async {
    final t = normalizarTema(tema);
    final uri = Uri(
      scheme: 'https',
      host: 'es.wikipedia.org',
      pathSegments: ['api', 'rest_v1', 'page', 'summary', t],
    );
    final json = await _c.obtenerJson(uri);
    return convertir(() => ResumenWiki.desdeJson(json as Map<String, dynamic>));
  }
}
