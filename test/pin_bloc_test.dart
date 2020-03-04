import 'package:bloc_test/bloc_test.dart';
import 'package:bookcatalog/pin/pin.dart';
import 'package:bookcatalog/pin/src/bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockPinRepo extends Mock implements PinRepository {}

void main() {
  final repo = MockPinRepo();
  group('pin group', () {
    blocTest(
      'first start new pin&repeated',
      build: () async {
        when(repo.get()).thenAnswer((_) => '');
        return PinBloc(pinRepository: repo);
      },
      act: (bloc) {
        // new pin
        bloc.add(PinInput(1));
        bloc.add(PinInput(1));
        bloc.add(PinInput(1));
        bloc.add(PinInput(1));
        // repeat
        bloc.add(PinInput(1));
        bloc.add(PinInput(1));
        bloc.add(PinInput(1));
        return bloc.add(PinInput(1));
      },
      skip: 0,
      expect: [
        NewPin(entered: ''),
        NewPin(entered: '1'),
        NewPin(entered: '11'),
        NewPin(entered: '111'),
        RepeatPin(entered: '', firstPin: '1111', notEqualToFirst: false),
        RepeatPin(entered: '1', firstPin: '1111', notEqualToFirst: false),
        RepeatPin(entered: '11', firstPin: '1111', notEqualToFirst: false),
        RepeatPin(entered: '111', firstPin: '1111', notEqualToFirst: false),
        isA<LoggedIn>(),
      ],
    );

    blocTest(
      'pins not equal new&repeated',
      build: () async {
        when(repo.get()).thenAnswer((_) => '');
        return PinBloc(pinRepository: repo);
      },
      act: (bloc) {
        bloc.add(PinInput(1));
        bloc.add(PinInput(1));
        bloc.add(PinInput(1));
        bloc.add(PinInput(1));

        bloc.add(PinInput(1));
        bloc.add(PinInput(1));
        bloc.add(PinInput(1));
        bloc.add(PinInput(2));
        bloc.add(PinBackspace());
        return bloc.add(PinInput(1));
      },
      expect: [
        NewPin(entered: '1'),
        NewPin(entered: '11'),
        NewPin(entered: '111'),
        RepeatPin(entered: '', firstPin: '1111', notEqualToFirst: false),
        RepeatPin(entered: '1', firstPin: '1111', notEqualToFirst: false),
        RepeatPin(entered: '11', firstPin: '1111', notEqualToFirst: false),
        RepeatPin(entered: '111', firstPin: '1111', notEqualToFirst: false),
        RepeatPin(entered: '1112', firstPin: '1111', notEqualToFirst: true),
        RepeatPin(entered: '111', firstPin: '1111', notEqualToFirst: false),
        isA<LoggedIn>(),
      ],
    );

    blocTest(
      'have pin & entered correct pin',
      build: () async {
        when(repo.get()).thenAnswer((_) => '1111');
        return PinBloc(pinRepository: repo);
      },
      act: (bloc) {
        bloc.add(PinInput(1));
        bloc.add(PinInput(1));
        bloc.add(PinInput(1));
        return bloc.add(PinInput(1));
      },
      skip: 0,
      expect: [
        HavePin(entered: '', storedPin: '1111', isInputWrong: false),
        HavePin(entered: '1', storedPin: '1111', isInputWrong: false),
        HavePin(entered: '11', storedPin: '1111', isInputWrong: false),
        HavePin(entered: '111', storedPin: '1111', isInputWrong: false),
        isA<LoggedIn>(),
      ],
    );

    blocTest(
      'have pin wrong input',
      build: () async {
        when(repo.get()).thenAnswer((_) => '1111');
        return PinBloc(pinRepository: repo);
      },
      act: (bloc) {
        bloc.add(PinInput(1));
        bloc.add(PinInput(1));
        bloc.add(PinInput(1));
        bloc.add(PinInput(2));
        bloc.add(PinBackspace());
        return bloc.add(PinInput(1));
      },
      expect: [
        HavePin(entered: '1', storedPin: '1111', isInputWrong: false),
        HavePin(entered: '11', storedPin: '1111', isInputWrong: false),
        HavePin(entered: '111', storedPin: '1111', isInputWrong: false),
        HavePin(entered: '1112', storedPin: '1111', isInputWrong: true),
        HavePin(entered: '111', storedPin: '1111', isInputWrong: false),
        isA<LoggedIn>(),
      ],
    );

    blocTest(
      'backspace works',
      build: () async {
        when(repo.get()).thenAnswer((_) => '1111');
        return PinBloc(pinRepository: repo);
      },
      act: (bloc) {
        bloc.add(PinInput(1));
        bloc.add(PinBackspace());
        return bloc.add(PinInput(2));
      },
      expect: [
        HavePin(entered: '1', storedPin: '1111', isInputWrong: false),
        HavePin(entered: '', storedPin: '1111', isInputWrong: false),
        HavePin(entered: '2', storedPin: '1111', isInputWrong: false),
      ],
    );
  });
}
