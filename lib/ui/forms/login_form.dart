import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intervals/data/repositories/authenticated_user_model.dart';
import 'package:provider/provider.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final apiKeyController = TextEditingController();

  final athleteIdController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    apiKeyController.dispose();
    athleteIdController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Start listening to changes.
    // apiKeyController.addListener(_login);
  }

  @override
  Widget build(BuildContext context) {
    // We create a Form object to help us handle validation
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[

          Row(
            children: [
              FloatingActionButton(
                onPressed: () {
                },
                child: const Text(
                  'Toby'
                ),
              ),
              FloatingActionButton(
                onPressed: () {
                },
                child: const Text(
                    'Carys'
                ),
              ),
            ],
          ),

          // A text box
          TextFormField(
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Enter your API key',
            ),
            controller: apiKeyController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),

          // Athlete ID
          TextFormField(
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Enter your athlete.dart ID from Strava',
            ),
            controller: athleteIdController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),

          // A submit button
          FloatingActionButton(
            // When the user presses the button, and the form is valid, submit the form
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Provider.of<AuthenticatedUserModel>(context, listen: false)
                  .logIn(apiKeyController.text, athleteIdController.text);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please put in your api key and athlete ID')),
                );
              }
            },
            tooltip: 'Show me the value!',
            child: const Text(
              'Login'
            ),
          ),
        ],
      ),
    );
    // Fill this out in the next step.
  }

}
