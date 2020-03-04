import 'package:bookcatalog/pin/pin.dart';
import 'package:bookcatalog/pin/src/page.dart';
import 'package:bookcatalog/themes.dart';
import 'package:bookcatalog/utils/bloc_printer_delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (const bool.fromEnvironment('dart.vm.product')) {
    /// release mode
  } else {
    BlocSupervisor.delegate = PrinterBlocDelegate();
  }

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  SharedPreferences sharedPreferencesInstance =
      await SharedPreferences.getInstance();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<PinRepository>(
          create: (_) =>
              PinRepository(sharedPreferences: sharedPreferencesInstance),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Books Catalog',
      theme: theme,
      home: PinPage(),
    );
  }
}
