import 'package:flutter/material.dart';

class PosSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  // use a controller so it doesn't reset
  final TextEditingController? controller; // ← add controller
  

  const PosSearchBar({
    super.key, 
    required this.onChanged, 
    this.controller
  });

  // @override
  // Widget build(BuildContext context) {
  //   return Padding(
  //     padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 12),
  //     child: TextField(
  //       controller: controller, // ← pass it in
  //       onChanged: onChanged,
  //       decoration: InputDecoration(
  //         hintText: 'Search products...',
  //         hintStyle: TextStyle(color: Colors.grey[400]),
  //         prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
  //         border: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(30),
  //           borderSide: BorderSide.none,
  //         ),
  //         filled: true,
  //         fillColor: Colors.grey[100],
  //         contentPadding: const EdgeInsets.symmetric(vertical: 0),
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 12),
      child: TextField(
        controller: controller, // ← pass it in
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search products...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
          suffixIcon: controller != null && controller!.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[400]),
                  onPressed: () {
                    controller!.clear();
                    onChanged(''); // reset search
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }
}
