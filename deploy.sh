#!/bin/bash

# Deploy script for homebrew-python-tools
# Automates version bump, tag, SHA256 update, and pushes

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

Automate Homebrew formula deployment:
- Bump version in formula
- Commit and tag
- Push tag
- Calculate SHA256
- Update formula with SHA256
- Commit and push

Options:
    -m, --message <message>    Release message (optional)
    -y, --yes                  Skip confirmation prompts
    -h, --help                 Show this help

Example:
    ./deploy.sh 1.1.0 -m "Release v1.1.0" --yes
EOF
}

# Check if we're in a git repository
check_git_repo() {
    if [ ! -d ".git" ]; then
        log_error "Not in a git repository. Please run from project root."
        exit 1
    fi
}

# Check if there are uncommitted changes
check_uncommitted_changes() {
    if [ -n "$(git status --porcelain)" ]; then
        log_warning "There are uncommitted changes:"
        git status --short
        read -p "Uncommitted changes detected. Commit them before deploying? [y/N]: " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            read -p "Enter commit message (leave blank for 'WIP commit before deploy'): " commit_msg
            if [ -z "$commit_msg" ]; then
                commit_msg="WIP commit before deploy"
            fi
            git add .
            git commit -m "$commit_msg"
            log_success "Committed changes: $commit_msg"
        else
            log_info "Deployment cancelled due to uncommitted changes."
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
update_version_in_formula() {
    local version="$1"
    log_info "Updating version in Formula/setup_virtualenv.rb..."
    sed -i.bak -e "s|^  version \".*\"|  version \"$version\"|" Formula/setup_virtualenv.rb
    rm Formula/setup_virtualenv.rb.bak
    log_success "Updated version in Formula/setup_virtualenv.rb"
}

update_sha256_in_formula() {
    local sha256="$1"
    log_info "Updating sha256 in Formula/setup_virtualenv.rb..."
    sed -i.bak -e "s|^  sha256 \".*\"|  sha256 \"$sha256\"|" Formula/setup_virtualenv.rb
    rm Formula/setup_virtualenv.rb.bak
    log_success "Updated sha256 in Formula/setup_virtualenv.rb"
}

# Main deployment function
deploy() {
    local version="$1"
    local message="$2"
    local auto_confirm="$3"
    local tag="v$version"
    local formula_file="Formula/setup_virtualenv.rb"
    local tarball_url="https://github.com/jramscr/homebrew-python-tools/archive/refs/tags/v${version}.tar.gz"
    
    log_info "Starting deployment for version $version"
    
    # Pre-deployment checks
    check_git_repo
    check_uncommitted_changes
    validate_version "$version"
    check_tag_exists "$version"
    
    # Update version in files
    update_version_in_formula "$version"
    
    # Commit version changes
    log_info "Committing version changes..."
    git add "$formula_file"
    git commit -m "Bump version to $version"
    
    # Create tag
    log_info "Creating tag $tag..."
    if [ -n "$message" ]; then
        git tag -a "$tag" -m "$message"
    else
        git tag -a "$tag" -m "Release version $version"
    fi
    
    # Push changes and tags
    log_info "Pushing changes and tags..."
    if [ "$auto_confirm" = "true" ]; then
        git push origin main
        git push origin "$tag"
    else
        read -p "Push changes and tags to GitHub? [y/N]: " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            git push origin main
            git push origin "$tag"
        else
            log_warning "Skipped pushing to GitHub."
        fi
    fi
    
    # Step 2: Download tarball and calculate SHA256
    log_info "Downloading tarball for SHA256 calculation..."
    curl -L -o v${version}.tar.gz "$tarball_url"
    sha256=$(shasum -a 256 v${version}.tar.gz | awk '{print $1}')
    log_info "SHA256: $sha256"
    rm v${version}.tar.gz
    
    # Step 3: Update sha256 in formula, commit, push
    update_sha256_in_formula "$sha256"
    git add "$formula_file"
    git commit -m "Update sha256 for v$version"
    git push origin main
    
    log_success "Deployment completed! Version $version is live."
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