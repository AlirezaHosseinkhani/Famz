import 'package:flutter_bloc/flutter_bloc.dart';

import 'navigation_event.dart';
import 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationChanged(0)) {
    on<NavigateToPageEvent>(_onNavigateToPage);
    on<ResetNavigationEvent>(_onResetNavigation);
  }

  void _onNavigateToPage(
    NavigateToPageEvent event,
    Emitter<NavigationState> emit,
  ) {
    emit(NavigationChanged(event.pageIndex));
  }

  void _onResetNavigation(
    ResetNavigationEvent event,
    Emitter<NavigationState> emit,
  ) {
    emit(const NavigationChanged(0));
  }
}
