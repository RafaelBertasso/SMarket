import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:smarket/components/loading_indication.dart';
import 'package:smarket/components/market_details_dialog.dart';
import 'package:smarket/components/market_marker.dart';
import 'package:smarket/controllers/markets.controller.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final MarketsController _controller = MarketsController();

  @override
  void initState() {
    super.initState();
    _controller.initialize();
    _controller.addListener(_handleStateChange);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleStateChange);
    _controller.dispose();
    super.dispose();
  }

  void _handleStateChange() {
    if (_controller.state.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_controller.state.errorMessage!)),
        );
        _controller.clearError();
      });
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Text(""),
        centerTitle: true,
        title: Text(
          'Encontre mercados',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: Stack(
        children: [
          _controller.state.isLoading
              ? LoadingIndicator()
              : FlutterMap(
                mapController: _controller.mapController,
                options: MapOptions(
                  initialCenter:
                      _controller.state.currentLocation ??
                      LatLng(-20.8119, -49.3762),
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
                  if (_controller.state.markets.isNotEmpty)
                    MarkerLayer(
                      markers:
                          _controller.state.markets.map((market) {
                            return Marker(
                              point: market['location'],
                              width: 40,
                              height: 40,
                              child: MarketMarkerContent(
                                onTap: () async {
                                  final address = await _controller
                                      .getAddressFromCoordinates(
                                        market['location'],
                                      );
                                  showDialog(
                                    context: context,
                                    builder:
                                        (_) => MarketDetailsDialog(
                                          marketName: market['name'],
                                          address: address,
                                          onRouteRequested:
                                              () => _controller
                                                  .fetchRouteToMarket(
                                                    market['location'],
                                                  ),
                                        ),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                    ),
                  if (_controller.state.route.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _controller.state.route,
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
                            return const Iterable<String>.empty();
                          }
                          return _controller.state.markets
                              .where(
                                (market) =>
                                    '${market['name']} ${market['address']}'
                                        .toLowerCase()
                                        .contains(
                                          textEditingValue.text.toLowerCase(),
                                        ),
                              )
                              .map(
                                (market) =>
                                    '${market['name']} - ${market['address']}',
                              )
                              .toList();
                        },
                        onSelected: (String selectedOption) async {
                          final selectedMarket = _controller.state.markets
                              .firstWhere(
                                (market) =>
                                    '${market['name']} - ${market['address']}' ==
                                    selectedOption,
                                orElse:
                                    () => {
                                      'name': 'Mercado não encontrado',
                                      'location': LatLng(0, 0),
                                      'address': 'Endereço não disponível',
                                      'fullAddress':
                                          'Não foi possível obter o endereço completo',
                                    },
                              );
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  icon: Icon(Icons.search),
                                  title: Text('${selectedMarket['name']}'),
                                  content: Text(
                                    '${selectedMarket['fullAddress']}',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Fechar'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _controller.fetchRouteToMarket(
                                          selectedMarket['location'],
                                        );
                                      },
                                      child: const Text('Traçar Rota'),
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
        onPressed: _controller.moveToCurrentLocation,
        backgroundColor: Colors.blue,
        child: Icon(Icons.my_location_outlined, size: 30, color: Colors.white),
      ),
    );
  }
}
