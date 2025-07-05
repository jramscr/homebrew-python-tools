# Homebrew Python Tools

A comprehensive collection of utilities for centralized Python virtual environment management with Homebrew.

## Features

- **Centralized Environment Management:**  
    Virtual environments are stored in `~/setup-virtualenv/envs/` with dependencies in `~/setup-virtualenv/dependencies/`, keeping your project directories clean.

- **Environment Tagging:**  
    Environments are automatically tagged with Python versions (e.g., `my-project_python3.9`, `my-project_python2.7`).

- **Visual Environment Indicators:**  
    Active environments show in your prompt as `(env-name) $` for easy identification.

- **Configuration-Driven Setup:**  
    Environment details are inferred from `.python-version` and `pyproject.toml` files in your project.

- **Focused Command-line Tools:**  
    The [`/bin`](bin) directory contains executable scripts focused on environment management.

## Installation

```bash
brew install jramscr/python-tools/setup-virtualenv
```

## Usage

### Typical Workflow

1. **Create project directory:**
   ```bash
   mkdir my-awesome-project
   cd my-awesome-project
   ```

2. **Create configuration files:**
   ```bash
   # Create .python-version file
   echo "3.9" > .python-version
   
   # Create pyproject.toml file
   cat > pyproject.toml << EOF
   [build-system]
   requires = ["setuptools>=61.0", "wheel"]
   build-backend = "setuptools.build_meta"
   
   [project]
   name = "my-awesome-project"
   version = "0.1.0"
   dependencies = [
       "requests>=2.28.0",
       "pandas>=1.5.0",
   ]
   
   [project.optional-dependencies]
   dev = [
       "pytest>=7.0.0",
       "black>=22.0.0",
   ]
   EOF
   ```

3. **Run setup-virtualenv:**
   ```bash
   setup-virtualenv
   ```
   
   This will:
   - Read Python version from `.python-version`
   - Read dependencies from `pyproject.toml`
   - Create environment `my-awesome-project_python3.9`
   - Sync and install dependencies
   - Activate the environment

### Managing Environments

```bash
# List all environments
setup-virtualenv --list

# Activate a specific environment
setup-virtualenv --use my-project_python3.9

# Delete an environment
setup-virtualenv --delete my-project_python3.9

# Force sync dependencies from pyproject.toml
setup-virtualenv --sync

# Validate environment is up-to-date
setup-virtualenv --validate
```

### Managing Dependencies

Since `setup-virtualenv` focuses on environment setup, you handle dependencies manually:

**Adding packages:**
```bash
# Edit pyproject.toml to add dependencies
# Then sync with setup-virtualenv
setup-virtualenv --sync
```

**Updating packages:**
```bash
# Activate environment
setup-virtualenv --use my-project_python3.9

# Update packages
pip install --upgrade package-name

# Or update all packages
pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip install -U
```

**Freezing dependencies:**
```bash
# Activate environment
setup-virtualenv --use my-project_python3.9

# Freeze to requirements.txt
pip freeze > requirements.txt
```

**Exporting dependencies:**
```bash
# Activate environment
setup-virtualenv --use my-project_python3.9

# Export to file
pip freeze > requirements.txt
```

### Directory Structure

```
~/setup-virtualenv/
├── envs/
│   ├── my-project_python3.9/
│   ├── my-project_python3.10/
│   └── my-project_dev_python3.10/
└── dependencies/
    ├── my-project_python3.9/
    │   ├── requirements.txt (compiled from pyproject.toml)
    │   └── dev-requirements.txt
    ├── my-project_python3.10/
    │   ├── requirements.txt (compiled from pyproject.toml)
    │   └── dev-requirements.txt
    └── my-project_dev_python3.10/
        ├── requirements.txt (compiled from pyproject.toml)
        └── dev-requirements.txt

Your Project Directory:
/path/to/project/
├── .python-version (specifies Python version)
├── pyproject.toml (defines dependencies)
├── src/
└── ...
```

## Available Commands

### setup-virtualenv (Main Command)
- `setup-virtualenv` - Create/activate environment for current project
- `setup-virtualenv --list` - List all environments
- `setup-virtualenv --use <env_name>` - Activate specific environment
- `setup-virtualenv --delete <env_name>` - Delete environment
- `setup-virtualenv --sync` - Force sync dependencies from pyproject.toml
- `setup-virtualenv --validate` - Check if environment is up-to-date

### delete-virtualenv
- `delete-virtualenv <env_name>` - Delete environment (wrapper for setup-virtualenv --delete)

## Configuration Files

### .python-version
Specifies the Python version for your project:
```
3.9
3.10.2
2.7
```

### pyproject.toml
Defines your project dependencies:
```toml
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "my-project"
version = "0.1.0"
dependencies = [
    "requests>=2.28.0",
    "pandas>=1.5.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0.0",
    "black>=22.0.0",
]
```

## Benefits

1. **Clean Project Directories:** No virtual environment folders in your project directories
2. **Easy Environment Switching:** Switch between environments without affecting project files
3. **Version Isolation:** Different Python versions for different projects
4. **Centralized Management:** All environments and dependencies in one place
5. **Visual Feedback:** Clear indication of active environment in prompt
6. **Configuration-Driven:** Environment setup inferred from project files
7. **Flexible Storage:** Dependencies defined in code, stored centrally
8. **Simple Workflow:** Just run `setup-virtualenv` and everything is handled automatically
9. **Focused Tool:** Single responsibility - environment setup and management
10. **User Control:** Full control over dependency management through standard tools

## Development and Deployment

### Deploying a New Version

Use the `deploy.sh` script to automate the entire deployment process:

```bash
# Deploy with interactive prompts
./deploy.sh 1.1.0

# Deploy with custom message
./deploy.sh 1.1.0 -m "Add centralized environment management"

# Deploy without confirmation prompts
./deploy.sh 1.1.0 --yes
```

The deploy script will:
1. Validate the version format and check for existing tags
2. Update version in formula files
3. Create git commit and tag
4. Update formula with new SHA256
5. Push changes and tags to GitHub

### Manual Deployment

If you prefer manual deployment:

1. **Update version in formula:**
   ```bash
   # Edit Formula/setup_virtualenv.rb
   # Update version and SHA256
   ```

2. **Create tag:**
   ```bash
   git tag -a v1.1.0 -m "Release version 1.1.0"
   ```

3. **Update formula:**
   ```bash
   ./update_formula.sh v1.1.0 "Release message"
   ```

4. **Push changes:**
   ```bash
   ./push_changes_and_tags.sh
   ```

## How to Tag This Project

To tag a new release, use the deploy script:

```bash
./deploy.sh <version> [options]
```

This will update the Homebrew formula and ensure the new version is published.

## Contributing

Contributions are welcome! Please open issues or submit pull requests for improvements.

## License

See [LICENSE](LICENSE) for details.

## Calculate Checksum
```
curl -L -o vX.X.X.tar.gz https://github.com/jramscr/homebrew-python-tools/archive/refs/tags/vX.X.X.tar.gz
shasum -a 256 vX.X.X.tar.gz
```