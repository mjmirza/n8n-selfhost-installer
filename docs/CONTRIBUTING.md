# 🤝 Contributing to N8N Rapid Deploy

Thank you for considering contributing to N8N Rapid Deploy! This document provides guidelines for contributing to the project.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Documentation](#documentation)

## 📜 Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inspiring community for all. Please be respectful and constructive in your interactions.

### Expected Behavior

- Use welcoming and inclusive language
- Be respectful of differing viewpoints
- Accept constructive criticism gracefully
- Focus on what is best for the community
- Show empathy towards other community members

## 🎯 How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates.

**Bug Report Template**:
```markdown
**Describe the bug**
A clear description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Run '...'
2. See error '...'

**Expected behavior**
What you expected to happen.

**Environment**:
- OS: [e.g., Ubuntu 24.04]
- Server: [e.g., Hetzner CPX21]
- Docker version: [e.g., 24.0.0]
- N8N version: [e.g., 1.10.0]

**Logs**
```
Paste relevant logs here
```

**Additional context**
Any other information about the problem.
```

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues.

**Enhancement Template**:
```markdown
**Is your feature request related to a problem?**
A clear description of the problem.

**Describe the solution you'd like**
A clear description of what you want to happen.

**Describe alternatives you've considered**
Any alternative solutions or features you've considered.

**Additional context**
Any other context about the feature request.
```

### Contributing Code

1. **Fork the repository**
2. **Create a feature branch**
3. **Make your changes**
4. **Test thoroughly**
5. **Submit a pull request**

## 🛠️ Development Setup

### Prerequisites

- Git
- A text editor (VS Code, Vim, etc.)
- Access to a test Ubuntu server (local VM or cloud)
- Basic knowledge of:
  - Bash scripting
  - Docker & Docker Compose
  - N8N

### Local Development

1. **Fork and clone**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/n8n-rapid-deploy.git
   cd n8n-rapid-deploy
   ```

2. **Create a branch**:
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/bug-description
   ```

3. **Make changes**:
   - Edit files in your preferred editor
   - Follow coding standards (see below)

4. **Test locally**:
   ```bash
   # Test on a fresh Ubuntu VM or server
   bash install.sh
   ```

5. **Commit changes**:
   ```bash
   git add .
   git commit -m "Add feature: your feature description"
   ```

6. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

7. **Create Pull Request**:
   - Go to GitHub
   - Click "New Pull Request"
   - Fill in the template

## 🔄 Pull Request Process

### Before Submitting

- [ ] Test on a fresh Ubuntu 22.04 or 24.04 installation
- [ ] Update documentation if needed
- [ ] Follow coding standards
- [ ] Add comments to complex code
- [ ] Update CHANGELOG.md if applicable

### PR Title Format

Use conventional commits format:

```
feat: add support for custom domains
fix: resolve SSL certificate issue
docs: update installation guide
chore: update dependencies
test: add integration tests
```

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Tested on Ubuntu 22.04
- [ ] Tested on Ubuntu 24.04
- [ ] Tested on Hetzner
- [ ] Tested on DigitalOcean

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-reviewed the code
- [ ] Commented complex code
- [ ] Updated documentation
- [ ] No new warnings
- [ ] Added tests (if applicable)

## Screenshots (if applicable)
Add screenshots here
```

## 📝 Coding Standards

### Bash Scripts

```bash
#!/bin/bash

# Use strict mode
set -e  # Exit on error

# Use meaningful variable names
DOMAIN_NAME="example.com"
CONTAINER_NAME="n8n-docker-caddy-n8n-1"

# Add comments for complex logic
# Check if container is running
if docker ps | grep -q "$CONTAINER_NAME"; then
    echo "✅ Container is running"
fi

# Use functions for reusability
check_status() {
    local service=$1
    # Function logic here
}

# Use consistent formatting
# - 4 spaces for indentation
# - Lowercase for function names
# - UPPERCASE for constants
```

### Documentation

- Use clear, concise language
- Include code examples
- Add screenshots when helpful
- Keep README up to date
- Use proper markdown formatting

### Commit Messages

Follow conventional commits:

```
type(scope): subject

body

footer
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting changes
- `refactor`: Code restructuring
- `test`: Adding tests
- `chore`: Maintenance tasks

**Examples**:
```
feat(installer): add timezone selection

Added interactive timezone selection during installation.
Users can now choose from common timezones or enter custom.

Closes #123
```

## 🧪 Testing

### Manual Testing

Test on fresh installations:

1. **Hetzner Cloud** (recommended):
   - Create fresh Ubuntu 24.04 server
   - Run installer
   - Verify all features work

2. **DigitalOcean**:
   - Test on different droplet sizes
   - Ensure compatibility

3. **Local VM**:
   - Use VirtualBox or VMware
   - Test Ubuntu 22.04 and 24.04

### Test Checklist

- [ ] Installation completes successfully
- [ ] All containers start correctly
- [ ] Firewall configured properly
- [ ] SSL certificates generated
- [ ] N8N accessible via HTTPS
- [ ] Utility scripts work correctly
- [ ] Status check shows all green
- [ ] Watchtower running
- [ ] Backups work
- [ ] Update script works

### Reporting Test Results

When submitting PR, include:

```markdown
## Test Results

**Environment**:
- Provider: Hetzner Cloud
- Server: CPX21 (3 vCPU, 4GB RAM)
- OS: Ubuntu 24.04 LTS
- Docker: 24.0.7

**Tests Performed**:
- [x] Fresh installation
- [x] SSL certificate generation
- [x] All utility scripts
- [x] Watchtower setup
- [x] Backup/restore

**Results**: All tests passed ✅
```

## 📚 Documentation

### What to Document

- **New Features**: Update README.md
- **Bug Fixes**: Update TROUBLESHOOTING.md if relevant
- **Setup Changes**: Update SETUP.md
- **Scripts**: Add inline comments
- **Configuration**: Update .env.example

### Documentation Style

- Use clear headers
- Include code examples
- Add practical examples
- Use screenshots when helpful
- Keep it concise but complete

## 🏷️ Issue Labels

We use these labels:

- `bug`: Something isn't working
- `enhancement`: New feature or request
- `documentation`: Documentation improvements
- `good first issue`: Good for newcomers
- `help wanted`: Extra attention needed
- `question`: Further information requested
- `wontfix`: This will not be worked on
- `duplicate`: This issue already exists

## 🎓 Getting Help

- **Questions**: Open a [Discussion](https://github.com/YOUR_USERNAME/n8n-rapid-deploy/discussions)
- **Bugs**: Open an [Issue](https://github.com/YOUR_USERNAME/n8n-rapid-deploy/issues)
- **Chat**: Join N8N Community [Discord](https://discord.gg/n8n)

## 🙏 Recognition

Contributors will be:
- Listed in README.md
- Mentioned in release notes
- Given credit in commits

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for contributing to N8N Rapid Deploy!** 🚀
