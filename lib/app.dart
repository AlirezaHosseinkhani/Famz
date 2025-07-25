import 'package:famz/presentation/bloc/alarm_recording/alarm_recording_bloc.dart';
import 'package:famz/presentation/bloc/alarm_request/alarm_request_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/config/theme_config.dart';
import 'injection_container.dart' as di;
import 'presentation/bloc/alarm/alarm_bloc.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/auth/auth_event.dart';
import 'presentation/bloc/navigation/navigation_bloc.dart';
import 'presentation/bloc/notification/notification_bloc.dart';
import 'presentation/bloc/profile/profile_bloc.dart';
import 'presentation/routes/app_router.dart';
import 'presentation/routes/route_names.dart';

class FamzApp extends StatelessWidget {
  const FamzApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => di.sl<AuthBloc>()..add(AuthCheckStatusEvent()),
        ),
        BlocProvider<NavigationBloc>(
          create: (context) => di.sl<NavigationBloc>(),
        ),
        BlocProvider<ProfileBloc>(
          create: (context) => di.sl<ProfileBloc>(),
        ),
        BlocProvider<NotificationBloc>(
          create: (context) => di.sl<NotificationBloc>(),
        ),
        BlocProvider<AlarmBloc>(
          create: (context) => di.sl<AlarmBloc>(),
        ),
        BlocProvider<AlarmRecordingBloc>(
          create: (context) => di.sl<AlarmRecordingBloc>(),
        ),
        BlocProvider<AlarmRequestBloc>(
          create: (context) => di.sl<AlarmRequestBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Famz',
        debugShowCheckedModeBanner: false,
        theme: ThemeConfig.lightTheme,
        darkTheme: ThemeConfig.darkTheme,
        themeMode: ThemeMode.system,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('fa', ''),
        ],
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: RouteNames.splash,
      ),
    );
  }
}
