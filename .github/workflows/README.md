# GitHub Actions Workflows

This directory contains the GitHub Actions workflows for the Sum25-intro-labs repository.

## Available Workflows

### CI/CD Pipeline (`ci-cd-pipeline.yml`)

A comprehensive CI/CD pipeline that demonstrates fundamental GitHub Actions concepts and system information gathering.

#### Triggers
- **Push**: Automatically runs on push to `main` or `master` branches
- **Pull Request**: Runs on pull requests targeting `main` or `master` branches  
- **Manual**: Can be triggered manually via GitHub Actions UI (`workflow_dispatch`)

#### Jobs

1. **build-and-test**
   - Runs on `ubuntu-latest`
   - Checks out repository code
   - Sets up Node.js environment
   - Performs basic build and test simulations
   - Displays greeting messages and timestamps

2. **system-info** 
   - Depends on successful completion of `build-and-test`
   - Gathers comprehensive system information:
     - Runner environment details
     - Hardware specifications (CPU, memory, disk)
     - Operating system information
     - Available tools and versions
     - GitHub Actions context data

3. **code-quality**
   - Runs in parallel with `build-and-test`
   - Analyzes project structure
   - Validates Markdown files
   - Reports repository metrics

#### Usage

The workflow will automatically execute when:
- Code is pushed to main/master branches
- Pull requests are created targeting main/master branches

To manually trigger the workflow:
1. Go to the repository on GitHub
2. Click "Actions" tab
3. Select "CI/CD Pipeline" workflow
4. Click "Run workflow" button

#### Purpose

This workflow was created as part of Lab 3 to demonstrate:
- Basic GitHub Actions setup following the official quickstart guide
- Manual workflow triggering capabilities
- System information gathering and reporting
- Multi-job workflow coordination
- CI/CD best practices implementation

For detailed documentation and observations, see `submission3.md` in the repository root. 