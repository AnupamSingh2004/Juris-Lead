#!/bin/bash

echo "🎨 Juris-Lead Logo Update Script"
echo "=================================="

# Check if new logo exists
NEW_LOGO_PATH="./new_logo.jpg"  # You can place your new logo here
LOGO_PATH="./assets/logo/logo.jpeg"

echo "📍 Current logo location: $LOGO_PATH"

if [ -f "$NEW_LOGO_PATH" ]; then
    echo "✅ New logo found at $NEW_LOGO_PATH"
    echo "🔄 Replacing logo..."
    cp "$NEW_LOGO_PATH" "$LOGO_PATH"
    echo "✅ Logo updated successfully!"
else
    echo "❌ New logo not found at $NEW_LOGO_PATH"
    echo "📝 Please place your new logo file at: $NEW_LOGO_PATH"
    echo "   Or manually copy it to: $LOGO_PATH"
fi

echo ""
echo "🔧 After updating the logo, run:"
echo "   flutter clean"
echo "   flutter pub get"
echo "   flutter run"

echo ""
echo "📱 The logo will appear in:"
echo "   • Login screen"
echo "   • Registration screen"
echo "   • User type selection"
echo "   • Dashboard header"
echo "   • About page"
echo "   • App drawer"

echo ""
echo "🎯 Your new JL logo will be used throughout the Juris-Lead app!"
