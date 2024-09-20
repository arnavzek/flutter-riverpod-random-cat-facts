import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Define the FutureProvider to fetch cat facts
final catFactProvider = FutureProvider<String>((ref) async {
  final response = await http.get(Uri.parse('https://catfact.ninja/fact'));
  if (response.statusCode != 200) {
    throw Exception('Failed to load cat fact');
  }
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
      theme: ThemeData(
        primarySwatch: Colors.teal, // Use a teal theme for a modern look
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Cat Facts'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0), // Add padding around the edges
          child: Center(
            child: CatFactWidget(),
          ),
        ),
      ),
    );
  }
}

class CatFactWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the cat fact using AsyncValue
    final catFactAsyncValue = ref.watch(catFactProvider);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment:
          CrossAxisAlignment.stretch, // Stretch items horizontally
      children: [
        // Handle loading, data, and error states using AsyncValue
        catFactAsyncValue.when(
          data: (fact) => Text(
            fact,
            style: TextStyle(
              fontSize: 18, // Larger font size for better readability
              fontWeight: FontWeight.w500,
              color: Colors.teal.shade900, // Darker color for contrast
            ),
            textAlign: TextAlign.center, // Center the text
          ),
          skipLoadingOnRefresh: false,
          loading: () => Center(
            child: CircularProgressIndicator(), // Show loading spinner
          ),
          error: (err, stack) => Center(
            child: Text(
              'Error: $err',
              style: TextStyle(
                fontSize: 16,
                color: Colors.red, // Red color for error messages
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SizedBox(height: 40), // Add space between the text and the button
        ElevatedButton(
          onPressed: () {
            ref.refresh(catFactProvider);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'Refresh Cat Fact',
              style: TextStyle(fontSize: 16), // Larger button text
            ),
          ),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(12), // Rounded corners for the button
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }
}
