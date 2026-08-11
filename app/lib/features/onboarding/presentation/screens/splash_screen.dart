import 'package:flutter/material.dart';

import 'package:vodan/core/routes/app_router.dart';
import 'package:vodan/core/presentation/vodan_scaffold.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      
      WelcomeRoute().go(context);
    });
  }

  @override
  Widget build(BuildContext context){
    return VodanScaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0), 
          duration: const Duration(milliseconds: 1500), 
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(
                scale: 0.8 + (value * 0.2),
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.storefront_rounded,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 16,),
              Text(
                'VoDan',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0
                ),
              )
            ],
          ),
        )
      ),
    );
  }
}