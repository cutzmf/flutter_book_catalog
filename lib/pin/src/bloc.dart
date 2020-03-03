import 'package:bloc/bloc.dart';
import 'package:bookcatalog/pin/pin.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

abstract class PinEvent {}

class PinInput implements PinEvent {
  final String value;

  PinInput(this.value);
}

class PinBackspace implements PinEvent {}

abstract class PinState {}

class NewPin implements PinState {}

class RepeatPin implements PinState {
  final String firstPin;
  final bool notEqualToFirst;

  const RepeatPin({
    @required this.firstPin,
    @required this.notEqualToFirst,
  });

  RepeatPin copyWith({
    String firstPin,
    bool notEqualToFirst,
  }) {
    return new RepeatPin(
      firstPin: firstPin ?? this.firstPin,
      notEqualToFirst: notEqualToFirst ?? this.notEqualToFirst,
    );
  }
}

class HavePin implements PinState {
  final String storedPin;
  final bool isInputWrong;

  const HavePin({
    @required this.storedPin,
    @required this.isInputWrong,
  });

  HavePin copyWith({
    String storedPin,
    bool isInputWrong,
  }) {
    return new HavePin(
      storedPin: storedPin ?? this.storedPin,
      isInputWrong: isInputWrong ?? this.isInputWrong,
    );
  }
}

class LoggedIn implements PinState {}

const int kMaxPinLength = 4;

class PinBloc extends Bloc<PinEvent, PinState> {
  final PinRepository pinRepository;

  @override
  PinState get initialState {
    String pin = pinRepository.get();
    return pin.isEmpty
        ? NewPin()
        : HavePin(storedPin: pin, isInputWrong: false);
  }

  @override
  Stream<PinState> mapEventToState(PinEvent event) async* {
    final s = state;

    if (event is PinInput) {
      final pin = event.value;

      if (pin.length == kMaxPinLength) {
        if (s is NewPin) {
          yield RepeatPin(firstPin: pin, notEqualToFirst: false);
          return;
        }

        if (s is RepeatPin) {
          if (pin == s.firstPin) {
            await pinRepository.set(pin);
            yield LoggedIn();
          } else {
            s.copyWith(notEqualToFirst: true);
          }
          return;
        }

        if (s is HavePin) {
          yield pin == s.storedPin
              ? LoggedIn()
              : s.copyWith(isInputWrong: true);
        }
      }
    }
  }

  PinBloc({
    @required this.pinRepository,
  });
}
