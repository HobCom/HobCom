import 'package:google_maps_flutter/google_maps_flutter.dart';
class MapUsers{
  final String username;
  final String uid;
  final dynamic mapImage;
  final String profilepic;
  final LatLng location;

  MapUsers({this.username, this.uid, this.profilepic, this.mapImage, this.location});
  
}