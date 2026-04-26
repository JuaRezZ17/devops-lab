# Git Hooks & GitHub Container Registry (GHCR)

## Overview
This project demonstrates the first stage of a Continuous Integration (CI) pipeline by automating quality checks and interacting with remote image repositories. Building on the Flask + Redis application from Saturday, this lab introduces security scanning with Trivy and automated deployment to GitHub Container Registry using Git hooks.

**Note:** For detailed step-by-step instructions on implementing this project, refer to the [WALKTHROUGH.md](WALKTHROUGH.md) file.

## Objective
Create automated security checks and container registry integration as the foundation of a CI pipeline. Learn to prevent vulnerable code from being deployed by implementing pre-push Git hooks that scan Docker images for critical security issues.

## The Project: Automated CI Pipeline with Security Scanning
### GitHub Container Registry Setup
- Configure GitHub Personal Access Token with package write permissions
- Authenticate Docker with GHCR using the token
- Manual tagging and pushing of container images

### Git Hooks Automation
A `pre-push` Git hook that:
- Builds the latest Docker image before scanning
- Runs Trivy security scan focusing on CRITICAL vulnerabilities only
- Automatically tags and pushes validated images to GHCR
- Blocks `git push` if critical vulnerabilities are found

### Security-First Approach
- **Trivy Integration:** Automated vulnerability scanning
- **Fail-Fast Strategy:** Critical issues prevent deployment
- **Zero-Trust Pipeline:** Every push is validated before reaching the repository

## Project Structure
```
src/
├── pre-push          # Git hook script for automated CI
└── token.txt         # GitHub PAT (keep secure - not for production)
```

## Prerequisites
- Docker and Docker Compose installed
- Git repository initialized
- Trivy security scanner installed (`apt-get install trivy` on Ubuntu/Debian)
- GitHub account with repository access
- Flask + Redis application from Saturday's lab

## Setup and Installation
### 1. Install Trivy
```bash
trivy --version
# If not installed:
sudo apt-get update && sudo apt-get install trivy
```

### 2. Create GitHub Personal Access Token
1. Go to GitHub Settings → Developer Settings → Personal Access Tokens → Tokens (classic)
2. Generate new token with `write:packages` permission
3. Store token securely (never commit to repository)

### 3. Authenticate with GHCR
```bash
# Replace YOUR_TOKEN with your actual PAT
echo "YOUR_TOKEN" | docker login ghcr.io -u YOUR_USERNAME --password-stdin
```

### 4. Setup Git Hook
```bash
# Navigate to your git repository
cd your-repo/.git/hooks/

# Copy the pre-push script
cp /path/to/sunday_26-04/src/pre-push .

# Make it executable
chmod +x pre-push

# Edit the script to use your GitHub username
# Replace 'juarezz17' with your actual username
```

## Usage
### Manual Workflow (Understanding)
1. **Build and tag image:**
   ```bash
   docker build -t my_flask_app .
   docker tag my_flask_app ghcr.io/your_username/my_flask_app:v1.0.0
   ```

2. **Push to GHCR:**
   ```bash
   docker push ghcr.io/your_username/my_flask_app:v1.0.0
   ```

### Automated Workflow (Production)
1. **Make code changes**
2. **Commit changes:**
   ```bash
   git add .
   git commit -m "Your commit message"
   ```

3. **Push (triggers automation):**
   ```bash
   git push origin main
   ```

The pre-push hook will automatically:
- Build the latest image
- Scan for critical vulnerabilities
- Push to GHCR if clean
- Block push if vulnerabilities found

## Security Scanning with Trivy
### Critical Vulnerabilities Only
```bash
trivy image --severity CRITICAL --exit-code 1 my_flask_app
```

**Parameters:**
- `--severity CRITICAL`: Focus on high-impact vulnerabilities only
- `--exit-code 1`: Fail the script if issues are found
- Enables automated blocking of insecure deployments

### Understanding Trivy Output
- **Exit Code 0:** No critical vulnerabilities found
- **Exit Code 1:** Critical vulnerabilities detected - deployment blocked
- Detailed reports show CVE IDs, severity levels, and affected packages

