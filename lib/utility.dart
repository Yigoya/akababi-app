import 'dart:convert';
import 'dart:io';

import 'package:akababi/pages/post/SinglePostPage.dart';
import 'package:akababi/pages/profile/cubit/profile_cubit.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';

Dio getDio() {
  final client = HttpClient();
  client.badCertificateCallback =
      (X509Certificate cert, String host, int port) {
    return true; // Accept any certificate during development
  };
  var dio = Dio();

  // Use IOHttpClientAdapter to configure the HttpClient
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      return client;
    },
  );

  return dio;
}

Future<Map<String, String>?> getCityAndCountry(
    double latitude, double longitude) async {
  try {
    // Fetch the list of placemarks at the given latitude and longitude
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);

    if (placemarks.isNotEmpty) {
      // Extract city/town and country from the first placemark
      Placemark place = placemarks.first;
      String city = place.locality ?? place.subLocality ?? '';
      String country = place.country ?? '';

      return {
        'city': city,
        'country': country,
      };
    } else {
      throw Exception('No placemarks found');
    }
  } catch (e) {
    return null;
  }
}

String formatDateTime(String dateString) {
  final DateTime dateTime = DateTime.parse(dateString);
  final DateTime now = DateTime.now();
  final Duration difference = now.difference(dateTime);

  // If the difference is less than a day, use the "time ago" format
  if (difference.inDays < 1) {
    return timeago.format(dateTime, locale: 'en_short');
  } else {
    // Otherwise, format the date as "21 Jul 2024"
    final DateFormat formatter = DateFormat('dd MMM yyyy');
    return formatter.format(dateTime);
  }
}

void main() {
  print(formatDateTime(
      '2024-07-02T07:11:39.000Z')); // Output: "20 seconds ago" or "21 Jul 2024"
}

Position defaultLocation = Position(
  longitude: 38.7781448, // Example longitude value
  latitude: 8.9631768, // Example latitude value
  timestamp: DateTime.now(), // Current timestamp
  accuracy: 0.0, // Example accuracy value
  altitude: 0.0, // Example altitude value
  altitudeAccuracy: 0.0, // Example altitude accuracy value
  heading: 0.0, // Example heading value
  headingAccuracy: 0.0, // Example heading accuracy value
  speed: 0.0, // Example speed value
  speedAccuracy: 0.0, // Example speed accuracy value
);

/// Opens Google Maps with the specified latitude and longitude.
///
/// This function generates a Google Maps URL using the provided latitude and longitude,
/// and attempts to launch the URL. If the URL can be launched, Google Maps will be opened
/// with the specified location. If the URL cannot be launched, an exception will be thrown.
///
/// Example usage:
/// ```dart
/// openGoogleMaps(37.7749, -122.4194);
/// ```
void openGoogleMaps(double latitude, double longitude) async {
  final String googleMapsUrl =
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

  if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
    await launchUrl(Uri.parse(googleMapsUrl));
  } else {
    throw 'Could not launch $googleMapsUrl';
  }
}

