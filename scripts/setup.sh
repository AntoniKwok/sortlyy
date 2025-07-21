#!/bin/bash

echo "🚀 Setting up Flutter Base Project..."

# Install dependencies
echo "📦 Installing dependencies..."
flutter pub get

# Generate code
echo "🔧 Generating code..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Analyze code
echo "🔍 Analyzing code..."
flutter analyze

# Check formatting
echo "✨ Checking code formatting..."
flutter format --set-exit-if-changed .

echo "✅ Setup complete! Your Flutter base project is ready to use."
echo ""
echo "Next steps:"
echo "1. Update API_BASE_URL in lib/core/constants/api_constants.dart"
echo "2. Add your app-specific features following the established pattern"
echo "3. Run 'flutter run' to start the app"
echo ""
echo "Happy coding! 🎉"