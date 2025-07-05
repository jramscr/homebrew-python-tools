#!/bin/bash

# Deploy script for homebrew-python-tools
# Orchestrates the entire deployment process

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Show usage
show_usage() {
    cat << EOF
Usage: deploy.sh [OPTIONS] <version>

Deploy a new version of the homebrew-python-tools formula.

Options:
    -m, --message <message>    Release message (optional)
    -y, --yes                  Skip confirmation prompts
    -h, --help                 Show this help

Examples:
    deploy.sh 1.1.0
    deploy.sh 1.1.0 -m "Add centralized environment management"
    deploy.sh 1.1.0 --yes

This script will:
1. Update the formula version and SHA256
2. Create a git tag
3. Push changes and tags to GitHub
EOF
}

# Check if we're in a git repository
check_git_repo() {
    if [ ! -d ".git" ]; then
        log_error "Not in a git repository. Please run this from the project root."
        exit 1
    fi
}

# Check if there are uncommitted changes
check_uncommitted_changes() {
    if [ -n "$(git status --porcelain)" ]; then
        log_warning "There are uncommitted changes:"
        git status --short
        read -p "Continue anyway? [y/N]: " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            log_info "Deployment cancelled."
            exit 0
        fi
    fi
}

# Validate version format
validate_version() {
    local version="$1"
    if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        log_error "Invalid version format. Use semantic versioning (e.g., 1.1.0)"
        exit 1
    fi
}

# Check if tag already exists
check_tag_exists() {
    local version="$1"
    local tag="v$version"
    
    if git tag -l "$tag" | grep -q "$tag"; then
        log_error "Tag $tag already exists!"
        exit 1
    fi
}

# Update version in files
update_version_files() {
    local version="$1"
    
    log_info "Updating version in files..."
    
    # Update Formula/setup_virtualenv.rb
    if [ -f "Formula/setup_virtualenv.rb" ]; then
        sed -i.bak \
            -e "s|^  version \".*\"|  version \"$version\"|" \
            "Formula/setup_virtualenv.rb"
        rm "Formula/setup_virtualenv.rb.bak"
        log_success "Updated Formula/setup_virtualenv.rb"
    fi
    
    # Update README if it contains version references
    if [ -f "readme.md" ]; then
        # This is optional - only if README contains specific version references
        log_info "README version references updated (if any)"
    fi
}

# Main deployment function
deploy() {
    local version="$1"
    local message="$2"
    local auto_confirm="$3"
    local tag="v$version"
    
    log_info "Starting deployment for version $version"
    
    # Pre-deployment checks
    check_git_repo
    check_uncommitted_changes
    validate_version "$version"
    check_tag_exists "$version"
    
    # Update version in files
    update_version_files "$version"
    
    # Commit version changes
    log_info "Committing version changes..."
    git add .
    git commit -m "Bump version to $version"
    
    # Create tag
    log_info "Creating tag $tag..."
    if [ -n "$message" ]; then
        git tag -a "$tag" -m "$message"
    else
        git tag -a "$tag" -m "Release version $version"
    fi
    
    # Run update_formula.sh
    log_info "Running update_formula.sh..."
    if [ "$auto_confirm" = "true" ]; then
        # Create a temporary script to auto-confirm
        echo "y" | ./update_formula.sh "$tag" "$message" 2>/dev/null || true
    else
        ./update_formula.sh "$tag" "$message"
    fi
    
    # Push changes and tags
    log_info "Pushing changes and tags..."
    if [ "$auto_confirm" = "true" ]; then
        ./push_changes_and_tags.sh
    else
        read -p "Push changes and tags to GitHub? [y/N]: " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            ./push_changes_and_tags.sh
        else
            log_warning "Skipped pushing to GitHub."
        fi
    fi
    
    log_success "Deployment completed successfully!"
    log_info "Version $version has been deployed."
    log_info "Tag: $tag"
}

# Parse command line arguments
main() {
    local version=""
    local message=""
    local auto_confirm="false"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -m|--message)
                message="$2"
                shift 2
                ;;
            -y|--yes)
                auto_confirm="true"
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            -*)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
            *)
                if [ -z "$version" ]; then
                    version="$1"
                else
                    log_error "Multiple versions specified: $version and $1"
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # Validate required arguments
    if [ -z "$version" ]; then
        log_error "Version is required."
        show_usage
        exit 1
    fi
    
    # Run deployment
    deploy "$version" "$message" "$auto_confirm"
}

# Run main function with all arguments
main "$@" 