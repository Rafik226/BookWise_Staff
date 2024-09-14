import 'package:flutter/material.dart';

class DashboardButtonsWidget extends StatelessWidget {
  const DashboardButtonsWidget({
    super.key,
    required this.title,
    required this.imagePath,
    required this.onPressed,
  });

  final String title, imagePath;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPressed();
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                height: 65,
                width: 65,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error, size: 65, color: Colors.red);
                },
              ),
              const SizedBox(
                height: 15,
              ),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
