# Clean Package Views Missing in Docker Builds - Fix Documentation

## Problem Overview

The **Clean** Umbraco starter kit package (v7.0.5) uses NuGet `contentFiles` to distribute views, assets, and other content. These files are not automatically included in Docker builds during CI/CD workflows.

## Root Cause

### How NuGet contentFiles Work

1. **Local Development**: When you run `dotnet restore` or `dotnet build` locally, NuGet automatically extracts contentFiles from packages into your project directory.

2. **CI/CD Environments**: In automated build environments (like GitHub Actions), NuGet packages are restored but contentFiles are **NOT automatically extracted** by default. This is by design to avoid modifying source files during CI builds.

3. **Docker Multi-Stage Builds**: When building Docker images, each stage starts fresh, and without proper configuration, the Clean package views never get extracted into the `/app/publish` directory.

## The Solution

### Changes Made

#### 1. GitHub Workflow (`docker-build.yml`)
Added `CI=true` as a build argument:

```yaml
build-args: |
  BUILD_CONFIGURATION=Release
  CI=true
```

This sets the environment variable that triggers the custom MSBuild target.

#### 2. Dockerfile
Updated to accept and pass the CI build argument:

```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
ARG BUILD_CONFIGURATION=Release
ARG CI=false
ENV BUILD_CONFIGURATION=$BUILD_CONFIGURATION
ENV CI=$CI
```

#### 3. UmbDocker.csproj
Improved the MSBuild target to force content extraction:

```xml
<Target Name="ForceCleanExtraction" BeforeTargets="BeforeBuild" Condition="'$(CI)' == 'true'">
    <Message Importance="high" Text="Forcing Clean Starter Kit asset extraction for CI environment..." />
    <Message Importance="high" Text="CI Environment Variable: $(CI)" />
    <Exec Command="dotnet restore --force" />
</Target>
```

## How It Works Now

1. **GitHub Actions** sets `CI=true` when building the Docker image
2. **Dockerfile** receives and sets the `CI` environment variable
3. **MSBuild Target** detects `CI=true` and forces NuGet to extract contentFiles
4. **Clean package views** are properly extracted before the `dotnet publish` step
5. **Final Docker image** includes all views, assets, and content from the Clean package

## Verification

### Check if Views Are Included

After building the Docker image:

```bash
# Build the image
docker build -t umbdocker:test .

# Run a temporary container
docker run --rm -it --entrypoint /bin/bash umbdocker:test

# Inside the container, check for Clean views
ls -la /app/Views/
ls -la /app/wwwroot/assets/
```

You should see views and assets from the Clean package.

### Build Logs

During the Docker build, you should see:

```
Forcing Clean Starter Kit asset extraction for CI environment...
CI Environment Variable: true
```

## Alternative: Switch to Clean.Core

According to the [Clean package documentation](https://github.com/prjseal/Clean), after initial setup, you should switch from `Clean` to `Clean.Core`:

```bash
dotnet remove "MyProject" package Clean
dotnet add "MyProject" package Clean.Core --version 7.0.5
```

**Why?**
- **Clean**: Full package with contentFiles for initial setup
- **Clean.Core**: Core functionality only, without contentFiles that could override your customizations

### For Docker Deployments

If you're deploying via Docker and want to preserve the Clean theme:

1. **First Run**: Use the `Clean` package and build locally to extract all content
2. **Commit Changes**: Commit the extracted views and assets to your repository
3. **Switch to Clean.Core**: Replace `Clean` with `Clean.Core` in your `.csproj`
4. **Docker Builds**: Now your Docker images will include the committed files without needing contentFiles extraction

## Additional Resources

- **Clean Package**: https://github.com/prjseal/Clean
- **Clean.Core Package**: https://www.nuget.org/packages/Clean.Core
- **NuGet ContentFiles**: https://learn.microsoft.com/en-us/nuget/reference/nuspec#including-content-files
- **Docker Multi-Stage Builds**: https://docs.docker.com/build/building/multi-stage/

## Troubleshooting

### Views Still Not Appearing?

1. **Check CI variable**:
   ```bash
   # In Dockerfile, add debug output
   RUN echo "CI Variable: $CI"
   ```

2. **Verify MSBuild target**:
   ```bash
   # Add verbose logging
   RUN dotnet build -v detailed
   ```

3. **Manual extraction** (temporary workaround):
   ```dockerfile
   # Add after dotnet restore
   RUN dotnet restore --force
   ```

### For Local Docker Builds

If building locally with `docker build`:

```bash
docker build --build-arg CI=true -t umbdocker:local .
```

Or update your `docker-compose.yml`:

```yaml
build:
  context: .
  dockerfile: Dockerfile
  args:
    BUILD_CONFIGURATION: Release
    CI: "true"
```
