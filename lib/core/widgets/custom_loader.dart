import 'package:flutter/material.dart';

class CustomLoader extends StatelessWidget {
  final String message;

  const CustomLoader({Key? key, this.message = 'Loading...'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Since we don't have a local Lottie file downloaded, we'll use a network Lottie or a very polished custom CircularProgressIndicator
          // In a real production app, we would include a 'assets/lottie/bus_loading.json'
          const CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
