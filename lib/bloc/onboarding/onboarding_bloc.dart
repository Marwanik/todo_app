import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoapp/bloc/onboarding/onboarding_event.dart';
import 'package:todoapp/bloc/onboarding/onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(OnboardingInitial()) {
    on<CheckOnboardingStatus>(_onCheckOnboardingStatus);
    on<CompleteOnboarding>(_onCompleteOnboarding);
  }

  Future<void> _onCheckOnboardingStatus(
      CheckOnboardingStatus event, Emitter<OnboardingState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('isFirstTime') ?? true;

    if (isFirstTime) {
      emit(ShowOnboarding());
    } else {
      emit(SkipOnboarding());
    }
  }

  Future<void> _onCompleteOnboarding(
      CompleteOnboarding event, Emitter<OnboardingState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false); // Mark onboarding as completed
    emit(SkipOnboarding());
  }
}
