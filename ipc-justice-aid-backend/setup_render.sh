#!/bin/bash
# Quick setup script for Render deployment

echo "🚀 IPC Justice Aid - Render Deployment Setup"
echo "=============================================="

# Check if we're in the right directory
if [ ! -f "manage.py" ]; then
    echo "❌ Error: Please run this script from the backend directory (where manage.py is located)"
    exit 1
fi

echo "✅ Found Django project"

# Check Python version
python_version=$(python3 --version 2>/dev/null || python --version 2>/dev/null)
echo "🐍 Python version: $python_version"

# Check if required files exist
echo ""
echo "📋 Checking deployment files..."

files_to_check=(
    "render.yaml"
    "render-build.sh"
    "requirements.render.txt"
    ".env.render"
    "RENDER_DEPLOYMENT_GUIDE.md"
    "health_check_render.py"
    "test_huggingface.py"
)

all_files_exist=true

for file in "${files_to_check[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file (missing)"
        all_files_exist=false
    fi
done

if [ "$all_files_exist" = false ]; then
    echo ""
    echo "❌ Some deployment files are missing. Please ensure all files are present."
    exit 1
fi

echo ""
echo "🔧 Making scripts executable..."
chmod +x render-build.sh
chmod +x health_check_render.py
chmod +x test_huggingface.py
echo "✅ Scripts are now executable"

echo ""
echo "🌟 Setup Complete! Next Steps:"
echo ""
echo "1. Get your Hugging Face API token:"
echo "   https://huggingface.co/settings/tokens"
echo ""
echo "2. Test Hugging Face integration locally (optional):"
echo "   export HUGGINGFACE_API_TOKEN=hf_your_token_here"
echo "   export ANALYSIS_ENVIRONMENT=huggingface"
echo "   python test_huggingface.py"
echo ""
echo "3. Deploy to Render:"
echo "   - Push your code to GitHub"
echo "   - Go to https://dashboard.render.com"
echo "   - Click 'New' → 'Blueprint'"
echo "   - Connect your repository"
echo ""
echo "4. Set environment variables in Render:"
echo "   - HUGGINGFACE_API_TOKEN=hf_your_token_here"
echo "   - ANALYSIS_ENVIRONMENT=huggingface"
echo ""
echo "5. Test your deployment:"
echo "   curl https://your-app.onrender.com/legal/health/"
echo ""
echo "📚 Read the full guide: RENDER_DEPLOYMENT_GUIDE.md"
echo "🚀 Quick guide: RENDER_QUICK_DEPLOY.md"
echo ""
echo "Happy deploying! 🎉"
