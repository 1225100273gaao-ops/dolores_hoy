String? soloHttps(Object? url) =>
    url is String && url.startsWith('https://') ? url : null;

class Clima {
  final double temperatura;
  final int humedad;
  final double viento;
  final int codigo;
  const Clima(this.temperatura, this.humedad, this.viento, this.codigo);

  factory Clima.desdeJson(Map<String, dynamic> json) {
    final c = json['current'] as Map<String, dynamic>;
    return Clima(
      (c['temperature_2m'] as num).toDouble(),
      (c['relative_humidity_2m'] as num).round(),
      (c['wind_speed_10m'] as num).toDouble(),
      (c['weather_code'] as num).toInt(),
    );
  }
}

(String, String) describirClima(int codigo) {
  if (codigo == 0) return ('☀️', 'Despejado');
  if (codigo <= 3) return ('⛅', 'Parcialmente nublado');
  if (codigo == 45 || codigo == 48) return ('🌫', 'Niebla');
  if (codigo >= 51 && codigo <= 57) return ('🌦', 'Llovizna');
  if (codigo >= 61 && codigo <= 67) return ('🌧', 'Lluvia');
  if (codigo >= 71 && codigo <= 77) return ('❄️', 'Nieve');
  if (codigo >= 80 && codigo <= 82) return ('🌧', 'Chubascos');
  if (codigo >= 95) return ('⛈️', 'Tormenta');
  return ('🌡', 'Clima variable');
}
