import 'package:famz/presentation/bloc/navigation/navigation_bloc.dart';
import 'package:famz/presentation/bloc/navigation/navigation_event.dart';
import 'package:famz/presentation/bloc/navigation/navigation_state.dart';
import 'package:famz/presentation/pages/main/alarms/alarms_page.dart';
import 'package:famz/presentation/pages/main/notifications/notifications_page.dart';
import 'package:famz/presentation/pages/main/profile/profile_page.dart';
import 'package:famz/presentation/pages/main/requests/requests_page.dart';
import 'package:famz/presentation/widgets/common/custom_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NavigationBloc(),
      child: const MainView(),
    );
  }
}

class MainView extends StatelessWidget {
  const MainView({super.key});

  static const List<Widget> _pages = [
    AlarmsPage(),
    RequestsPage(),
    NotificationsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        int currentIndex = 0;
        if (state is NavigationChanged) {
          currentIndex = state.currentIndex;
        }

        return Scaffold(
          body: IndexedStack(
            index: currentIndex,
            children: _pages,
          ),
          bottomNavigationBar: CustomBottomNav(
            currentIndex: currentIndex,
            onTap: (index) {
              context.read<NavigationBloc>().add(
                    NavigateToPageEvent(index),
                  );
            },
          ),
        );
      },
    );
  }
}
