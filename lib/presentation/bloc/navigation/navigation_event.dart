import 'package:equatable/equatable.dart';

abstract class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object> get props => [];
}

class NavigateToPageEvent extends NavigationEvent {
  final int pageIndex;

  const NavigateToPageEvent(this.pageIndex);

  @override
  List<Object> get props => [pageIndex];
}

class ResetNavigationEvent extends NavigationEvent {}
