import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:ai_text_improver_app/home/home.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_text_improver_app/data/repositories/repositories.dart';

// void main() => runApp(const AIApp());
void main() {
  runApp(
    DevicePreview(
      // ignore: avoid_redundant_argument_values
      enabled: false,
      builder: (context) => RepositoryProvider(
        create: (context) => SettingsRepository(),
        child: const App(),
      ),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(
        settingsRepository: context.read<SettingsRepository>(),
      ),
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) => MaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
            colorSchemeSeed: Colors.grey,
          ),
          debugShowCheckedModeBanner: false,
          title: 'AI Text Improver',
          home: const HomePage(),
        ),
      ),
    );
  }
}
