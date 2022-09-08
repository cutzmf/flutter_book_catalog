import 'package:bookcatalog/bookify_icons_icons.dart';
import 'package:bookcatalog/catalog/catalog.dart' as catalog;
import 'package:bookcatalog/pin/src/repository.dart';
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
        create: (context) => PinBloc(pinRepository: context.read<PinRepository>()),
        child: BlocConsumer<PinBloc, PinState>(
          listener: (context, state) {
            final scaffoldManager = ScaffoldMessenger.of(context);
            scaffoldManager.removeCurrentSnackBar();

            if (state is RepeatPin && state.notEqualToFirst)
              scaffoldManager.showSnackBar(
                SnackBar(
                  content: Text(S.pinsNotEqual),
                  backgroundColor: Colors.grey,
                ),
              );

            if (state is HavePin && state.isInputWrong) {
              scaffoldManager.showSnackBar(
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
            if (state is NewPin || state is RepeatPin) return _EnterNewAndRepeat();
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
          final controller = context.read<PageController>();
          if (state is NewPin) controller.animateToPage(0, duration: _pageDuration, curve: _pageCurve);
          if (state is RepeatPin) controller.animateToPage(1, duration: _pageDuration, curve: _pageCurve);
        },
        builder: (context, state) {
          return PageView(
            controller: context.read<PageController>(),
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
      buildWhen: (_, s) => s is NewPin,
      builder: (context, state) {
        if (state is NewPin) {
          return _AttemptPin(
            text: S.enterNewPin,
            filledDots: state.entered.length,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _SecondPin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PinBloc, PinState>(
      buildWhen: (_, s) => s is RepeatPin,
      builder: (context, state) {
        if (state is RepeatPin) {
          return _AttemptPin(
            text: S.repeatPin,
            filledDots: state.entered.length,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _PinInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PinBloc, PinState>(
      buildWhen: (_, s) => s is HavePin,
      builder: (context, state) {
        if (state is HavePin) {
          return _AttemptPin(
            text: S.enterPin,
            filledDots: state.entered.length,
          );
        }
        return const SizedBox.shrink();
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
          onDigit: (digit) => context.watch<PinBloc>().add(PinInput(digit)),
          onBackspace: () => context.watch<PinBloc>().add(PinBackspace()),
        ),
      ],
    );
  }

  const _AttemptPin({
    required this.text,
    required this.filledDots,
  });
}

class PinKeyboard extends StatelessWidget {
  final ValueChanged<int> onDigit;
  final VoidCallback onBackspace;

  PinKeyboard({
    required this.onDigit,
    required this.onBackspace,
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

  const _Key({
    required this.child,
    required this.onTap,
  });

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
    required this.filledCount,
    required this.dotsCount,
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
