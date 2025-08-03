# Contributing to terraform-aws-ecs-fargate

Thank you for your interest in contributing to the terraform-aws-ecs-fargate module! This document provides guidelines for contributing to this Terraform module that provisions AWS ECS Fargate infrastructure.

## 📋 Table of Contents

- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Module Standards](#module-standards)
- [Testing Requirements](#testing-requirements)
- [Documentation Standards](#documentation-standards)
- [Security Guidelines](#security-guidelines)
- [Review Process](#review-process)
- [Release Process](#release-process)

## 🚀 Getting Started

### Prerequisites

- **Terraform** >= 1.6.0
- **AWS CLI** configured with appropriate permissions
- **Git** for version control
- **Go** >= 1.19 (for testing)
- **terraform-docs** for documentation generation
- **tfsec** for security scanning (optional but recommended)

### Local Development Setup

1. **Fork and Clone**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/terraform-aws-ecs-fargate.git
   cd terraform-aws-ecs-fargate
   ```

2. **Install Development Tools**:
   ```bash
   # Install terraform-docs
   brew install terraform-docs
   
   # Install tfsec for security scanning
   brew install tfsec
   
   # Install pre-commit hooks (optional)
   pip install pre-commit
   pre-commit install
   ```

3. **Validate Installation**:
   ```bash
   terraform --version
   terraform-docs --version
   tfsec --version
   ```

## 🔄 Development Workflow

### Branch Naming

Use descriptive branch names with prefixes:

- `feature/` - New features
- `fix/` - Bug fixes  
- `docs/` - Documentation updates
- `refactor/` - Code refactoring
- `test/` - Test improvements
- `chore/` - Maintenance tasks

**Examples:**
- `feature/add-fargate-spot-support`
- `fix/alb-listener-certificate-issue`
- `docs/update-usage-examples`

### Commit Messages

Follow conventional commit format:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Examples:**
```
feat(autoscaling): add support for custom scaling metrics

- Add variables for custom CloudWatch metrics
- Implement target tracking scaling policies
- Update documentation with examples

Closes #42
```

```
fix(security): resolve security group ingress rule conflict

The ALB security group was allowing overly broad access.
Updated to use specific port ranges and source security groups.

Fixes #38
```

## 📐 Module Standards

### File Organization

```
terraform-aws-ecs-fargate/
├── main.tf                 # Core ECS resources
├── alb.tf                  # Application Load Balancer resources
├── autoscaling.tf          # Auto scaling policies
├── dns.tf                  # Route53 and SSL certificate resources
├── monitoring.tf           # CloudWatch resources
├── security.tf             # Security groups and IAM roles
├── storage.tf              # EFS and S3 resources
├── service-discovery.tf    # AWS Cloud Map resources
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── versions.tf             # Provider requirements (if needed)
├── locals.tf               # Local values (if needed)
├── examples/               # Usage examples
├── README.md               # Module documentation
└── CONTRIBUTING.md         # This file
```

### Terraform Code Standards

1. **Resource Naming**:
   ```hcl
   resource "aws_ecs_cluster" "main" {
     name = var.name
     
     # Use consistent naming patterns
     tags = merge(var.tags, {
       Name = "${var.name}-cluster"
     })
   }
   ```

2. **Variable Definitions**:
   ```hcl
   variable "enable_spot_instances" {
     description = "Enable Fargate Spot instances for cost optimization"
     type        = bool
     default     = false
     
     # Include validation where appropriate
     validation {
       condition     = var.enable_spot_instances == true || var.enable_spot_instances == false
       error_message = "enable_spot_instances must be a boolean value."
     }
   }
   ```

3. **Output Definitions**:
   ```hcl
   output "ecs_cluster_arn" {
     description = "ARN of the ECS cluster"
     value       = aws_ecs_cluster.main.arn
   }
   ```

4. **Conditional Resources**:
   ```hcl
   resource "aws_lb" "main" {
     count = var.create_alb ? 1 : 0
     
     name               = "${var.name}-alb"
     load_balancer_type = "application"
     # ... other configuration
   }
   ```

### Code Quality Standards

1. **Formatting**: Always run `terraform fmt` before committing
2. **Validation**: Ensure `terraform validate` passes
3. **Documentation**: Update README.md when adding new features
4. **Comments**: Add comments for complex logic or non-obvious configurations
5. **Consistency**: Follow existing patterns and naming conventions

## 🧪 Testing Requirements

### Pre-commit Validation

Before submitting a PR, run these checks:

```bash
# Format code
terraform fmt -recursive

# Validate configuration  
terraform validate

# Generate documentation
terraform-docs markdown table --output-file README.md .

# Security scan (optional but recommended)
tfsec .

# Check for common issues
terraform plan # with appropriate variables
```

### Example Testing

Test your changes with the provided examples:

```bash
cd examples/basic-web-app
terraform init
terraform plan -var-file="example.tfvars"
```

### Integration Testing

For significant changes, test with real AWS resources:

1. **Use a test AWS account** or isolated environment
2. **Deploy and verify** the infrastructure works as expected
3. **Test scaling, monitoring, and other features**
4. **Clean up resources** after testing

### Automated Testing

We encourage adding automated tests for complex features:

```go
// Example Terratest structure
func TestECSFargateModule(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../examples/basic-web-app",
        Vars: map[string]interface{}{
            "name": "test-ecs-fargate",
        },
    }
    
    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)
    
    // Add assertions here
}
```

## 📚 Documentation Standards

### README Structure

The README.md should include:

1. **Description** - Module purpose and capabilities
2. **Features** - Key features and benefits  
3. **Requirements** - Terraform and provider versions
4. **Usage** - Basic and advanced examples
5. **Inputs** - All variable documentation
6. **Outputs** - All output documentation
7. **Examples** - Links to example configurations

### Variable Documentation

```hcl
variable "example_var" {
  description = <<-EOT
    Detailed description of what this variable does.
    Include any constraints, defaults, or special considerations.
    
    Example:
    ```
    example_var = "some_value"
    ```
  EOT
  type        = string
  default     = null
}
```

### Output Documentation

```hcl
output "example_output" {
  description = "Clear description of what this output provides and how to use it"
  value       = aws_resource.example.attribute
}
```

### Auto-generated Documentation

We use terraform-docs to auto-generate parts of the README:

```bash
# Generate documentation
terraform-docs markdown table --output-file README.md .

# Or with custom template
terraform-docs markdown table \
  --header-from main.tf \
  --output-file README.md .
```

## 🔒 Security Guidelines

### Security Best Practices

1. **IAM Policies**: Use least-privilege principles
2. **Security Groups**: Minimal required access only  
3. **Encryption**: Enable encryption at rest and in transit
4. **Secrets**: Never hardcode secrets or credentials
5. **Network**: Use private subnets for application resources

### Security Group Example

```hcl
resource "aws_security_group" "alb" {
  name_prefix = "${var.name}-alb-"
  vpc_id      = var.vpc_id

  # Specific ingress rules only
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  # Egress to ECS tasks only
  egress {
    description     = "To ECS tasks"
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks.id]
  }

  tags = var.tags
}
```

### Security Testing

```bash
# Run security scanning
tfsec .

# Check for hardcoded secrets
git secrets --scan

# Validate IAM policies
terraform plan | grep -i "policy"
```

## 🔍 Review Process

### Pull Request Requirements

1. **Title**: Clear, descriptive title
2. **Description**: Detailed description of changes
3. **Testing**: Evidence of testing performed
4. **Documentation**: Updated documentation if needed
5. **Breaking Changes**: Clearly marked if applicable

### PR Checklist

- [ ] Code follows Terraform best practices
- [ ] `terraform fmt` and `terraform validate` pass
- [ ] Documentation updated (README.md, variables, outputs)
- [ ] Examples work with changes
- [ ] Security considerations addressed
- [ ] Backward compatibility maintained (or breaking changes documented)
- [ ] Tests pass (if applicable)

### Review Criteria

Reviewers will evaluate:

- **Functionality**: Does it work as intended?
- **Security**: Are there security implications?
- **Performance**: Impact on AWS costs and performance
- **Maintainability**: Is the code readable and maintainable?
- **Compatibility**: Backward compatibility considerations
- **Documentation**: Is it properly documented?

## 🚢 Release Process

### Versioning Strategy

We follow [Semantic Versioning](https://semver.org/):

- **MAJOR** (v2.0.0): Breaking changes
- **MINOR** (v1.1.0): New features (backward compatible)
- **PATCH** (v1.0.1): Bug fixes (backward compatible)

### Release Workflow

1. **Update Version References**:
   ```bash
   # Update version in README examples
   sed -i 's/ref=v1.0.0/ref=v1.1.0/g' README.md
   ```

2. **Update CHANGELOG.md**:
   ```markdown
   ## [1.1.0] - 2025-01-15
   
   ### Added
   - Fargate Spot instance support
   - EFS Intelligent Tiering option
   
   ### Fixed
   - ALB health check timeout issue
   ```

3. **Create Release Tag**:
   ```bash
   git tag -a v1.1.0 -m "Release version 1.1.0"
   git push origin v1.1.0
   ```

4. **GitHub Release**: Create GitHub release with release notes

### Breaking Changes

For breaking changes:

1. **Document migration steps** in CHANGELOG
2. **Update major version** number
3. **Provide migration examples** 
4. **Consider deprecation period** for major features

## 🤔 Questions and Support

### Getting Help

- **GitHub Issues**: For bugs and feature requests
- **GitHub Discussions**: For questions and ideas
- **Documentation**: Check README and examples first

### Reporting Issues

When reporting issues, include:

- Terraform version
- AWS provider version  
- Module version
- Minimal reproduction example
- Error messages and logs
- Expected vs actual behavior

### Feature Requests

For feature requests, describe:

- Use case and problem being solved
- Proposed solution approach
- Example usage or configuration
- Impact on existing functionality

---

Thank you for contributing to terraform-aws-ecs-fargate! Your contributions help make AWS ECS Fargate deployments easier and more reliable for everyone. 🚀