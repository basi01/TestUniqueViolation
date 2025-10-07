# Windows Build Scripts

This directory contains Windows-specific batch scripts for building and running the TestUniqueViolation Mendix application.

## Files

### `100-build.bat`
**Purpose**: Main build script for Windows environments

**Description**: 
This batch script orchestrates the entire build process for the Mendix application. It:
- Sets up the build environment and error handling
- Navigates to the internal build directory (`../zzz-internal/`)
- Uses Docker Compose to build the application using the Mendix buildpack
- Creates a Docker image containing the compiled Mendix application
- Handles cleanup of temporary build containers and images
- Provides proper exit codes and optional pause for debugging

**Usage**:
```batch
100-build.bat
```

**Key Features**:
- Automatic cleanup of build artifacts on completion
- Error handling with proper exit codes
- Support for buildpack debugging via environment variables
- Uses Docker Compose for reproducible builds

### `900-run.bat`
**Purpose**: Runtime script for starting the application and its dependencies

**Description**:
This batch script starts the complete application stack including:
- PostgreSQL database container
- The built Mendix application container
- Sets up networking between containers
- Configures default admin credentials
- Provides graceful shutdown and cleanup

**Usage**:
```batch
900-run.bat
```

**Key Features**:
- Sets default admin password (`n0t-A-s3cRet`)
- Handles container orchestration via Docker Compose
- Automatic cleanup on exit
- Support for optional command-line parameters
- Built-in delay functionality for container startup sequencing

**Environment**:
- Admin Password: `n0t-A-s3cRet` (configurable via ADMIN_PASSWORD)
- Database: PostgreSQL (testuniqueviolation database)
- Network: Custom Docker network for container communication

## Prerequisites

- Windows with PowerShell or Command Prompt
- Docker Desktop for Windows
- Docker Compose (included with Docker Desktop)

## Execution Order

1. First run `100-build.bat` to build the application image
2. Then run `900-run.bat` to start the application stack

## Error Handling

Both scripts include comprehensive error handling:
- Proper exit codes are maintained throughout execution
- Cleanup is performed even when errors occur
- Optional pause functionality for debugging (controlled by `OPT_PAUSE` environment variable)

## Dependencies

These scripts depend on the Docker configurations and shell scripts in the `../zzz-internal/` directory.