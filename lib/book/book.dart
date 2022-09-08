import 'package:bookcatalog/book/src/bloc.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'src/model.dart';
import 'src/page.dart';

export 'src/api.dart';
export 'src/model.dart';

MaterialPageRoute detailsRoute(Book book, BuildContext oldContext) {
  return MaterialPageRoute(
    builder: (_) {
      return BlocProvider(
        create: (_) => BookBloc(
          book: book,
          booksApi: oldContext.read(),
        ),
        child: Page(),
      );
    },
  );
}
