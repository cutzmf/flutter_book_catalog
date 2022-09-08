import 'dart:ui';

import 'package:bookcatalog/book/book.dart';
import 'package:bookcatalog/bookify_icons_icons.dart';
import 'package:bookcatalog/catalog/src/bloc.dart';
import 'package:bookcatalog/strings.dart';
import 'package:bookcatalog/utils/context_extension.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<CatalogBloc, CatalogState>(
        listener: (context, state) {
          if (state is Error)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.networkError)),
            );
        },
        child: Stack(
          children: <Widget>[
            RefreshIndicator(
              color: Colors.grey,
              backgroundColor: Colors.grey.shade200,
              onRefresh: () {
                // ignore: close_sinks
                final bloc = context.watch<CatalogBloc>();
                bloc.add(Refresh());
                return bloc.stream.skip(1).firstWhere((it) => it is! Refreshing);
              },
              child: _BooksList(),
            ),
            Center(child: _LoadingIndicator()),
            Align(child: _SearchBar(), alignment: Alignment.bottomCenter),
          ],
        ),
      ),
    );
  }
}

class _BooksList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatalogBloc, CatalogState>(
      buildWhen: (_, state) => state is Loaded,
      builder: (context, state) {
        if (state is Loaded) {
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 140 / 220,
            ),
            itemCount: state.books.length + 1,
            itemBuilder: (context, index) {
              /// TODO solve this +1 quick fix. Last items partially hidden under the [_SearchBar]
              if (index + 1 > state.books.length) return SizedBox.shrink();
              return BookListItem(book: state.books[index], isLeft: index.isEven);
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatalogBloc, CatalogState>(
      buildWhen: (before, now) => before is Loading || now is Loading,
      builder: (context, state) {
        if (state is Loading)
          return CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
            backgroundColor: Colors.grey.shade200,
          );
        return SizedBox.shrink();
      },
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          height: 80 + context.safeBottom,
          color: Colors.grey.shade400.withOpacity(.6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10).add(
              EdgeInsets.only(bottom: context.safeBottom),
            ),
            child: ChangeNotifierProvider(
              create: (_) => TextEditingController(),
              child: _SearchInput(),
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: context.read(),
      onChanged: (value) => context.watch<CatalogBloc>().add(Search(value)),
      style: TextStyle(fontSize: 24),
      decoration: InputDecoration(
        prefixIcon: Icon(BookifyIcons.search, color: Colors.white),
        suffix: _ClearSearch(),
        fillColor: Colors.white.withOpacity(.3),
        filled: true,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(100)),
        ),
      ),
    );
  }
}

class _ClearSearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.clear, color: Colors.white),
      onPressed: () {
        context.watch()<CatalogBloc>().add(ClearSearch());
        context.read<TextEditingController>().clear();
      },
    );
  }
}

class BookListItem extends StatelessWidget {
  final Book book;
  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        return InkWell(
          onTap: () => Navigator.push(context, detailsRoute(book, context)),
          child: Center(
            child: Padding(
              padding: isLeft ? const EdgeInsets.only(left: 12) : const EdgeInsets.only(right: 12),
              child: SizedBox(
                width: c.maxWidth * .756,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: c.maxHeight * .05),
                    AspectRatio(
                      aspectRatio: 140 / 220,
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          BookCover(book),
                          Align(
                            child: _Price(book.price),
                            alignment: Alignment.bottomLeft,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      book.title,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      book.author,
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w300, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  const BookListItem({
    required this.book,
    required this.isLeft,
  });
}

class BookCover extends StatelessWidget {
  final Book book;

  BookCover(this.book);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: book.id,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 10,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          child: FittedBox(
            fit: BoxFit.cover,
            child: CachedNetworkImage(
              imageUrl: book.imageUrl,
            ),
          ),
        ),
      ),
    );
  }
}

class _Price extends StatelessWidget {
  final int price;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade500.withOpacity(.5),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Text(
        '$price \u20BD',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
      ),
    );
  }

  _Price(this.price);
}
