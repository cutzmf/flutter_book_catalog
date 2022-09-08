import 'package:bloc/bloc.dart';
import 'package:bookcatalog/pin/pin.dart';

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
    required this.entered,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is NewPin && runtimeType == other.runtimeType && entered == other.entered;
  }

  @override
  int get hashCode => entered.hashCode;

  NewPin copyWith({
    String? entered,
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
    required this.firstPin,
    required this.entered,
    required this.notEqualToFirst,
  });

  RepeatPin copyWith({
    String? firstPin,
    String? entered,
    bool? notEqualToFirst,
  }) {
    return RepeatPin(
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
  int get hashCode => firstPin.hashCode ^ entered.hashCode ^ notEqualToFirst.hashCode;
}

class HavePin implements PinState {
  final String entered;
  final bool isInputWrong;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HavePin &&
          runtimeType == other.runtimeType &&
          entered == other.entered &&
          isInputWrong == other.isInputWrong;

  @override
  int get hashCode => entered.hashCode ^ isInputWrong.hashCode;

  const HavePin({
    required this.entered,
    required this.isInputWrong,
  });

  HavePin copyWith({
    String? entered,
    bool? isInputWrong,
  }) {
    return HavePin(
      entered: entered ?? this.entered,
      isInputWrong: isInputWrong ?? this.isInputWrong,
    );
  }
}

class LoggedIn implements PinState {}

const int kMaxPinLength = 4;

class PinBloc extends Bloc<PinEvent, PinState> {
  final PinRepository pinRepository;

  String get storedPin => pinRepository.get();

  @override
  Stream<PinState> mapEventToState(PinEvent event) async* {
    final s = state;

    if (event is PinInput) {
      if (s is NewPin) {
        final NewPin newPin = s.copyWith(entered: '${s.entered}${event.value}');
        if (newPin.entered.length == kMaxPinLength) {
          yield newPin;
          yield RepeatPin(firstPin: newPin.entered, entered: '', notEqualToFirst: false);
        } else {
          yield newPin;
        }
      }

      if (s is RepeatPin) {
        final RepeatPin repeatPin = s.copyWith(entered: '${s.entered}${event.value}');
        if (repeatPin.entered.length > kMaxPinLength) return;
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
        final String enteredPin = '${s.entered}${event.value}';
        if (enteredPin.length > kMaxPinLength) return;
        if (enteredPin.length == kMaxPinLength) {
          if (enteredPin == storedPin) {
            yield HavePin(entered: enteredPin, isInputWrong: false);
            yield LoggedIn();
          } else {
            yield HavePin(entered: enteredPin, isInputWrong: true);
          }
        } else {
          yield HavePin(entered: enteredPin, isInputWrong: false);
        }
      }
    } else if (event is PinBackspace) {
      if (s is NewPin) yield s.copyWith(entered: _removeLast(s.entered));
      if (s is RepeatPin) yield s.copyWith(entered: _removeLast(s.entered), notEqualToFirst: false);
      if (s is HavePin)
        yield s.copyWith(
          entered: _removeLast(s.entered),
          isInputWrong: false,
        );
    }
  }

  String _removeLast(String string) => string.isEmpty ? string : string.substring(0, string.length - 1);

  PinBloc({
    required this.pinRepository,
  }) : super(pinRepository.get().isEmpty ? NewPin(entered: '') : HavePin(entered: '', isInputWrong: false));
}
