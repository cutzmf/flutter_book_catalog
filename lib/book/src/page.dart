import 'dart:ui';

import 'package:bookcatalog/book/src/bloc.dart';
import 'package:bookcatalog/strings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: <Widget>[
              RefreshIndicator(
                onRefresh: () => Future.delayed(Duration(seconds: 1)),
                child: ListView(
                  children: [
//                    SizedBox(height: constraints.maxHeight * .01),
                    Center(
                      child: SizedBox(
                        width: constraints.maxWidth * .9,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(height: constraints.maxHeight * .05),
                            Container(
                              height: constraints.maxHeight / 3,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: _Picture(),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'title',
                              style: TextStyle(fontWeight: FontWeight.w500),
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.fade,
                            ),
                            Text(
                              'author',
                              style: TextStyle(fontWeight: FontWeight.w300),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                child: _BottomActionsBar(),
                alignment: Alignment.bottomCenter,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Picture extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookBloc, BookState>(
      builder: (context, state) {
        return CachedNetworkImage(
          imageUrl: state is Loaded ? state.book.imageUrl : null,
          fit: BoxFit.fitHeight,
        );
      },
    );
  }
}

class _BottomActionsBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: double.infinity,
      color: Colors.transparent,
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: IconButton(
              icon: Icon(Icons.keyboard_backspace),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Expanded(
            flex: 2,
            child: _BuyButton(),
          ),
        ],
      ),
    );
  }
}

class _BuyButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.5),
            blurRadius: 20,
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {},
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Center(
              child: Text(
                S.buy,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            Center(
              child: Icon(
                Icons.add_shopping_cart,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
