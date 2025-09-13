# Releasing ProgressIndicator

This document outlines the process for creating a new release of ProgressIndicator and updating the Homebrew tap. The system follows the automated distribution approach detailed in [Justin Searls' "How to distribute your own scripts via Homebrew"](https://justin.searls.co/posts/how-to-distribute-your-own-scripts-via-homebrew/).

## Overview

Our release system uses GitHub Actions to automate the entire distribution pipeline:

1. **Developer**: Creates and pushes a version tag
2. **GitHub Actions**: Builds universal binary, creates release, and updates Homebrew cask
3. **Users**: Install via `brew install --cask smartwatermelon/tap/progress-indicator`

## Prerequisites

Before releasing, ensure you have:

- [ ] Push access to both repositories:
  - `smartwatermelon/swift-progress-indicator`
  - `smartwatermelon/homebrew-tap`
- [ ] The `HOMEBREW_TAP_TOKEN` secret configured in the swift-progress-indicator repository
- [ ] All changes committed and pushed to the `main` branch
- [ ] The application builds successfully with `./build.sh`

## Release Process

### Step 1: Prepare the Release

1. **Ensure clean working directory:**

   ```bash
   git status
   # Should show "working tree clean"
   ```

2. **Test the build locally:**

   ```bash
   ./build.sh
   # Verify the build completes successfully
   ```

3. **Test the application:**

   ```bash
   echo "Test log entry" > /tmp/test.log
   ./release/ProgressIndicator --watchfile=/tmp/test.log
   # Verify the GUI launches and displays the log content
   ```

### Step 2: Create and Push Version Tag

1. **Determine the next version number** following [Semantic Versioning](https://semver.org/):
   - **Patch** (e.g., 1.0.1): Bug fixes, minor improvements
   - **Minor** (e.g., 1.1.0): New features, backward compatible
   - **Major** (e.g., 2.0.0): Breaking changes

2. **Create the version tag:**

   ```bash
   git tag v1.0.2  # Replace with your version number
   ```

3. **Push the tag to trigger automation:**

   ```bash
   git push origin v1.0.2
   ```

### Step 3: Monitor the Automation

1. **Watch the GitHub Actions workflow:**

   ```bash
   gh run list --repo smartwatermelon/swift-progress-indicator
   ```

2. **If the workflow succeeds**, the automation will:
   - ✅ Build universal binary (Intel + Apple Silicon)
   - ✅ Create GitHub release with binary artifact
   - ✅ Calculate SHA256 checksum
   - ✅ Update Homebrew cask formula automatically
   - ✅ Push changes to homebrew-tap repository

3. **If the workflow fails**, check the logs:

   ```bash
   gh run view [RUN_ID] --log-failed --repo smartwatermelon/swift-progress-indicator
   ```

## Manual Fallback (If Automation Fails)

If the GitHub Actions workflow fails, you can complete the release manually:

### Manual Release Creation

```bash
# Build and package
./build.sh
VERSION=1.0.2  # Your version number
mkdir -p release-package
cp release/ProgressIndicator release-package/
tar -czf ProgressIndicator-${VERSION}.tar.gz -C release-package ProgressIndicator

# Calculate checksum
shasum -a 256 ProgressIndicator-${VERSION}.tar.gz

# Create GitHub release
gh release create v${VERSION} ProgressIndicator-${VERSION}.tar.gz \
  --repo smartwatermelon/swift-progress-indicator \
  --title "ProgressIndicator v${VERSION}" \
  --notes "## ProgressIndicator v${VERSION}

Universal binary for Intel and Apple Silicon Macs.

### Installation
\`\`\`bash
brew tap smartwatermelon/tap
brew install --cask progress-indicator
\`\`\`

### SHA256 Checksum
\`[CHECKSUM_FROM_ABOVE]\`"
```

### Manual Homebrew Cask Update

```bash
# Clone the homebrew tap
git clone https://github.com/smartwatermelon/homebrew-tap.git
cd homebrew-tap

# Update version and checksum in Casks/progress-indicator.rb
sed -i '' "s/version \".*\"/version \"${VERSION}\"/" Casks/progress-indicator.rb
sed -i '' "s/sha256 \".*\"/sha256 \"[CHECKSUM]\"/" Casks/progress-indicator.rb

# Commit and push
git add Casks/progress-indicator.rb
git commit -m "Update progress-indicator to v${VERSION}"
git push origin main
```

## Testing the Release

After the release is complete, test the installation:

```bash
# Remove any existing installation
brew uninstall --cask progress-indicator 2>/dev/null || true
brew untap smartwatermelon/tap 2>/dev/null || true

# Fresh install
brew tap smartwatermelon/tap
brew install --cask progress-indicator

# Test functionality
ProgressIndicator --help
```

## Troubleshooting

### Common Issues

**GitHub Actions 403 Error:**

- The `GITHUB_TOKEN` may lack release permissions
- Manually create the release using `gh release create`

**Homebrew Cask Validation Errors:**

```bash
brew cask audit --strict Casks/progress-indicator.rb
```

**Binary Won't Run (Gatekeeper):**

- The cask includes automatic quarantine removal
- Users should not see security warnings

**Version Already Exists:**

- Delete the tag: `git tag -d v1.0.2 && git push origin :refs/tags/v1.0.2`
- Delete the release on GitHub
- Increment version and retry

### Getting Help

1. **Check workflow logs:** Use `gh run view --log-failed` for detailed error information
2. **Validate cask syntax:** Run `brew cask audit --strict` on the formula
3. **Test locally:** Always test `./build.sh` before tagging
4. **Review Justin's article:** Reference the [original automation guide](https://justin.searls.co/posts/how-to-distribute-your-own-scripts-via-homebrew/) for additional context

## Security Considerations

- The `HOMEBREW_TAP_TOKEN` secret provides write access to the homebrew-tap repository
- Only repository collaborators should perform releases
- All releases should be tested locally before distribution
- The postflight quarantine removal is necessary for unsigned binaries

## Repository Structure

```text
swift-progress-indicator/
├── .github/workflows/release.yml    # Automated release workflow
├── Sources/ProgressIndicator/       # Swift source code
├── build.sh                         # Universal binary build script
├── RELEASING.md                     # This document
└── README.md                        # Project documentation

homebrew-tap/
├── .github/workflows/test-casks.yml # Cask validation tests
├── Casks/progress-indicator.rb      # Homebrew cask formula
└── README.md                        # Tap documentation
```

This automated approach ensures consistent, reliable releases while minimizing manual steps and reducing the potential for human error.
