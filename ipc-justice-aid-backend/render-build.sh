#!/usr/bin/env bash
set -o errexit  # Exit on error

echo "� Python version check..."
python_version=$(python --version 2>&1)
echo "Using Python: $python_version"

# Check if we're using Python 3.13+ which has compatibility issues
if python -c "import sys; exit(0 if sys.version_info < (3, 13) else 1)" 2>/dev/null; then
    echo "✅ Python version is compatible"
else
    echo "⚠️  WARNING: Python 3.13+ detected. This may cause compatibility issues."
    echo "   Ensure runtime.txt specifies python-3.11.9 for better compatibility."
fi

echo "📦 Installing Python dependencies..."
pip install --upgrade pip setuptools wheel
pip install -r requirements.render.txt

echo "🗃️  Collecting static files..."
python manage.py collectstatic --no-input

echo "🚀 Setting production environment..."
export ANALYSIS_ENVIRONMENT=gemini
export DEBUG=False

echo "✅ Build completed successfully!"
echo "� Next: Configure environment variables in Render dashboard:"
echo "   - DATABASE_URL"
echo "   - GEMINI_API_KEY"
