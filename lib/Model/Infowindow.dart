import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:hobcom/Model/MapUsers.dart';

class Infowindow extends ChangeNotifier{
  bool _showinfo = false;
  bool _temphidden = false;
  MapUsers _user ;
  double _leftmargin;
  double _rightmargin ;
  String _status;

void rebuildInfoWindow(){
  notifyListeners();
}

void updateUser(MapUsers user){

_user = user;
notifyListeners();

}

void updateVisiblity(bool visibility ){

  _showinfo=visibility;
notifyListeners();

}
void updateRequestStatus(String req){
  _status=req;
  notifyListeners();
}
void updateInfoWindow(BuildContext context , GoogleMapController controller , LatLng location ,
double widthInfoWindow , double markeroffset
 ) async {

   ScreenCoordinate screenCoordinate = await controller.getScreenCoordinate(location);
  //  for updating postion 
   double devicePixelratio = Platform.isAndroid ? MediaQuery.of(context).devicePixelRatio : 1.0;
   double left = (screenCoordinate.x.toDouble()/devicePixelratio)-(widthInfoWindow/2);
    double top = (screenCoordinate.y.toDouble()/devicePixelratio)-(widthInfoWindow/2);

if(left<0 || top<0){

  _temphidden = true;

}else{
  _temphidden = false;
  _leftmargin=left;
  _rightmargin = top;
}
notifyListeners();
}

bool get showinfoWindow => (_showinfo== true && _temphidden ==false ? true : false);

double get leftMargin => _leftmargin;
double get topMargin => _rightmargin;

MapUsers get user => _user;
String get status => _status;

}