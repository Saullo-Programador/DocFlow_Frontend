import 'package:flutter/material.dart';
import 'package:manege_doc/constants.dart';
import 'package:manege_doc/responsive/responsive.dart';

class DashboardScreen extends StatelessWidget {
const DashboardScreen({ super.key });

  @override
  Widget build(BuildContext context){
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Center(
              child: Text(
                "${Responsive.isMobile(context) ? "Mobile" 
                : Responsive.isDesktop(context) ? "Desktop" 
                : "Tablet"} Layout"
              ),
            )
          ],
        ),
      )
    );
  }
}