/// Builds a list item widget for displaying a post.
///
/// The [listItem] function takes in a [BuildContext] and a [Map] of post data.
/// It decodes the media from the post data and determines the appropriate image path based on the media type.
/// It then returns a [GestureDetector] widget wrapped in a [Stack] widget, displaying the post image and an icon indicating the media type.
///
/// The [onTap] callback is triggered when the list item is tapped, and it navigates to the [SinglePostPage] for the corresponding post.
///
/// Example usage:
/// ```dart
/// Widget postItem = listItem(context, post);
/// ```
Widget listItem(BuildContext context, Map<String, dynamic> post,
    {bool? isRepost, int? rePostId}) {
  Map<String, dynamic> media = decodeMedia(post['media']);
  var isVideo = media['video'] != null;
  var isAudio = media['audio'] != null;
  var isOther = media['other'] != null;
  var imagePath;
  if (isVideo) {
    imagePath = media['thumbnail'];
  } else if (isAudio) {
    imagePath = 'assets/image/audio.jpg';
  } else if (isOther) {
    imagePath = 'assets/image/file.jpg';
  } else {
    imagePath = media['image'];
  }
  isVideo ? media['thumbnail'] : media['image'];
  return GestureDetector(
    onTap: () async {
      Logger().i(post);
      await Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
          builder: (context) => SinglePostPage(
                id: isRepost != null && isRepost ? rePostId : post['id'],
                isRepost: isRepost,
              )));
      BlocProvider.of<ProfileCubit>(context).getUser();
    },
    child: Stack(
      children: [
        Container(
          child: Image(
            image: isOther || isAudio
                ? AssetImage(imagePath)
                : NetworkImage('${AuthRepo.SERVER}/$imagePath')
                    as ImageProvider<Object>,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(
              isVideo
                  ? Icons.ondemand_video
                  : isAudio
                      ? Icons.audio_file_outlined
                      : isOther
                          ? Icons.file_copy
                          : Icons.image,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ),
  );
}

/// Decodes the given [media] object into a [Map<String, dynamic>].
///
/// If the application is running on the server, the [media] object is expected
/// to be a JSON string, which will be decoded using [jsonDecode] and returned
/// as a [Map<String, dynamic>]. Otherwise, if the application is running on
/// the client, the [media] object is expected to be a [Map<String, dynamic>]
/// and will be returned as is.
///
/// Returns the decoded [Map<String, dynamic>] representation of the [media]
/// object.
Map<String, dynamic> decodeMedia(dynamic media) {
  if (AuthRepo.isServer) {
    return jsonDecode(media);
  } else {
    return {"image": media};
  }
}

/// Requests the location permission and returns a boolean indicating whether the permission is granted or not.
///
/// This function uses the `Permission.locationWhenInUse` package to request the location permission.
/// It returns `true` if the permission is granted, and `false` otherwise.
Future<bool> requestLocationPermission() async {
  final locationStatus = await Permission.locationWhenInUse.request();
  return locationStatus.isGranted;
}

/// Shows a dialog to prompt the user to enable location services.
///
/// This function displays an [AlertDialog] with a title and content
/// informing the user that location services are disabled on their device.
/// It provides two actions: "Cancel" and "Settings". Tapping "Cancel"
/// dismisses the dialog, while tapping "Settings" opens the device's
/// location settings.
///
/// The [context] parameter is the [BuildContext] of the current widget.
/// It is used to show the dialog.
///
/// Example usage:
/// ```dart
/// _showLocationServiceDialog(context);
/// ```
Future<void> _showLocationServiceDialog(BuildContext context) async {
  showDialog<void>(
    context: context,
    barrierDismissible:
        false, // Prevent dismissing the dialog by tapping outside
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Location Services Disabled'),
        content: Text(
            'Please enable location services in your device settings. After enabling, tap "Settings" to continue. or "Cancel" to dismiss see the result in 30 seconds'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Settings'),
            onPressed: () {
              Navigator.of(context).pop();
              Geolocator.openLocationSettings();
            },
          ),
        ],
      );
    },
  );
}

trigerNotification(String title, String body) {
  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });
  AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: 10, channelKey: 'channelKey', title: title, body: body));
}

/// Waits for the location service to be enabled within the specified [timeout].
///
/// Returns a [Future] that completes with a boolean value indicating whether the location service was enabled or not.
/// If the location service is enabled before the [timeout] duration expires, the future completes with `true`.
/// If the [timeout] duration expires and the location service is still not enabled, the future completes with `false`.
///
/// The [timeout] parameter specifies the maximum duration to wait for the location service to be enabled.
/// If the location service is not enabled within this duration, the future completes with `false`.
///
/// This method periodically checks if the location service is enabled using the [Geolocator.isLocationServiceEnabled] method.
/// It waits for 1 second before checking again.
///
/// Example usage:
/// ```dart
/// bool locationServiceEnabled = await _waitForLocationServiceEnable(timeout: Duration(seconds: 10));
/// if (locationServiceEnabled) {
///   // Location service is enabled
/// } else {
///   // Location service is not enabled within the specified timeout
/// }
/// ```
Future<bool> _waitForLocationServiceEnable({required Duration timeout}) async {
  DateTime endTime = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(endTime)) {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (serviceEnabled) {
      return true; // User enabled location services
    }
    await Future.delayed(
        Duration(seconds: 1)); // Wait for 1 second before checking again
  }
  return false; // Timeout reached, user did not enable location services
}

