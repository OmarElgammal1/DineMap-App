import 'package:flutter_bloc/flutter_bloc.dart';
import 'navigation_state.dart';

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(NavigationState(currentIndex: 0));

  // Navigate to specified index
  void navigateTo(int index) {
    emit(NavigationState(currentIndex: index));
  }
}