import 'dart:ui';

import 'package:bookcatalog/book/book.dart';
import 'package:bookcatalog/catalog/src/bloc.dart';
import 'package:bookcatalog/strings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<CatalogBloc, CatalogState>(
        listener: (context, state) {
          if (state is Error)
            Scaffold.of(context).showSnackBar(
              SnackBar(content: Text(S.networkError)),
            );
        },
        child: Stack(
          children: <Widget>[
            RefreshIndicator(
              onRefresh: () {
                // ignore: close_sinks
                final CatalogBloc bloc = context.bloc();
                bloc.add(Refresh());
                return bloc.skip(1).firstWhere((it) => it is! Loading);
              },
              child: BlocBuilder<CatalogBloc, CatalogState>(
                condition: (_, state) => state is Loaded,
                builder: (context, state) {
                  final Loaded loaded = state;
                  return ListView.builder(
                    itemCount: loaded.books.length,
                    itemBuilder: (context, index) =>
                        BookListItem(book: loaded.books[index]),
                  );
                },
              ),
            ),
            BlocBuilder<CatalogBloc, CatalogState>(
              condition: (before, now) => before is Loading || now is Loading,
              builder: (context, state) {
                if (state is Loading)
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                return SizedBox.shrink();
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _SearchBar(),
            ),
          ],
        ),
      ),
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
          height: 80,
          color: Colors.grey.shade100.withOpacity(.7),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                  fillColor: Colors.white.withOpacity(.3),
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BookListItem extends StatelessWidget {
  final Book book;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: IntrinsicHeight(
        child: Row(
          children: <Widget>[
            SizedBox(
              height: 100,
              width: 100,
              child: CachedNetworkImage(
                imageUrl: book.imageUrl,
              ),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  Text(book.title),
                  Text(book.price.toString()),
                  Text(book.shortDescription),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FlatButton(
                      child: Text(S.details),
                      shape: StadiumBorder(
                        side: BorderSide(),
                      ),
                      onPressed: () =>
                          Navigator.push(context, detailsRoute(book, context)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  const BookListItem({
    @required this.book,
  });
}
