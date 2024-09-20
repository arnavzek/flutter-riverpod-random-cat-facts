import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Define the FutureProvider to fetch cat facts
final catFactProvider = FutureProvider<String>((ref) async {
  final response = await http.get(Uri.parse('https://catfact.ninja/fact'));
  final data = jsonDecode(response.body);
  return data['fact'] as String;
});

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cat Facts App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Cat Facts'),
        ),
        body: Center(
          child: CatFactWidget(),
        ),
      ),
    );
  }
}

class CatFactWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the asynchronous cat fact data
    final catFactAsyncValue = ref.watch(catFactProvider);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Display the cat fact or loading/error message
        catFactAsyncValue.when(
          data: (fact) => Text(fact),
          loading: () => CircularProgressIndicator(),
          error: (err, stack) => Text('Error: $err'),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // Refresh the data by invalidating the provider
            ref.refresh(catFactProvider);
          },
          child: Text('Refresh'),
        ),
      ],
    );
  }
}
