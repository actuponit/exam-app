import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

class NotesSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final VoidCallback onClear;
  final String? initialQuery;

  const NotesSearchBar({
    super.key,
    required this.onSearch,
    required this.onClear,
    this.initialQuery,
  });

  @override
  State<NotesSearchBar> createState() => _NotesSearchBarState();
}

class _NotesSearchBarState extends State<NotesSearchBar> {
  late TextEditingController _controller;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _isSearching = widget.initialQuery?.isNotEmpty ?? false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    if (query.trim().isEmpty) {
      _clearSearch();
      return;
    }

    setState(() {
      _isSearching = true;
    });

    widget.onSearch(query.trim());
  }

  void _clearSearch() {
    _controller.clear();
    setState(() {
      _isSearching = false;
    });
    widget.onClear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        onChanged: _handleSearch,
        onSubmitted: _handleSearch,
        decoration: InputDecoration(
          hintText: 'Search notes...',
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.primary,
          ),
          suffixIcon: _isSearching
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                  onPressed: _clearSearch,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
      ),
    );
  }
}
