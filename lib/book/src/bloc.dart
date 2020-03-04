import 'package:bloc/bloc.dart';
import 'package:bookcatalog/book/book.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

abstract class BookEvent {}

class Refresh implements BookEvent {}

class Buy implements BookEvent {}

abstract class BookState {}

class Loading implements BookState {}

class Error implements BookState {}

class Buying implements BookState {}

class SucceedBuy implements BookState {}

class Loaded implements BookState {
  final Book book;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Loaded && runtimeType == other.runtimeType && book == other.book;

  @override
  int get hashCode => book.hashCode;

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
    if (state is SucceedBuy) {
      yield SucceedBuy();
      return;
    }

    if (event is Refresh) {
      yield Loading();
      try {
        final fetchedBook = await booksApi.getBookById(book.id);
        yield Loaded(book: fetchedBook);
      } catch (e) {
        yield Error();
      }
    } else if (event is Buy) {
      yield Buying();
      try {
        await booksApi.buyBook(book);
        yield SucceedBuy();
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
