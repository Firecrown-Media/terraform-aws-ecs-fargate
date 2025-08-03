# GitHub Actions Workflows

This directory contains comprehensive GitHub Actions workflows for the terraform-aws-ecs-fargate module, providing automated quality assurance, security scanning, and validation processes.

## 🔄 Workflow Overview

The repository includes two primary workflows designed to ensure code quality, security, and reliability:

### 1. Terraform Module Validation (`terraform-module-validation.yml`)
**Purpose**: Comprehensive validation and testing of Terraform configurations

### 2. Advanced Security Scanning (`security-scan.yml`)
**Purpose**: Deep security analysis and compliance validation

## 📋 Workflow Details

### Terraform Module Validation Workflow

**File**: `.github/workflows/terraform-module-validation.yml`

#### Trigger Events
```yaml
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  workflow_dispatch:
    inputs:
      terraform_version:
        description: 'Terraform version to test'
        required: false
        default: 'latest'
      skip_examples:
        description: 'Skip example validation'
        type: boolean
        required: false
        default: false
```

#### Jobs and Steps

1. **Setup and Preparation**
   - Checkout repository
   - Setup Terraform (multiple versions: 1.6.0, 1.7.0, 1.8.0, latest)
   - Cache Terraform providers
   - Configure AWS credentials (for validation only)

2. **Code Quality Checks**
   - **Terraform Format**: `terraform fmt -check -recursive`
   - **Terraform Validation**: `terraform validate` across all configurations
   - **TFLint Analysis**: AWS and Terraform best practices validation

3. **Security Scanning**
   - **Checkov**: Infrastructure security and compliance scanning
   - **TFSec**: Terraform-specific security analysis
   - **SARIF Upload**: Results uploaded to GitHub Security tab

4. **Documentation Validation**
   - **terraform-docs**: Ensure documentation is up-to-date
   - **Example Validation**: Validate all example configurations
   - **README Consistency**: Check documentation consistency

5. **Multi-Version Compatibility**
   - Test against multiple Terraform versions
   - Ensure backward/forward compatibility
   - Provider version constraint validation

6. **Pull Request Integration**
   - Automated PR comments with validation results
   - Quality gate enforcement
   - Detailed feedback on failures

#### Quality Gates

All the following must pass for workflow success:

✅ **Terraform Format**: Code must be properly formatted  
✅ **Terraform Validation**: All configurations must be valid  
✅ **Security Scans**: No HIGH or CRITICAL findings  
✅ **Linting**: Pass all TFLint rules  
✅ **Documentation**: All docs must be current and accurate  
✅ **Examples**: All examples must validate successfully  

#### Example Output

```bash
✅ Terraform Format Check: PASSED
✅ Terraform Validation: PASSED  
✅ Security Scanning: PASSED (0 HIGH, 2 MEDIUM findings)
✅ TFLint Analysis: PASSED
✅ Documentation: PASSED
✅ Example Validation: PASSED (3/3 examples)
✅ Multi-Version Test: PASSED (4/4 versions)

🎉 All quality gates passed! Ready for merge.
```

### Advanced Security Scanning Workflow

**File**: `.github/workflows/security-scan.yml`

#### Trigger Events
```yaml
on:
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM UTC
  workflow_dispatch:
    inputs:
      scan_type:
        description: 'Type of scan to run'
        required: true
        default: 'full'
        type: choice
        options:
          - full
          - quick
          - compliance-only
      notify_team:
        description: 'Notify security team on failures'
        type: boolean
        default: true
```

#### Security Tools

