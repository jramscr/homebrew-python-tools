# Homebrew Python Tools

A pretty basic collection of utilities and scripts to streamline Python development and packaging with Homebrew.

## Features

- **Virtual Environment Setup:**  
    The [`Formula/setup_virtualenv.rb`](Formula/setup_virtualenv.rb) script automates the creation and management of Python virtual environments for Homebrew formulae.

- **Command-line Tools:**  
    The [`/bin`](bin) directory contains executable scripts for common tasks, such as environment setup, dependency management, and project automation.

## Usage

### Setting Up a Virtual Environment

To set up a Python virtual environment for your Homebrew formula, use the logic provided in [`Formula/setup_virtualenv.rb`](Formula/setup_virtualenv.rb). This script ensures isolated and reproducible Python environments.

### Available Commands

Scripts in the [`/bin`](bin) folder include:

- `bin/setup`: Initializes the project environment.
- `bin/test`: Runs the test suite.
- `bin/lint`: Checks code style and formatting.

Run any script with:

```sh
./bin/<script-name>
```

## How to Tag This Project

To tag a new release, follow the process outlined in [`update_formula.sh`](update_formula.sh):

1. **Update the version:**  
     Edit the version number in the relevant files.

2. **Create a Git tag:**  
     ```sh
     git tag v<new-version>
     git push origin v<new-version>
     ```

3. **Run the update script:**  
     ```sh
     ./update_formula.sh <new-version>
     ```

This will update the Homebrew formula and ensure the new version is published.

## Contributing

Contributions are welcome! Please open issues or submit pull requests for improvements.

## License

See [LICENSE](LICENSE) for details.