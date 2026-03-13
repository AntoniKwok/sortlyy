import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../core/constants/app_colors.dart';

enum SocialProvider { google, apple }

class SocialSignInButton extends StatelessWidget {
  final SocialProvider provider;
  final VoidCallback? onPressed;
  final bool isLoading;

  const SocialSignInButton({
    super.key,
    required this.provider,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.border,
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textPrimary,
                      ),
                    )
                  else ...[
                    _buildIcon(),
                    const SizedBox(width: 12),
                    Text(
                      _label,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    switch (provider) {
      case SocialProvider.google:
        return const FaIcon(
          FontAwesomeIcons.google,
          size: 18,
          color: AppColors.textPrimary,
        );
      case SocialProvider.apple:
        return const FaIcon(
          FontAwesomeIcons.apple,
          size: 20,
          color: AppColors.textPrimary,
        );
    }
  }

  String get _label {
    switch (provider) {
      case SocialProvider.google:
        return 'Continue with Google';
      case SocialProvider.apple:
        return 'Continue with Apple';
    }
  }
}
