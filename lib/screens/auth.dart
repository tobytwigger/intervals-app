import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intervals/data/repositories/authenticated_user_model.dart';
import 'package:intervals/ui/forms/login_form.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticatedUserModel>(
      builder: (context, userModel, child) {
        if(userModel.isLoggingIn) {
          return Scaffold(
            appBar: AppBar(title: const Text('Logging In')),
            body: Column(children: [CircularProgressIndicator()]),
          );
        } else {
          return Scaffold(
              appBar: AppBar(title: const Text('Login')),
              body: const LoginForm());
        }
      }
    );
  }
}
