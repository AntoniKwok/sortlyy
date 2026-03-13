import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';
import '../widgets/gallery_scan_step.dart';
import '../widgets/preferences_step.dart';
import '../widgets/swipe_tutorial_step.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OnboardingCubit>(),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView();

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: BlocListener<OnboardingCubit, OnboardingState>(
        listenWhen: (prev, curr) => curr.isComplete && !prev.isComplete,
        listener: (context, state) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const DashboardPage()),
            (_) => false,
          );
        },
        child: BlocBuilder<OnboardingCubit, OnboardingState>(
          buildWhen: (prev, curr) => prev.currentPage != curr.currentPage,
          builder: (context, state) {
            // Sync external page changes from cubit
            if (_pageController.hasClients &&
                _pageController.page?.round() != state.currentPage) {
              _pageController.animateToPage(
                state.currentPage,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut,
              );
            }

            return Scaffold(
              backgroundColor: AppColors.background,
              body: SafeArea(
                child: Column(
                  children: [
                    _TopBar(
                      currentPage: state.currentPage,
                      pageController: _pageController,
                    ),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: const [
                          GalleryScanStep(),
                          PreferencesStep(),
                          SwipeTutorialStep(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final int currentPage;
  final PageController pageController;

  const _TopBar({
    required this.currentPage,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button (hidden on first page)
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: currentPage > 0 ? 1.0 : 0.0,
            child: GestureDetector(
              onTap: currentPage > 0
                  ? () => context
                      .read<OnboardingCubit>()
                      .goToPage(currentPage - 1)
                  : null,
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),
          // Page dots
          SmoothPageIndicator(
            controller: pageController,
            count: 3,
            effect: const ExpandingDotsEffect(
              dotHeight: 6,
              dotWidth: 6,
              activeDotColor: AppColors.textPrimary,
              dotColor: AppColors.border,
              expansionFactor: 3,
              spacing: 6,
            ),
          ),
          // Skip button (hidden on last page)
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: currentPage < 2 ? 1.0 : 0.0,
            child: GestureDetector(
              onTap: currentPage < 2
                  ? () => context.read<OnboardingCubit>().completeOnboarding()
                  : null,
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
