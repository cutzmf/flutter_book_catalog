import 'package:bookcatalog/book/src/bloc.dart';
import 'package:bookcatalog/book/src/thanks.dart';
import 'package:bookcatalog/bookify_icons_icons.dart';
import 'package:bookcatalog/catalog/src/page.dart';
import 'package:bookcatalog/strings.dart';
import 'package:bookcatalog/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<BookBloc, BookState>(
        listener: (context, state) {
          if (state is Error)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(S.networkError),
              ),
            );

          if (state is SucceedBuy)
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => ThanksDialog(),
            );
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: <Widget>[
                RefreshIndicator(
                  color: Colors.grey,
                  backgroundColor: Colors.grey.shade200,
                  onRefresh: () {
                    final bloc = context.watch<BookBloc>();
                    // ignore: close_sinks
                    bloc.add(Refresh());
                    return context.watch<BookBloc>().stream.skip(1).firstWhere((state) => state is! Loading);
                  },
                  child: ListView(
                    children: [
                      BlocBuilder<BookBloc, BookState>(
                        buildWhen: (_, state) => state is Loaded,
                        builder: (context, state) {
                          final s = state as Loaded;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(height: constraints.maxHeight * .05),
                              SizedBox(
                                width: constraints.maxWidth * .533,
                                child: AspectRatio(
                                  aspectRatio: 2 / 3,
                                  child: BookCover(s.book),
                                ),
                              ),
                              SizedBox(height: 30),
                              Text(
                                s.book.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                ),
                                maxLines: 2,
                                softWrap: true,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.fade,
                              ),
                              Text(
                                s.book.author,
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 22,
                                ),
                              ),
                              SizedBox(height: 28),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 30),
                                child: Column(
                                  children: <Widget>[
                                    Divider(thickness: 1, height: 0),
                                    SizedBox(height: 20),
                                    Row(
                                      children: <Widget>[
                                        Spacer(
                                          flex: 5,
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                'Цена',
                                                style: _nanoHeaderStyle,
                                              ),
                                              SizedBox(height: 6),
                                              Text(
                                                '${s.book.price}\u20BD',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 26,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 19),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        S.shortDescription,
                                        style: _nanoHeaderStyle,
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      s.book.shortDescription + '\n\n' + s.book.shortDescription,
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: 40),
                      SizedBox(
                        height: _kBottomButtonHeight,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              flex: _kBottomFreeWidth,
                              child: IconButton(
                                icon: Icon(BookifyIcons.back),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                            Spacer(flex: _kBottomButtonWidth),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _BuyButton(),
              ],
            );
          },
        ),
      ),
    );
  }
}

const _nanoHeaderStyle = const TextStyle(
  fontWeight: FontWeight.w500,
  fontSize: 12,
  color: Color(0xFF9F9F9F),
);

const double _kBottomButtonHeight = 80;
const int _kBottomFreeWidth = 104;
const int _kBottomButtonWidth = 270;

class _BuyButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: ClipRRect(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20)),
        child: Container(
          height: _kBottomButtonHeight + context.safeBottom,
          width: context.screenWidth * _kBottomButtonWidth / (_kBottomFreeWidth + _kBottomButtonWidth),
          child: Material(
            color: Colors.black,
            child: BlocBuilder<BookBloc, BookState>(
              builder: (context, state) {
                return InkWell(
                  onTap: state is Loaded || state is Error ? () => context.watch<BookBloc>().add(Buy()) : null,
                  splashColor: Colors.grey,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: context.safeBottom),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Center(
                          child: Text(
                            state is! SucceedBuy ? S.buy.toUpperCase() : S.alreadyBought.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Center(
                          child: state is Buying
                              ? CircularProgressIndicator(
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                                )
                              : Icon(
                                  BookifyIcons.fav,
                                  color: Colors.white,
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
