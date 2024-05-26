import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

Future<bool> requestLocationPermission() async {
  final locationStatus = await Permission.locationWhenInUse.request();
  return locationStatus.isGranted;
  // if (locationStatus.isGranted) {
  //   print('Location permission granted');
  // } else if (locationStatus.isDenied) {
  //   print('Location permission denied');
  // }
}

Future<Position?> getCurrentLocation() async {
  final locationData = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      forceAndroidLocationManager: true);
  print(locationData.latitude);
  return locationData;
}

String handleDioError(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionError:
      return "Have on Internet or Server down";
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      // Handle network timeout errors
      return "time out";
    case DioExceptionType.cancel:
      return "request cancelled";
    case DioExceptionType.badResponse:
      // Handle server response errors (e.g., status codes)
      return _handleResponseError(error.response!);
    default:
      // Handle other Dio-related errors
      return 'Other Dio error: ${error.message}';
  }
}

String _handleResponseError(Response response) {
  if (response.statusCode == 400) {
    return response.data['message'] ?? response.data['msg'];
  } else if (response.statusCode == 404) {
    return response.data['message'] ?? response.data['msg'];
  } else if (response.statusCode == 500) {
    return 'Internal server error';
  } else {
    return 'Error: ${response.statusCode}';
  }
}

enum ErrorType { timeout, noconnect, pagenotfound }
