# UmbDocker - Umbraco CMS Docker Project

A containerized Umbraco CMS application built with .NET 10.0 and Docker.
Some details:

- Umbraco v17 (LTS)
- Clean starterkit
- Diplo.GodMode

## Prerequisites

- [Docker](https://www.docker.com/get-started) (version 20.10 or higher)
- [Docker Compose](https://docs.docker.com/compose/install/) (version 2.0 or higher)

## Quick Start

### Local Development with Docker Compose

1. **Clone the repository:**

   ```bash
   git clone <repository-url>
   cd UmbDocker
   ```

2. **Build and start the application:**

   ```bash
   docker-compose up -d
   ```

3. **Access the application:**
   - Open your browser and navigate to: `http://localhost:5000`
   - First-time setup: Follow the Umbraco installation wizard

4. **View logs:**

   ```bash
   docker-compose logs -f umbdocker
   ```

5. **Stop the application:**
   ```bash
   docker-compose down
   ```

### Building the Docker Image

To build the Docker image manually:

```bash
docker build -t umbdocker:latest .
```

### Running the Container

To run the container without Docker Compose:

```bash
docker run -d \
  -p 5000:8080 \
  -v ./umbraco/Data:/app/umbraco/Data \
  -v ./umbraco/Logs:/app/umbraco/Logs \
  -v ./umbraco/media:/app/wwwroot/media \
  --name umbdocker \
  umbdocker:latest
```

## Project Structure

```
UmbDocker/
├── .github/workflows/      # CI/CD automation
├── src/                    # Application source code
│   ├── Controllers/        # Custom controllers
│   ├── Models/            # Custom models
│   ├── Views/             # Razor templates
│   ├── wwwroot/           # Static assets
│   └── ...
├── umbraco/               # Runtime data (gitignored)
│   ├── Data/              # SQLite database
│   ├── Logs/              # Application logs
│   └── media/             # Uploaded media files
├── .dockerignore
├── .gitignore
├── Dockerfile
├── docker-compose.yml
└── README.md
```

## Configuration

### Environment Variables

Copy `.env.example` to `.env` and adjust values:

```bash
cp .env.example .env
```

Available environment variables:

- `ASPNETCORE_ENVIRONMENT` - Application environment (Development/Production)
- `HOST_PORT` - Port on host machine (default: 5000)
- `BUILD_CONFIGURATION` - Build configuration (Debug/Release)

### Persistent Data

The following directories are mounted as volumes for data persistence:

- `./umbraco/Data` - SQLite database files
- `./umbraco/Logs` - Application logs
- `./umbraco/media` - Uploaded media files

## Development

### .NET Development

To run the application locally without Docker:

```bash
cd src
dotnet restore
dotnet run
```

### Rebuild After Changes

If you make changes to the application code:

```bash
docker-compose up -d --build
```

## CI/CD

This project uses GitHub Actions for automated builds and deployments:

- **On Pull Requests**: Builds and pushes Docker image tagged with `pr-<number>`
- **On Main Branch**: Builds and pushes Docker image tagged with `latest` and commit SHA

Images are pushed to GitHub Container Registry (ghcr.io).

## Technology Stack

- **Framework**: .NET 10.0
- **CMS**: Umbraco CMS (latest)
- **Database**: SQLite (file-based)
- **Container**: Docker + Docker Compose
- **CI/CD**: GitHub Actions

## Umbraco Backoffice Access

After initial setup, access the Umbraco backoffice at:

- URL: `http://localhost:5000/umbraco`
- Follow the installation wizard to create an admin account

## Troubleshooting

### Port Already in Use

If port 5000 is already in use, change the `HOST_PORT` in `.env` or modify `docker-compose.yml`:

```yaml
ports:
  - "8080:8080" # Change host port to 8080
```

### Permission Issues

On Linux/Mac, if you encounter permission issues with volume mounts:

```bash
sudo chown -R $USER:$USER ./umbraco
```

### Database Issues

To reset the database, remove the SQLite files:

```bash
rm -rf ./umbraco/Data/*.db*
docker-compose restart
```

## License

[Specify your license here]

## Contributing

[Add contribution guidelines here]
