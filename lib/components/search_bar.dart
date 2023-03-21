import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({super.key});

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  @override
  Widget build(BuildContext context) {
    double radius =
        1000; // very high value to round borders completely and independently from the screen size

    return TextField(
      decoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        filled: true,
        fillColor: Colors.grey[400],
        prefixIcon: const Icon(Icons.search),
        hintText: 'Search',
        suffixIcon: const Icon(Icons.clear),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(
            width: 2,
            color: Theme.of(context).primaryColor,
          ),
        ),
        errorBorder: OutlineInputBorder(
          // might not be necessary
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(
            width: 2,
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}
