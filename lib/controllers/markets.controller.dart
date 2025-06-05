import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:smarket/models/map.state.dart';

class MarketsController extends ChangeNotifier {
  final MapController mapController = MapController();
  final Location _location = Location();
  MapState _state = MapState();
  final TextEditingController searchController = TextEditingController();

  MapState get state => _state;

  Future<void> initialize() async {
    await _initializeLocation();
    await findMarketsOSM();
  }

  Future<void> _initializeLocation() async {
    if (!await _checkAndRequestPermissions()) return;

    try {
      final locationData = await _location.getLocation();
      _updateState(
        _state.copyWith(
          currentLocation: LatLng(
            locationData.latitude!,
            locationData.longitude!,
          ),
          isLoading: false,
        ),
      );

      _location.onLocationChanged.listen((locationData) {
        _updateState(
          _state.copyWith(
            currentLocation: LatLng(
              locationData.latitude!,
              locationData.longitude!,
            ),
          ),
        );
      });
    } catch (e) {
      _updateState(
        _state.copyWith(
          isLoading: false,
          errorMessage: "Erro ao obter a localização",
        ),
      );
    }
  }

  Future<void> findMarketsOSM() async {
    const query = '''
[out:json];
area["name"="São José do Rio Preto"]->.searchArea;
(
  node["shop"="supermarket"](area.searchArea);
  way["shop"="supermarket"](area.searchArea);
  relation["shop"="supermarket"](area.searchArea);
);
out center;
''';

    try {
      final url = Uri.parse("https://overpass-api.de/api/interpreter");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: "data=$query",
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final elements = data['elements'] as List<dynamic>;
        final List<Map<String, dynamic>> loadedMarkets = [];

        for (var e in elements) {
          final lat = e['lat'] ?? e['center']['lat'];
          final lon = e['lon'] ?? e['center']['lon'];
          final location = LatLng(lat, lon);

          final fullAddress = await getAddressFromCoordinates(location);
          final road = fullAddress.split(',').first.trim();

          loadedMarkets.add({
            "name": e['tags']?['name']?.toString() ?? 'Supermercado',
            "location": location,
            "address": road.isNotEmpty ? road : 'Endereço não disponível',
            "fullAddress": fullAddress,
          });
        }

        _updateState(_state.copyWith(markets: loadedMarkets));
      }
    } catch (e) {
      _updateState(
        _state.copyWith(
          errorMessage: 'Erro ao carregar mercados: ${e.toString()}',
        ),
      );
    }
  }

  Future<String> getAddressFromCoordinates(LatLng coordinates) async {
    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/reverse?format=json&lat=${coordinates.latitude}&lon=${coordinates.longitude}",
    );
    try {
      final response = await http.get(
        url,
        headers: {'User-Agent': 'SMarketApp/1.0'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];
        final formatted = _formatAddress(address);
        return (formatted.trim().isNotEmpty)
            ? formatted
            : 'Endereço não disponível';
      }
      return 'Erro ao obter endereço';
    } catch (e) {
      return 'Erro de rede';
    }
  }

  String _formatAddress(Map<String, dynamic> address) {
    final city = address['city'] ?? address['town'] ?? '';
    final state = address['state'] ?? '';
    final houseNumber = address['house_number'] ?? '';
    final suburb = address['suburb'] ?? '';
    final postcode = address['postcode'] ?? '';
    final road = address['road'] ?? '';

    String formattedAddress = '';
    if (road.isNotEmpty || houseNumber.isNotEmpty) {
      formattedAddress = '$road, $houseNumber';
    }
    if (suburb.isNotEmpty) formattedAddress += '\n$suburb';
    if (postcode.isNotEmpty) formattedAddress += ' - $postcode';
    if (city.isNotEmpty) formattedAddress += '\n$city';
    if (state.isNotEmpty)
      formattedAddress += '/${_getStateAbbreviation(state)}';

    return formattedAddress.trim();
  }

  String _getStateAbbreviation(String state) {
    const map = {
      'Acre': 'AC',
      'Alagoas': 'AL',
      'Amapá': 'AP',
      'Amazonas': 'AM',
      'Bahia': 'BA',
      'Ceará': 'CE',
      'Distrito Federal': 'DF',
      'Espírito Santo': 'ES',
      'Goiás': 'GO',
      'Maranhão': 'MA',
      'Mato Grosso': 'MT',
      'Mato Grosso do Sul': 'MS',
      'Minas Gerais': 'MG',
      'Pará': 'PA',
      'Paraíba': 'PB',
      'Paraná': 'PR',
      'Pernambuco': 'PE',
      'Piauí': 'PI',
      'Rio de Janeiro': 'RJ',
      'Rio Grande do Norte': 'RN',
      'Rio Grande do Sul': 'RS',
      'Rondônia': 'RO',
      'Roraima': 'RR',
      'Santa Catarina': 'SC',
      'São Paulo': 'SP',
      'Sergipe': 'SE',
      'Tocantins': 'TO',
    };
    return map[state] ?? state;
  }

  Future<bool> _checkAndRequestPermissions() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return false;
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return false;
    }
    return true;
  }

  Future<void> fetchCoordinatesPoint(String location) async {
    try {
      final url = Uri.parse(
        "https://nominatim.openstreetmap.org/search?q=$location&format=json&limit=1",
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          _updateState(_state.copyWith(destination: LatLng(lat, lon)));
          await fetchRoute();
        } else {
          _updateState(
            _state.copyWith(errorMessage: 'Localização não encontrada.'),
          );
        }
      } else {
        _updateState(
          _state.copyWith(errorMessage: 'Erro ao buscar localização.'),
        );
      }
    } catch (e) {
      _updateState(
        _state.copyWith(errorMessage: 'Erro na conexão com o servidor.'),
      );
    }
  }

  Future<void> fetchRoute() async {
    if (_state.currentLocation == null || _state.destination == null) return;

    try {
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/${_state.currentLocation!.longitude},${_state.currentLocation!.latitude};${_state.destination!.longitude},${_state.destination!.latitude}?overview=full&geometries=polyline',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final geometry = data['routes'][0]['geometry'];
        _decodePolyline(geometry);
      } else {
        _updateState(_state.copyWith(errorMessage: 'Erro ao buscar rota.'));
      }
    } catch (e) {
      _updateState(_state.copyWith(errorMessage: 'Erro ao traçar a rota.'));
    }
  }

  void _decodePolyline(String encodedPolyline) {
    final decodedPoints = PolylinePoints().decodePolyline(encodedPolyline);
    final route =
        decodedPoints
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();

    _updateState(_state.copyWith(route: route));
    mapController.move(_state.currentLocation!, 15);
  }

  Future<void> moveToCurrentLocation() async {
    if (_state.currentLocation != null) {
      mapController.move(_state.currentLocation!, 15);
    } else {
      _updateState(
        _state.copyWith(errorMessage: 'Localização atual não disponível.'),
      );
    }
  }

  void clearError() {
    _updateState(_state.copyWith(errorMessage: null));
  }

  void _updateState(MapState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> fetchRouteToMarket(LatLng marketLocation) async {
    _updateState(_state.copyWith(destination: marketLocation));
    await fetchRoute();
  }
}
