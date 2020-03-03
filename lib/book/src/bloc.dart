import 'package:bloc/bloc.dart';
import 'package:bookcatalog/book/book.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

abstract class BookEvent {}

class Refresh implements BookEvent {}

abstract class BookState {}

class Loading implements BookState {}

class Error implements BookState {}

class Loaded implements BookState {
  final Book book;

  const Loaded({
    @required this.book,
  });

  Loaded copyWith({
    Book book,
  }) {
    return new Loaded(
      book: book ?? this.book,
    );
  }
}

class BookBloc extends Bloc<BookEvent, BookState> {
  final Book book;
  final BooksApi booksApi;

  @override
  BookState get initialState => Loaded(book: book);

  @override
  Stream<BookState> mapEventToState(BookEvent event) async* {
    final s = state;
    if (event is Refresh && s is Loaded) {
      yield Loading();
      try {
        final books = await booksApi.getBooksById([book.id].toSet());
        s.copyWith(book: books.first);
      } catch (e) {
        yield Error();
      }
    }
  }

  BookBloc({
    @required this.book,
    @required this.booksApi,
  });
}
