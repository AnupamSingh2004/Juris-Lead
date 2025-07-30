# Contributing to AarogyaRekha

Thank you for your interest in contributing to AarogyaRekha! This document provides guidelines and information for contributing to our project.

## 🎯 Code of Conduct

By participating in this project, you agree to abide by our Code of Conduct. Please read it before contributing.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.8.1 or higher
- Python 3.11 or higher
- PostgreSQL 13 or higher
- Redis server
- Git

### Setting Up Development Environment

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/yourusername/aarogyarekha.git
   cd aarogyarekha
   ```
3. **Set up the backend** (see README.md for detailed instructions)
4. **Set up the frontend** (see README.md for detailed instructions)

## 🛠️ Development Workflow

### 1. Create a Branch
```bash
git checkout -b feature/your-feature-name
```

### 2. Make Changes
- Follow the coding standards outlined below
- Write tests for new features
- Update documentation as needed

### 3. Test Your Changes
```bash
# Backend tests
cd aarogyarekha-backend
python manage.py test

# Frontend tests
cd frontend
flutter test
```

### 4. Commit Your Changes
```bash
git add .
git commit -m "feat: add new feature description"
```

### 5. Push and Create Pull Request
```bash
git push origin feature/your-feature-name
```

Then create a Pull Request on GitHub.

## 📝 Coding Standards

### Flutter/Dart Standards
- Follow the [Flutter Style Guide](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo)
- Use meaningful variable and function names
- Add documentation comments for public APIs
- Format code with `flutter format`

### Python Standards
- Follow [PEP 8](https://www.python.org/dev/peps/pep-0008/)
- Use type hints where appropriate
- Write docstrings for functions and classes
- Use meaningful variable names

### Commit Message Format
We use conventional commits:
- `feat:` for new features
- `fix:` for bug fixes
- `docs:` for documentation changes
- `style:` for formatting changes
- `refactor:` for code refactoring
- `test:` for test additions/changes

## 🐛 Bug Reports

When reporting bugs, please include:
- Steps to reproduce the issue
- Expected behavior
- Actual behavior
- Screenshots/logs if applicable
- Environment details (OS, Flutter version, etc.)

## 💡 Feature Requests

When requesting features:
- Describe the problem you're trying to solve
- Explain why this feature would be useful
- Provide examples of how it would work
- Consider the impact on existing functionality

## 🧪 Testing Guidelines

### Frontend Testing
- Write unit tests for business logic
- Write widget tests for UI components
- Write integration tests for critical user flows

### Backend Testing
- Write unit tests for models and utilities
- Write integration tests for API endpoints
- Test error handling and edge cases

## 📚 Documentation

- Update README.md for major changes
- Add inline code comments for complex logic
- Update API documentation for new endpoints
- Include examples in documentation

## 🔍 Code Review Process

1. All submissions require review before merging
2. Reviews focus on:
   - Code quality and maintainability
   - Test coverage
   - Documentation
   - Performance implications
   - Security considerations

## 🏷️ Labels

We use the following labels for issues and PRs:
- `bug` - Something isn't working
- `enhancement` - New feature or request
- `documentation` - Documentation improvements
- `good first issue` - Good for newcomers
- `help wanted` - Extra attention needed
- `question` - Further information requested

## 🎉 Recognition

Contributors are recognized in:
- GitHub contributors list
- Release notes for significant contributions
- Project documentation

## 📞 Getting Help

If you need help:
- Check existing issues and documentation
- Ask questions in GitHub Discussions
- Join our Discord community
- Contact maintainers directly

## 📄 License

By contributing to AarogyaRekha, you agree that your contributions will be licensed under the MIT License.
