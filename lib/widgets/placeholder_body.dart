import 'package:flutter/material.dart';

/// Temporary body used by phase-1 placeholder screens.
class PlaceholderBody extends StatelessWidget {
  const PlaceholderBody({super.key, required this.title, required this.source, required this.path});
  final String title, source, path;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(child: Text('$title\n($source -> $path)\nTODO: convert', textAlign: TextAlign.center)),
      );
}
