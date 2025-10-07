# Build Scripts

This directory contains build automation scripts for the TestUniqueViolation Mendix project. The build system is designed to work with Docker and supports both Windows and cross-platform development environments.

## Directory Structure

- **`windows/`** - Windows-specific batch scripts for building and running the application
- **`zzz-internal/`** - Internal build system components including Docker configurations and shell scripts

## Overview

The build system uses a containerized approach to ensure consistent builds across different environments. It leverages the Mendix Docker buildpack to:

1. Build the Mendix application into a deployment archive (MDA)
2. Create a Docker image containing the application
3. Run the application with its dependencies (PostgreSQL database)

## Prerequisites

- Docker Desktop or Docker Engine
- Docker Compose
- Access to the internet (for downloading base images and buildpack)

## Quick Start

### Windows
```batch
# Build the application
cd windows
100-build.bat

# Run the application
900-run.bat
```

### Cross-platform
Use the Docker Compose files directly from the `zzz-internal/` directory.

## Architecture

The build process follows these steps:

1. **Builder Image Creation**: Creates a Ubuntu-based builder image with Git and Python
2. **Buildpack Cloning**: Downloads the Mendix Docker buildpack from GitHub
3. **MDA Generation**: Converts the Mendix project (.mpr) into a deployment archive
4. **Application Image**: Builds the final Docker image containing the Mendix runtime
5. **Runtime Environment**: Starts the application with PostgreSQL database

## Environment Variables

- `BUILDPACK_XTRACE`: Enable verbose buildpack logging
- `BUILDKIT_PROGRESS`: Control Docker build output format
- `ADMIN_PASSWORD`: Default admin password for the running application

## Network Configuration

The application runs on a custom Docker network and exposes:
- Application: Port 4078 (mapped from the dumb proxy container)
- PostgreSQL: Port 4079 (mapped to container's 5432)