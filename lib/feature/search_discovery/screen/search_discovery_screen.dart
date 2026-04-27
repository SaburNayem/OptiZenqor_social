import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/data/models/post_model.dart';
import '../../../core/data/models/user_model.dart';
import '../controller/search_discovery_controller.dart';

class SearchDiscoveryScreen extends StatefulWidget {
  const SearchDiscoveryScreen({super.key});

  @override
  State<SearchDiscoveryScreen> createState() => _SearchDiscoveryScreenState();
}

class _SearchDiscoveryScreenState extends State<SearchDiscoveryScreen> {
  final SearchDiscoveryController _controller = SearchDiscoveryController();
  final TextEditingController _queryController = TextEditingController();

  @override
  void dispose() {
    _queryController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, _) {
            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                  child: TextField(
                    controller: _queryController,
                    autofocus: true,
                    onChanged: _controller.search,
                    decoration: InputDecoration(
                      hintText: 'Search people, posts, pages...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _queryController.text.trim().isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () {
                                _queryController.clear();
                                _controller.search('');
                                setState(() {});
                              },
                            ),
                      filled: true,
                      fillColor: AppColors.grey50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: AppColors.grey100),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: AppColors.grey100),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: SearchEntityFilter.values.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (BuildContext context, int index) {
                      final SearchEntityFilter filter =
                          SearchEntityFilter.values[index];
                      final bool selected = filter == _controller.activeFilter;
                      return ChoiceChip(
                        label: Text(_controller.labelFor(filter)),
                        selected: selected,
                        onSelected: (_) => _controller.setFilter(filter),
                        selectedColor: AppColors.primary100,
                        labelStyle: TextStyle(
                          color: selected
                              ? AppColors.primary800
                              : AppColors.grey700,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ),
                Expanded(child: _buildBody()),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody() {
    final String query = _queryController.text.trim();
    if (query.isEmpty) {
      return _SearchSuggestions(
        terms: _controller.trendingTerms,
        onSelected: (String term) {
          _queryController.text = term;
          _queryController.selection = TextSelection.collapsed(
            offset: term.length,
          );
          _controller.search(term);
          setState(() {});
        },
      );
    }

    if (_controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.errorMessage != null) {
      return _SearchMessage(
        icon: Icons.search_off_rounded,
        title: _controller.errorMessage!,
      );
    }

    final List<Object> results = _controller.visibleResults;
    if (results.isEmpty) {
      return const _SearchMessage(
        icon: Icons.manage_search_rounded,
        title: 'No results found',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: results.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (BuildContext context, int index) {
        final Object item = results[index];
        if (item is UserModel) {
          return _UserResultTile(user: item);
        }
        if (item is PostModel) {
          return _PostResultTile(post: item);
        }
        return _BucketResultTile(item: item as SearchBucketItem);
      },
    );
  }
}

class _SearchSuggestions extends StatelessWidget {
  const _SearchSuggestions({required this.terms, required this.onSelected});

  final List<String> terms;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      children: <Widget>[
        const Text(
          'Trending searches',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: terms
              .map(
                (String term) => ActionChip(
                  label: Text(term),
                  onPressed: () => onSelected(term),
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}

class _UserResultTile extends StatelessWidget {
  const _UserResultTile({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundImage: user.avatar.trim().isEmpty
            ? null
            : NetworkImage(user.avatar.trim()),
        child: user.avatar.trim().isEmpty
            ? Text(user.name.characters.firstOrNull ?? '?')
            : null,
      ),
      title: Text(user.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        user.username.trim().isEmpty ? 'people' : '@${user.username}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _PostResultTile extends StatelessWidget {
  const _PostResultTile({required this.post});

  final PostModel post;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: _ResultImage(url: post.media.isEmpty ? '' : post.media.first),
      title: Text(
        post.caption.trim().isEmpty ? 'Post' : post.caption.trim(),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text('${post.likes} likes | ${post.comments} comments'),
    );
  }
}

class _BucketResultTile extends StatelessWidget {
  const _BucketResultTile({required this.item});

  final SearchBucketItem item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: _ResultImage(url: item.imageUrl),
      title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        item.subtitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        item.type,
        style: const TextStyle(color: AppColors.grey500, fontSize: 12),
      ),
    );
  }
}

class _ResultImage extends StatelessWidget {
  const _ResultImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 48,
        height: 48,
        child: url.trim().isEmpty
            ? const ColoredBox(
                color: AppColors.grey100,
                child: Icon(Icons.search_rounded, color: AppColors.grey500),
              )
            : Image.network(url.trim(), fit: BoxFit.cover),
      ),
    );
  }
}

class _SearchMessage extends StatelessWidget {
  const _SearchMessage({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 42, color: AppColors.grey500),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
