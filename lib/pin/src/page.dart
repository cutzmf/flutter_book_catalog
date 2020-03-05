import 'package:bookcatalog/bookify_icons_icons.dart';
import 'package:bookcatalog/catalog/catalog.dart' as catalog;
import 'package:bookcatalog/strings.dart';
import 'package:bookcatalog/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'bloc.dart';

class PinPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => PinBloc(pinRepository: context.repository()),
        child: BlocConsumer<PinBloc, PinState>(
          listener: (context, state) {
            final ScaffoldState scaffold = Scaffold.of(context);
            scaffold.removeCurrentSnackBar();

            if (state is RepeatPin && state.notEqualToFirst)
              scaffold.showSnackBar(
                SnackBar(
                  content: Text(S.pinsNotEqual),
                  backgroundColor: Colors.grey,
                ),
              );

            if (state is HavePin && state.isInputWrong) {
              scaffold.showSnackBar(
                SnackBar(
                  content: Text(S.wrongPin),
                  backgroundColor: Colors.grey,
                ),
              );
            }

            if (state is LoggedIn)
              Navigator.pushAndRemoveUntil(
                context,
                catalog.route(),
                (_) => false,
              );
          },
          buildWhen: (_, s) => s is! LoggedIn,
          builder: (context, state) {
            if (state is HavePin) return _EnterPin();
            if (state is NewPin || state is RepeatPin)
              return _EnterNewAndRepeat();
            return SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _EnterPin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _PinInput();
  }
}

const Duration _pageDuration = const Duration(milliseconds: 270);
const Curve _pageCurve = Curves.easeIn;

class _EnterNewAndRepeat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PageController(),
      child: BlocConsumer<PinBloc, PinState>(
        listener: (context, state) {
          final PageController controller = context.repository();
          if (state is NewPin)
            controller.animateToPage(0,
                duration: _pageDuration, curve: _pageCurve);
          if (state is RepeatPin)
            controller.animateToPage(1,
                duration: _pageDuration, curve: _pageCurve);
        },
        builder: (context, state) {
          return PageView(
            controller: context.repository(),
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              _FirstPin(),
              _SecondPin(),
            ],
          );
        },
      ),
    );
  }
}

class _FirstPin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PinBloc, PinState>(
      condition: (_, s) => s is NewPin,
      builder: (context, state) {
        final NewPin s = state;
        return _AttemptPin(
          text: S.enterNewPin,
          filledDots: s.entered.length,
        );
      },
    );
  }
}

class _SecondPin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PinBloc, PinState>(
      condition: (_, s) => s is RepeatPin,
      builder: (context, state) {
        final RepeatPin s = state;
        return _AttemptPin(
          text: S.repeatPin,
          filledDots: s.entered.length,
        );
      },
    );
  }
}

class _PinInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PinBloc, PinState>(
      condition: (_, s) => s is HavePin,
      builder: (context, state) {
        final HavePin s = state;
        return _AttemptPin(
          text: S.enterPin,
          filledDots: s.entered.length,
        );
      },
    );
  }
}

class _AttemptPin extends StatelessWidget {
  final String text;
  final int filledDots;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: 50),
        Text(
          text,
          style: TextStyle(fontSize: 20),
        ),
        SizedBox(height: 24),
        PinCodeDots(
          dotsCount: kMaxPinLength,
          filledCount: filledDots,
        ),
        SizedBox(height: 24),
        PinKeyboard(
          onDigit: (digit) => context.bloc<PinBloc>().add(PinInput(digit)),
          onBackspace: () => context.bloc<PinBloc>().add(PinBackspace()),
        ),
      ],
    );
  }

  const _AttemptPin({
    @required this.text,
    @required this.filledDots,
  });
}

class PinKeyboard extends StatelessWidget {
  final ValueChanged<int> onDigit;
  final VoidCallback onBackspace;

  PinKeyboard({
    @required this.onDigit,
    @required this.onBackspace,
  });

  Widget _numKey(int num) => _Key(
        onTap: () => onDigit(num),
        child: Text(
          '$num',
          style: TextStyle(
            color: Colors.black,
            fontSize: 40,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Container(
        margin: EdgeInsets.only(
          bottom: context.screenWidth * .13333,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              children: <Widget>[
                for (var i = 1; i <= 7; i = i + 3) _numKey(i),
              ],
            ),
            Column(
              children: <Widget>[
                for (var i = 2; i <= 8; i = i + 3) _numKey(i),
                _numKey(0),
              ],
            ),
            Column(
              children: <Widget>[
                for (var i = 3; i <= 9; i = i + 3) _numKey(i),
                if (onBackspace != null)
                  _Key(
                    onTap: onBackspace,
                    child: Icon(BookifyIcons.back),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Key extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _Key({this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    final size = context.screenWidth * .192;
    final margin = context.screenWidth * 0.021333333;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(),
      ),
      margin: EdgeInsets.all(margin),
      child: InkWell(
        onTap: onTap,
        customBorder: CircleBorder(side: BorderSide()),
        child: Center(
          child: child,
        ),
      ),
    );
  }
}

class PinCodeDots extends StatelessWidget {
  final int filledCount;
  final int dotsCount;
  static const margins = .372;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.screenWidth * margins),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 1; i <= dotsCount; i++)
            SizedBox(
              width: context.screenWidth * (1 - 2 * margins) * .125,
              child: AspectRatio(
                aspectRatio: 1,
                child: _Dot(i <= filledCount),
              ),
            ),
        ],
      ),
    );
  }

  PinCodeDots({
    @required this.filledCount,
    @required this.dotsCount,
  });
}

class _Dot extends StatelessWidget {
  final bool isFilled;

  _Dot(this.isFilled);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 270),
      decoration: BoxDecoration(
        color: isFilled ? Colors.black : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.black,
          width: 1,
        ),
      ),
    );
  }
}