1. **Checkov** ![Checkov](https://img.shields.io/badge/Checkov-Infrastructure-blue)
   - Infrastructure as Code security scanning
   - CIS benchmarks and compliance validation
   - Custom policy enforcement
   - SARIF output for GitHub integration

2. **TFSec** ![TFSec](https://img.shields.io/badge/TFSec-Terraform-purple)
   - Terraform-specific security analysis
   - AWS resource security validation
   - Sensitive data exposure detection
   - Performance optimized scanning

3. **Semgrep** ![Semgrep](https://img.shields.io/badge/Semgrep-SAST-green)
   - Static Application Security Testing
   - Custom rule set for Terraform
   - Pattern-based vulnerability detection
   - High-precision, low false-positive analysis

4. **Trivy** ![Trivy](https://img.shields.io/badge/Trivy-Vulnerability-red)
   - Configuration vulnerability scanning
   - Multi-format support (Terraform, Dockerfile, etc.)
   - CVE database integration
   - License compliance checking

5. **Custom Compliance Validation**
   - AWS Config rule validation
   - Security group analysis
   - IAM policy validation
   - Encryption compliance checking

#### Scan Types

**Full Scan** (Default)
- All security tools enabled
- Deep analysis with maximum coverage
- Comprehensive reporting
- ~15-20 minutes runtime

**Quick Scan**
- Essential tools only (Checkov + TFSec)
- Faster feedback for development
- Basic security validation
- ~5-8 minutes runtime

**Compliance Only**
- Focus on compliance frameworks
- CIS benchmarks validation
- Regulatory requirement checking
- ~8-12 minutes runtime

#### Security Reporting

1. **SARIF Integration**
   ```yaml
   - name: Upload SARIF results
     uses: github/codeql-action/upload-sarif@v3
     with:
       sarif_file: results.sarif
       category: security-analysis
   ```

2. **GitHub Security Tab**
   - All findings appear in repository Security tab
   - Integration with GitHub Advanced Security
   - Trending analysis and baseline comparison
   - Automated issue creation for HIGH/CRITICAL findings

3. **Team Notifications**
   ```yaml
   - name: Notify Security Team
     if: failure() && inputs.notify_team
     uses: actions/github-script@v7
     with:
       script: |
         github.rest.issues.create({
           owner: context.repo.owner,
           repo: context.repo.repo,
           title: '🚨 Security Scan Failed',
           body: 'Security scan found HIGH or CRITICAL issues...',
           labels: ['security', 'high-priority']
         })
   ```

## 🔧 Configuration Files

### TFLint Configuration (`.tflint.hcl`)

```hcl
# TFLint configuration for AWS and Terraform best practices
config {
  # Enable all rules by default
  disabled_by_default = false
  
  # Terraform version constraint
  terraform_version = "~> 1.6"
}

# AWS provider plugin for AWS-specific rules
plugin "aws" {
  enabled = true
  version = "0.24.1"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
  
  # Deep checking requires AWS credentials
  deep_check = false
}

# Terraform core rules
plugin "terraform" {
  enabled = true
  version = "0.4.0"
  source  = "github.com/terraform-linters/tflint-ruleset-terraform"
  
  preset = "recommended"
}

# Custom rules for this module
rule "terraform_standard_module_structure" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = true
  format  = "snake_case"
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = true
}
```

### Checkov Configuration (`.checkov.yml`)

```yaml
# Checkov security scanning configuration
framework:
  - terraform
  - dockerfile
  - secrets

# Output configuration
output: sarif
sarif-output: checkov-results.sarif

# Skip specific checks if needed
skip-check:
  # Example: Skip check for specific use case
  # - CKV_AWS_144  # Ensure S3 bucket has cross-region replication

# Custom policies directory
external-checks-dir: .checkov/policies

# Severity configuration
severity: HIGH

# Compact output for better readability
compact: true

# Download external checks
download-external-modules: true

# Framework-specific settings
terraform:
  # Scan plan files
  scan-plan: true
  
  # Check for drift
  check-drift: false
  
  # Deep analysis
  deep-analysis: true

# Docker-specific settings (for examples)
dockerfile:
  # Check for security best practices
  security: true
  
  # Check for performance optimizations  
  performance: true

# Secrets scanning
secrets:
  # Scan all files
  all-files: true
  
  # Custom entropy threshold
  entropy-threshold: 4.5
```

## 🚀 Usage Examples

### Running Workflows Manually

#### Terraform Validation with Specific Version
```bash
# Via GitHub CLI
gh workflow run terraform-module-validation.yml \
  -f terraform_version=1.7.0 \
  -f skip_examples=false

# Via GitHub API
curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/owner/repo/actions/workflows/terraform-module-validation.yml/dispatches \
  -d '{"ref":"main","inputs":{"terraform_version":"1.7.0"}}'
```

#### Security Scan with Custom Parameters
```bash
# Quick security scan
gh workflow run security-scan.yml \
  -f scan_type=quick \
  -f notify_team=false

# Full compliance scan
gh workflow run security-scan.yml \
  -f scan_type=compliance-only \
  -f notify_team=true
```

### Local Development Integration

#### Pre-commit Hooks
```bash
# Install pre-commit
pip install pre-commit

# Setup hooks (create .pre-commit-config.yaml)
pre-commit install

# Run hooks manually
pre-commit run --all-files
```

Example `.pre-commit-config.yaml`:
```yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.83.5
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_tflint
      - id: terraform_checkov
```

#### Local Quality Checks
```bash
# Run the same checks locally
make validate    # Terraform format and validate
make security    # Security scanning
make lint        # TFLint analysis
make docs        # Documentation generation
make test        # Full test suite
```

## 📊 Workflow Monitoring

### Workflow Status Badges

Add to your README.md:

```markdown
[![Terraform Validation](https://github.com/owner/repo/workflows/Terraform%20Module%20Validation/badge.svg)](https://github.com/owner/repo/actions/workflows/terraform-module-validation.yml)
[![Security Scan](https://github.com/owner/repo/workflows/Advanced%20Security%20Scanning/badge.svg)](https://github.com/owner/repo/actions/workflows/security-scan.yml)
```

### Metrics and Analytics

Track workflow performance:
- **Success Rate**: Percentage of successful workflow runs
- **Execution Time**: Average workflow duration
- **Security Findings**: Trend of security issues over time
- **Quality Metrics**: Code quality improvements

### Notifications

Configure notifications for workflow events:

1. **Slack Integration**:
```yaml
- name: Slack Notification
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
  if: always()
```

2. **Email Notifications**:
```yaml
- name: Email Notification
  uses: dawidd6/action-send-mail@v3
  with:
    server_address: smtp.gmail.com
    server_port: 587
    username: ${{ secrets.EMAIL_USERNAME }}
    password: ${{ secrets.EMAIL_PASSWORD }}
    subject: Workflow Failed - ${{ github.repository }}
  if: failure()
```

## 🔒 Security Considerations

### Secrets Management

All workflows use GitHub Secrets for sensitive data:

```yaml
# Required secrets
AWS_ACCESS_KEY_ID      # AWS access key for validation
AWS_SECRET_ACCESS_KEY  # AWS secret key for validation
SLACK_WEBHOOK         # Slack notification webhook
EMAIL_PASSWORD        # SMTP password for notifications
```

### Permissions

Workflows use minimal required permissions:

```yaml
permissions:
  contents: read
  security-events: write  # For SARIF upload
  pull-requests: write    # For PR comments
  issues: write          # For issue creation
  actions: read          # For workflow status
```

### Security Scanning Results

Security findings are:
- 🔒 **Private**: Only visible to repository maintainers
- 📊 **Tracked**: Historical trending and analysis
- 🚨 **Actionable**: Automatic issue creation for critical findings
- 📈 **Measurable**: KPIs and metrics for security posture

## 🤝 Contributing to Workflows

### Adding New Checks

1. **Create Custom Check**:
```bash
# Add to .github/workflows/custom-check.yml
name: Custom Quality Check
on: [push, pull_request]
jobs:
  custom_check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run custom validation
        run: ./scripts/custom-check.sh
```

2. **Integrate with Main Workflow**:
```yaml
# Add to terraform-module-validation.yml
- name: Custom Check
  run: |
    echo "Running custom validation..."
    ./scripts/custom-check.sh
```

### Modifying Security Rules

1. **Custom Checkov Policies**:
```bash
# Create .checkov/policies/custom_policy.py
from checkov.common.models.enums import TRUE_VALUES
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck

class CustomSecurityCheck(BaseResourceCheck):
    def __init__(self):
        name = "Custom security check"
        id = "CKV_CUSTOM_001"
        supported_resources = ['aws_ecs_service']
        categories = [CheckCategories.GENERAL_SECURITY]
        super().__init__(name=name, id=id, categories=categories, supported_resources=supported_resources)

    def scan_resource_conf(self, conf):
        # Custom security logic here
        return CheckResult.PASSED
```

2. **Custom TFLint Rules**:
```bash
# Add to .tflint.hcl
rule "custom_naming_convention" {
  enabled = true
}
```

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Terraform GitHub Actions](https://github.com/hashicorp/terraform-github-actions)
- [Security Scanning Best Practices](https://docs.github.com/en/code-security)
- [SARIF Format Specification](https://docs.oasis-open.org/sarif/sarif/v2.1.0/)

## 🤝 Support

For workflow-related issues:

1. **Check Workflow Logs**: GitHub Actions > Workflow Run > Job Details
2. **Review Configuration**: Ensure all required secrets are set
3. **Validate Local Setup**: Run checks locally before pushing
4. **Open Issues**: [GitHub Issues](https://github.com/Firecrown-Media/terraform-aws-ecs-fargate/issues) with workflow logs

---

**💡 Pro Tip**: These workflows are designed to catch issues early and maintain high code quality. They represent industry best practices for Infrastructure as Code development and should serve as a foundation for your own projects.