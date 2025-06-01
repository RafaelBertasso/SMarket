import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final MapController _mapController = MapController();
  final Location _location = Location();
  final TextEditingController _locationController = TextEditingController();

  bool isLoading = true;

  LatLng? _currentLocation;
  LatLng? _destination;
  List<LatLng> _route = [];
  List<Map<String, dynamic>> _markets = [];

  @override
  void initState() {
    super.initState();
    _initializeLocation().then((_) {
      _findMarketsOSM();
    });
  }

  Future<void> _findMarketsOSM() async {
    final query = '''
[out:json];
area["name"="São José do Rio Preto"]->.searchArea;
(
  node["shop"="supermarket"](area.searchArea);
  way["shop"="supermarket"](area.searchArea);
  relation["shop"="supermarket"](area.searchArea);
);
out center;
''';

    final url = Uri.parse("https://overpass-api.de/api/interpreter");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: "data=$query",
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final elements = data['elements'] as List<dynamic>;

      setState(() {
        _markets =
            elements.map((e) {
              final lat = e['lat'] ?? e['center']['lat'];
              final lon = e['lon'] ?? e['center']['lon'];
              return {
                "name": e['tags']['name'] ?? 'Supermercado',
                "location": LatLng(lat, lon),
              };
            }).toList();
      });
    } else {
      errorMessage('Erro ao buscar mercados do OpenStreetMap.');
    }
  }

  Future<String> _getAddressFromCoordinates(LatLng coordinates) async {
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
        if (suburb.isNotEmpty) {
          formattedAddress += '\n$suburb';
        }
        if (postcode.isNotEmpty) {
          formattedAddress += ' - $postcode';
        }
        if (city.isNotEmpty) {
          formattedAddress += '\n$city';
        }
        if (state.isNotEmpty) {
          formattedAddress += '/${_getStateAbbreviation(state)}';
        }

        return formattedAddress.trim();
      } else {
        return 'Erro ao obter endereço';
      }
    } catch (e) {
      return 'Erro de rede';
    }
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

  Future<void> _initializeLocation() async {
    if (!await _checkAndRequestPermissions()) return;

    try {
      final locationData = await _location.getLocation();

      setState(() {
        _currentLocation = LatLng(
          locationData.latitude!,
          locationData.longitude!,
        );
        isLoading = false;
      });

      _location.onLocationChanged.listen((locationData) {
        setState(() {
          _currentLocation = LatLng(
            locationData.latitude!,
            locationData.longitude!,
          );
        });
      });
    } catch (e) {
      errorMessage("Erro ao obter a localização.");
      setState(() => isLoading = false);
    }
  }

  Future<bool> _checkAndRequestPermissions() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        errorMessage('Serviço de localização desativado.');
        return false;
      }
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        errorMessage('Permissão de localização negada.');
        return false;
      }
    }

    return true;
  }

  Future<void> _fetchCoordinatesPoint(String location) async {
    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/search?q=$location&format=json&limit=1",
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);
        setState(() {
          _destination = LatLng(lat, lon);
        });
        await _fetchRoute();
      } else {
        errorMessage('Localização não encontrada.');
      }
    } else {
      errorMessage('Erro ao buscar localização.');
    }
  }

  Future<void> _fetchRoute() async {
    if (_currentLocation == null || _destination == null) return;

    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/${_currentLocation!.longitude},${_currentLocation!.latitude};${_destination!.longitude},${_destination!.latitude}?overview=full&geometries=polyline',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final geometry = data['routes'][0]['geometry'];
      _decodePolyline(geometry);
    } else {
      errorMessage('Erro ao buscar rota.');
    }
  }

  void _decodePolyline(String encodedPolyline) {
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPoints = polylinePoints.decodePolyline(
      encodedPolyline,
    );

    setState(() {
      _route =
          decodedPoints
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();
      _mapController.move(_currentLocation!, 15);
    });
  }

  void errorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 2)),
    );
  }

  Future<void> _userCurrentLocation() async {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 15);
    } else {
      errorMessage('Localização atual não disponível.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Encontre mercados',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          isLoading
              ? Center(child: CircularProgressIndicator())
              : FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _currentLocation ?? LatLng(-20.8119, -49.3762),
                  initialZoom: 14.0,
                  minZoom: 3.0,
                  maxZoom: 18.0,
                  onTap: (_, __) => FocusScope.of(context).unfocus(),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  ),
                  CurrentLocationLayer(
                    style: LocationMarkerStyle(
                      marker: DefaultLocationMarker(
                        child: Icon(Icons.location_pin, color: Colors.white),
                      ),
                      markerSize: Size(35, 35),
                      markerDirection: MarkerDirection.heading,
                    ),
                  ),
                  if (_markets.isNotEmpty)
                    MarkerLayer(
                      markers:
                          _markets.map((market) {
                            return Marker(
                              point: market['location'],
                              width: 40,
                              height: 40,
                              child: GestureDetector(
                                onTap: () async {
                                  final address =
                                      await _getAddressFromCoordinates(
                                        market['location'],
                                      );
                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          backgroundColor: Colors.white,
                                          title: Text(
                                            market['name'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          content: Text(
                                            address,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          actionsPadding: const EdgeInsets.only(
                                            right: 16,
                                            bottom: 12,
                                          ),
                                          actionsAlignment:
                                              MainAxisAlignment.end,
                                          actions: [
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                foregroundColor:
                                                    Colors.redAccent,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 10,
                                                    ),
                                              ),
                                              onPressed:
                                                  () => Navigator.pop(context),
                                              child: const Text(
                                                'Cancelar',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 10,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              onPressed: () async {
                                                Navigator.pop(context);
                                                setState(() {
                                                  _destination =
                                                      market['location'];
                                                });
                                                await _fetchRoute();
                                              },
                                              child: const Text(
                                                'Rota',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ),
                                          ],
                                        ),
                                  );
                                },
                                child: Icon(
                                  Icons.shopping_cart,
                                  color: Colors.blue,
                                  size: 30,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  if (_route.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _route,
                          strokeWidth: 4.0,
                          color: Colors.red,
                        ),
                      ],
                    ),
                  Positioned(
                    top: 10,
                    right: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return Iterable<String>.empty();
                          }
                          return _markets
                              .map((market) => market['name'].toString())
                              .where(
                                (name) => name.toLowerCase().contains(
                                  textEditingValue.text.toLowerCase(),
                                ),
                              )
                              .toList();
                        },
                        fieldViewBuilder: (
                          context,
                          controller,
                          focusNode,
                          onFieldSubmitted,
                        ) {
                          _locationController.text = controller.text;
                          return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Digite o nome do mercado',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                            ),
                            onSubmitted: (value) {
                              if (value.isNotEmpty) {
                                _fetchCoordinatesPoint(value);
                              } else {
                                errorMessage('Por favor, digite um local.');
                              }
                            },
                          );
                        },
                        onSelected: (String selectedName) async {
                          final selectedMarket = _markets.firstWhere(
                            (market) => market['name'] == selectedName,
                          );

                          final location = selectedMarket['location'] as LatLng;
                          final address = await _getAddressFromCoordinates(
                            location,
                          );

                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  backgroundColor: Colors.white,
                                  title: Text(
                                    selectedName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  content: Text(
                                    address,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  actionsPadding: EdgeInsets.only(
                                    right: 16,
                                    bottom: 12,
                                  ),
                                  actionsAlignment: MainAxisAlignment.end,
                                  actions: [
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.redAccent,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 10,
                                        ),
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        'Cancelar',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 10,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        setState(() {
                                          _destination = location;
                                        });
                                        await _fetchRoute();
                                      },
                                      child: Text(
                                        'Rota',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _userCurrentLocation,
        backgroundColor: Colors.blue,
        child: Icon(Icons.my_location_outlined, size: 30, color: Colors.white),
      ),
    );
  }
}
