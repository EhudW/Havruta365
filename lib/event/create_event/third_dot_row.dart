import 'package:adobe_xd/pinned.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:havruta_project/globals.dart';

class ThirdDotRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 54,
          height: 6,
          child: Stack(
            children: <Widget>[
              Pinned.fromSize(
                bounds: Rect.fromLTWH(
                    Globals.scaler.getWidth(0.1),
                    Globals.scaler.getHeight(0),
                    Globals.scaler.getWidth(0.5),
                    Globals.scaler.getWidth(0.5)),
                size: Size(54.0, 6.0),
                pinTop: true,
                pinBottom: true,
                fixedWidth: true,
                child: SvgPicture.string(
                  _svg_h36wzl,
                  allowDrawingOutsideViewBox: true,
                  fit: BoxFit.fill,
                ),
              ),
              Pinned.fromSize(
                bounds: Rect.fromLTWH(
                    Globals.scaler.getWidth(2.5),
                    Globals.scaler.getHeight(0),
                    Globals.scaler.getWidth(0.5),
                    Globals.scaler.getWidth(0.5)),
                size: Size(54.0, 6.0),
                pinTop: true,
                pinBottom: true,
                fixedWidth: true,
                child: SvgPicture.string(
                  _svg_h36wzl,
                  allowDrawingOutsideViewBox: true,
                  fit: BoxFit.fill,
                ),
              ),
              Pinned.fromSize(
                bounds: Rect.fromLTWH(
                    Globals.scaler.getWidth(5),
                    Globals.scaler.getHeight(0),
                    Globals.scaler.getWidth(0.5),
                    Globals.scaler.getWidth(0.5)),
                size: Size(54.0, 6.0),
                pinTop: true,
                pinBottom: true,
                fixedWidth: true,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.all(Radius.elliptical(9999.0, 9999.0)),
                    color: Colors.teal[400],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

const String _svg_h36wzl =
    '<svg viewBox="16.0 0.0 6.0 6.0" ><path transform="translate(16.0, 0.0)" d="M 3 0 C 4.656854152679443 0 6 1.343145847320557 6 3 C 6 4.656854152679443 4.656854152679443 6 3 6 C 1.343145847320557 6 0 4.656854152679443 0 3 C 0 1.343145847320557 1.343145847320557 0 3 0 Z" fill="#bce0fd" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