## Git Hook Implementation
### Pre-Push Hook Logic
```bash
#!/bin/bash
# 1. Build latest image
docker build -t $IMAGE_NAME .

# 2. Security scan
trivy image --severity CRITICAL --exit-code 1 $IMAGE_NAME

# 3. If scan passes: tag, push, allow git push
# 4. If scan fails: block git push
```

### Hook Execution Flow
1. **Pre-Push Trigger:** Activated before `git push`
2. **Build Phase:** Creates image with latest code changes
3. **Scan Phase:** Trivy checks for critical vulnerabilities
4. **Decision Point:** Success allows push, failure blocks it
5. **Deploy Phase:** Validated image pushed to GHCR

## Testing the Pipeline
### Successful Deployment Test
1. Make a clean code change
2. Commit and attempt push
3. Verify image appears in GHCR packages

### Security Blocking Test
1. Introduce a vulnerable dependency (temporarily)
2. Attempt push
3. Verify push is blocked with security alert
4. Check Trivy output for vulnerability details

### Hook Debugging
```bash
# Test hook manually
./.git/hooks/pre-push

# Check exit codes
echo $?
```

## Key Concepts and Learning Objectives
### Continuous Integration Fundamentals
- **Automated Quality Gates:** Prevent bad code from reaching repositories
- **Security-First Development:** Scan early, fail fast
- **Infrastructure as Code:** Version control for deployment processes

### Git Hooks
- **Pre-Push Hook:** Executes before code reaches remote repository
- **Automation Scripts:** Bash scripting for DevOps workflows
- **Exit Codes:** Control flow based on command success/failure

### Container Registry Integration
- **GHCR Authentication:** Secure token-based access
- **Image Tagging:** Semantic versioning for container images
- **Remote Deployment:** Push validated images to cloud registry

### Security Scanning
- **Vulnerability Assessment:** Automated CVE detection
- **Risk Prioritization:** Focus on critical threats only
- **Compliance Automation:** Enforce security standards

## Troubleshooting
### Common Issues

1. **Trivy not found:**
   ```bash
   sudo apt-get install trivy
   ```

2. **GHCR authentication failed:**
   - Verify PAT has `write:packages` permission
   - Check token hasn't expired
   - Ensure correct username format

3. **Hook not executing:**
   ```bash
   chmod +x .git/hooks/pre-push
   # Verify hook is in correct location
   ls -la .git/hooks/
   ```

4. **Docker build failures:**
   - Ensure Dockerfile exists in repository root
   - Check Docker daemon is running
   - Verify base images are accessible

### Logs and Debugging
```bash
# View Git hook output
git push origin main

# Manual Trivy scan
trivy image --severity CRITICAL my_flask_app

# Check Docker images
docker images

# View GHCR packages on GitHub
# Go to repository → Packages
```

## Security Best Practices
### Token Management
- **Never commit tokens** to version control
- **Use environment variables** for sensitive data
- **Rotate tokens regularly** and on compromise
- **Limit token scope** to minimum required permissions

### Image Security
- **Scan regularly** with updated vulnerability databases
- **Use trusted base images** from official repositories
- **Keep dependencies updated** to patch known vulnerabilities
- **Implement multi-stage builds** to reduce attack surface

## Cleanup
```bash
# Remove local images
docker rmi my_flask_app ghcr.io/your_username/my_flask_app:v1.0.0

# Logout from GHCR
docker logout ghcr.io

# Remove Git hook (optional)
rm .git/hooks/pre-push
```

## Next Steps
This lab establishes the foundation for a complete CI/CD pipeline. Consider extending it with:

- **GitHub Actions:** Replace Git hooks with cloud-based CI
- **Multi-stage scanning:** Include unit tests and linting
- **Branch protection:** Require status checks before merging
- **Deployment automation:** Auto-deploy validated images
- **Monitoring integration:** Alert on security findings
- **Compliance reporting:** Generate security audit reports

## Resources
- [Trivy Documentation](https://aquasecurity.github.io/trivy/)
- [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [Git Hooks](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks)
- [Personal Access Tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)