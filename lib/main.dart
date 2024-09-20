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

// Define a Notifier to handle loading state
class LoadingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setLoading(bool isLoading) {
    state = isLoading;
  }
}

final loadingProvider =
    NotifierProvider<LoadingNotifier, bool>(LoadingNotifier.new);

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
    // Get the cat fact and loading state
    final catFactAsyncValue = ref.watch(catFactProvider);
    final isLoading = ref.watch(loadingProvider);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment:
          CrossAxisAlignment.stretch, // Stretch items horizontally
      children: [
        // Show loading indicator when fetching new data
        if (isLoading)
          Center(
            child: CircularProgressIndicator(),
          )
        else
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
            loading: () => Center(
              child: CircularProgressIndicator(),
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
          onPressed: () async {
            // Show the loading indicator and refresh data
            ref.read(loadingProvider.notifier).setLoading(true);
            await ref.refresh(catFactProvider.future);
            ref.read(loadingProvider.notifier).setLoading(false);
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
