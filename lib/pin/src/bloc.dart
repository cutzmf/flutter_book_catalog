import 'package:bloc/bloc.dart';
import 'package:bookcatalog/pin/pin.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

abstract class PinEvent {}

class PinInput implements PinEvent {
  final int value;

  PinInput(this.value);
}

class PinBackspace implements PinEvent {}

abstract class PinState {}

class NewPin implements PinState {
  final String entered;

  const NewPin({
    @required this.entered,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewPin &&
          runtimeType == other.runtimeType &&
          entered == other.entered;

  @override
  int get hashCode => entered.hashCode;

  NewPin copyWith({
    String entered,
  }) {
    return new NewPin(
      entered: entered ?? this.entered,
    );
  }
}

class RepeatPin implements PinState {
  final String firstPin;
  final String entered;
  final bool notEqualToFirst;

  const RepeatPin({
    @required this.firstPin,
    @required this.entered,
    @required this.notEqualToFirst,
  });

  RepeatPin copyWith({
    String firstPin,
    String entered,
    bool notEqualToFirst,
  }) {
    return new RepeatPin(
      firstPin: firstPin ?? this.firstPin,
      entered: entered ?? this.entered,
      notEqualToFirst: notEqualToFirst ?? this.notEqualToFirst,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepeatPin &&
          runtimeType == other.runtimeType &&
          firstPin == other.firstPin &&
          entered == other.entered &&
          notEqualToFirst == other.notEqualToFirst;

  @override
  int get hashCode =>
      firstPin.hashCode ^ entered.hashCode ^ notEqualToFirst.hashCode;
}

class HavePin implements PinState {
  final String storedPin;
  final String entered;
  final bool isInputWrong;

  const HavePin({
    @required this.storedPin,
    @required this.entered,
    @required this.isInputWrong,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HavePin &&
          runtimeType == other.runtimeType &&
          storedPin == other.storedPin &&
          entered == other.entered &&
          isInputWrong == other.isInputWrong;

  @override
  int get hashCode =>
      storedPin.hashCode ^ entered.hashCode ^ isInputWrong.hashCode;

  HavePin copyWith({
    String storedPin,
    String entered,
    bool isInputWrong,
  }) {
    return new HavePin(
      storedPin: storedPin ?? this.storedPin,
      entered: entered ?? this.entered,
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
        ? NewPin(entered: '')
        : HavePin(entered: '', storedPin: pin, isInputWrong: false);
  }

  @override
  Stream<PinState> mapEventToState(PinEvent event) async* {
    final s = state;

    if (event is PinInput) {
      if (s is NewPin) {
        final NewPin newPin = s.copyWith(entered: '${s.entered}${event.value}');
        if (newPin.entered.length == kMaxPinLength) {
          yield newPin;
          yield RepeatPin(
              firstPin: newPin.entered, entered: '', notEqualToFirst: false);
        } else {
          yield newPin;
        }
      }

      if (s is RepeatPin) {
        final RepeatPin repeatPin =
            s.copyWith(entered: '${s.entered}${event.value}');
        if (repeatPin.entered.length == kMaxPinLength) {
          if (repeatPin.entered == s.firstPin) {
            await pinRepository.set(repeatPin.entered);
            yield repeatPin;
            yield LoggedIn();
          } else {
            yield repeatPin.copyWith(notEqualToFirst: true);
          }
        } else {
          yield repeatPin;
        }
      }

      if (s is HavePin) {
        final HavePin newState =
            s.copyWith(entered: '${s.entered}${event.value}');
        if (newState.entered.length == kMaxPinLength) {
          if (newState.entered == newState.storedPin) {
            yield newState;
            yield LoggedIn();
          } else
            yield newState.copyWith(isInputWrong: true);
        } else {
          yield newState;
        }
      }
    } else if (event is PinBackspace) {
      if (s is NewPin) yield s.copyWith(entered: _removeLast(s.entered));
      if (s is RepeatPin)
        yield s.copyWith(
            entered: _removeLast(s.entered), notEqualToFirst: false);
      if (s is HavePin)
        yield s.copyWith(
          entered: _removeLast(s.entered),
          isInputWrong: false,
        );
    }
  }

  String _removeLast(String string) =>
      string.isEmpty ? string : string.substring(0, string.length - 1);

  PinBloc({
    @required this.pinRepository,
  });
}