/// Retrieves the current location of the device.
///
/// This function requests the necessary location permission from the user and
/// checks if the location service is enabled. If the service is disabled, it
/// prompts the user to enable it. If the user does not enable the service within
/// the specified timeout, a snackbar is shown with a message indicating that
/// location services are still disabled.
///
/// If the permission is granted and the location service is enabled, the function
/// uses the Geolocator package to retrieve the current position with high accuracy.
/// If an error occurs during the process, the function returns a default location.
///
/// If the permission is denied, the function returns a default location.
///
/// If the permission is permanently denied, the function opens the app settings
/// to allow the user to manually enable the location permission.
///
/// Returns the current position as a [Position] object, or the default location
/// if an error occurs or the permission is denied.
Future<Position?> getCurrentLocation(BuildContext context) async {
  PermissionStatus permission = await Permission.location.request();

  if (permission.isGranted) {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await _showLocationServiceDialog(context);
        bool userEnabledService =
            await _waitForLocationServiceEnable(timeout: Duration(seconds: 30));

        if (!userEnabledService) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Location services are still disabled. Please enable them to get accurate result.')),
          );

          return defaultLocation;
        }
      }
      final locationData = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          forceAndroidLocationManager: true);
      print(locationData.latitude);

      return locationData;
    } catch (e) {
      return defaultLocation;
    }
  } else if (permission.isDenied) {
    return defaultLocation;
  } else if (permission.isPermanentlyDenied) {
    openAppSettings();
    return defaultLocation;
  }
  return defaultLocation;
}

// Future<Position?> getCurrentLocation() async {
//   _checkPermission();
//   if (await requestLocationPermission()) {
//     final locationData = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//         forceAndroidLocationManager: true);
//     print(locationData.latitude);
//     return locationData;
//   } else {
//     return Position(
//       longitude: 38.7781448, // Example longitude value
//       latitude: 8.9631768, // Example latitude value
//       timestamp: DateTime.now(), // Current timestamp
//       accuracy: 0.0, // Example accuracy value
//       altitude: 0.0, // Example altitude value
//       altitudeAccuracy: 0.0, // Example altitude accuracy value
//       heading: 0.0, // Example heading value
//       headingAccuracy: 0.0, // Example heading accuracy value
//       speed: 0.0, // Example speed value
//       speedAccuracy: 0.0, // Example speed accuracy value
//     );
//   }
// }

/// Handles the DioException and returns an appropriate error message based on the error type.
///
/// The [error] parameter is the DioException that occurred.
/// Returns a string representing the error message.
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

/// Handles the response error and returns an error message.
///
/// If the response contains a 'message' key, it is returned as the error message.
/// If the response contains a 'msg' key, it is returned as the error message.
/// If neither 'message' nor 'msg' keys are present, a default error message is returned
/// with the HTTP status code of the response.
///
/// Returns the error message.
String _handleResponseError(Response response) {
  return response.data['message'] ??
      response.data['msg'] ??
      'Error occured please try again later ${response.statusCode}';
}

final PersistentTabController pageController =
    PersistentTabController(initialIndex: 0);

enum ErrorType { timeout, noconnect, pagenotfound }

final ScrollController scrollController = ScrollController();

void scrollToTop() {
  scrollController.animateTo(
    0.0,
    duration: Duration(milliseconds: 300),
    curve: Curves.easeInOut,
  );
}

void jumpToTop() {
  scrollController.jumpTo(0);
}

int feedIndex = -1;

int getFeedIndex() {
  if (feedIndex >= 3) {
    feedIndex = 0;
    return feedIndex;
  } else {
    feedIndex++;
    return feedIndex;
  }
}
