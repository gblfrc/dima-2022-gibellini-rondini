import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  final Function(String)? onChanged;

  const SearchBar({super.key, this.onChanged});

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double radius =
        1000; // very high value to round borders completely and independently from the screen size

    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        filled: true,
        fillColor: Colors.grey[400],
        prefixIcon: const Icon(Icons.search),
        hintText: 'Search',
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            _controller.clear();
            // explicitly call callback function (otherwise it isn't called)
            if (widget.onChanged != null) widget.onChanged!(_controller.text);
          },
        ),
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
      onChanged: widget.onChanged,
    );
  }
}
