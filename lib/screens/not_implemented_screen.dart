import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plate_pal/utils/app_colors.dart';

class NotImplementedScreen extends StatelessWidget {
  const NotImplementedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color gradientStart = AppColors.backgroundGradientStart;
    const Color gradientEnd = AppColors.backgroundGradientEnd;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            customBorder: const CircleBorder(),
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: AppColors.backButton.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Transform.scale(
                scale: 0.6,
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'assets/icons/back.svg',
                  height: 16,
                  width: 16,
                ),
              ),
            ),
          ),
        ),
        title: const Text(
          'Bin',
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [gradientStart, gradientEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Center(
          child: Text(
            'This functionality is not implemented yet.',
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
