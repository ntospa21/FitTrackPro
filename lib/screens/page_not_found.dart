import 'package:fit_track_pro/routes/routes_names.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PageNotFound extends StatelessWidget {
  final String errorMessage;
  const PageNotFound({
    super.key,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                errorMessage,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.red,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              OutlinedButton(
                  onPressed: () {
                    GoRouter.of(context).goNamed(RouteNames.home);
                  },
                  child: Text("Go home"))
            ],
          ),
        ),
      ),
    );
  }
}
