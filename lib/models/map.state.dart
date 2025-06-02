import 'package:latlong2/latlong.dart';

class MapState {
  final LatLng? currentLocation;
  final LatLng? destination;
  final List<LatLng> route;
  final List<Map<String, dynamic>> markets;
  final bool isLoading;
  final String? errorMessage;

  MapState({
    this.currentLocation,
    this.destination,
    this.route = const [],
    this.markets = const [],
    this.isLoading = true,
    this.errorMessage,
  });

  MapState copyWith({
    LatLng? currentLocation,
    LatLng? destination,
    List<LatLng>? route,
    List<Map<String, dynamic>>? markets,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MapState(
      currentLocation: currentLocation ?? this.currentLocation,
      destination: destination ?? this.destination,
      route: route ?? this.route,
      markets: markets ?? this.markets,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
