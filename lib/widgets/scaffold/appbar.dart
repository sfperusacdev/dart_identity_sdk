import 'dart:async';

import 'package:flutter/material.dart';

class AppBarBuilder extends StatelessWidget implements PreferredSizeWidget {
  final PreferredSizeWidget Function(BuildContext context) builder;

  const AppBarBuilder({required this.builder, super.key});

  @override
  Widget build(BuildContext context) => builder(context);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final Duration debounce;
  final ValueChanged<String>? onChange;

  const SearchAppBar({
    super.key,
    required this.title,
    this.onChange,
    this.debounce = const Duration(milliseconds: 300),
  });

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SearchAppBarState extends State<SearchAppBar> {
  bool _isSearching = false;
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(widget.debounce, () => widget.onChange?.call(value));
  }

  void _submitNow(String value) {
    _debounce?.cancel();
    widget.onChange?.call(value);
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _submitNow('');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        child: _isSearching
            ? TextField(
                key: const ValueKey('searchField'),
                controller: _searchController,
                autofocus: true,
                onChanged: _onSearchChanged,
                onSubmitted: _submitNow,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Buscar...',
                  border: InputBorder.none,
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _submitNow('');
                            setState(() {}); // actualiza suffixIcon
                          },
                          tooltip: 'Limpiar',
                        ),
                ),
              )
            : Text(widget.title, key: const ValueKey('title')),
      ),
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          tooltip: _isSearching ? 'Cerrar búsqueda' : 'Buscar',
          onPressed: _toggleSearch,
        ),
      ],
    );
  }
}
