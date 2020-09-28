import 'package:bookcatalog/book/book.dart';
import 'package:bookcatalog/catalog/src/bloc.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'src/page.dart';

MaterialPageRoute route() {
  return MaterialPageRoute(
    builder: (context) {
      return RepositoryProvider(
        create: (_) => BooksApi(),
        child: BlocProvider(
          create: (context) => CatalogBloc(booksApi: context.repository()),
          child: Page(),
        ),
      );
    },
  );
}
