import 'package:bookcatalog/catalog/catalog.dart' as catalog;
import 'package:bookcatalog/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'bloc.dart';

class PinPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: null,
          title: Text(S.login),
        ),
        body: BlocProvider(
          create: (context) => PinBloc(pinRepository: context.repository()),
          child: BlocConsumer<PinBloc, PinState>(
            listener: (context, state) {
              if (state is RepeatPin && state.notEqualToFirst)
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text(S.pinsNotEqual),
                    backgroundColor: Colors.amber,
                  ),
                );

              if (state is HavePin && state.isInputWrong)
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text(S.wrongPin),
                    backgroundColor: Colors.amber,
                  ),
                );

              if (state is LoggedIn)
                Navigator.pushAndRemoveUntil(
                  context,
                  catalog.route(),
                  (_) => false,
                );
            },
            builder: (context, state) {
              if (state is HavePin) return _EnterPin();
              return _EnterNewAndRepeat();
            },
          ),
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

const Duration _pageDuration = const Duration(milliseconds: 170);
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

class _FirstPin extends _AttemptPin {
  _FirstPin() : super(S.enterPin);
}

class _SecondPin extends _AttemptPin {
  _SecondPin() : super(S.repeatPin);
}

abstract class _AttemptPin extends StatelessWidget {
  final String text;

  _AttemptPin(this.text);

  @override
  Widget build(BuildContext context) {
    return BlocListener<PinBloc, PinState>(
      listener: (context, state) {
        if (state is RepeatPin || state is NewPin) {
          final focusScope = FocusScope.of(context);
          if (!focusScope.hasPrimaryFocus) focusScope.unfocus();
        }
      },
      child: Column(
        children: <Widget>[
          Text(text),
          _PinInput(),
        ],
      ),
    );
  }
}

class _PinInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (value) => context.bloc<PinBloc>().add(PinInput(value)),
      autofocus: true,
      keyboardType: TextInputType.number,
      inputFormatters: [
        WhitelistingTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(kMaxPinLength),
      ],
    );
  }
}
