# Dockerize a React Application with Multi-Stage Build

This project demonstrates how to create a production-ready Docker image for a React application using a multi-stage Docker build. This approach significantly reduces image size, separates build dependencies from runtime dependencies, and prepares your app for deployment.

## Objective

Learn how to:
- Create a React application using Create React App
- Write a multi-stage Dockerfile with Node.js build stage and Nginx serving stage
- Optimize Docker image size by excluding unnecessary files
- Build and run a Docker container locally
- Verify that the final image size is smaller than including all dev dependencies

## Project Structure

```
dockerize-react-app-multistage/
├── src/                           # React source files
│   ├── App.js
│   ├── App.css
│   ├── index.js
│   └── index.css
├── public/                        # Public assets
│   ├── index.html
│   ├── favicon.ico
│   └── manifest.json
├── package.json                   # Node.js dependencies
├── package-lock.json
├── Dockerfile                     # Multi-stage Dockerfile
├── .dockerignore                  # Files to exclude from Docker build
├── nginx.conf                     # Nginx configuration
└── README.md                      # This file
```

## Prerequisites

- **Docker**: Install Docker from [docker.com](https://www.docker.com/)
- **Node.js & npm**: For local development (optional, not needed for Docker build)
- **Git**: For version control

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/vishritesh/dockerize-react-app-multistage.git
cd dockerize-react-app-multistage
```

### 2. Build the Docker Image

Build the Docker image with the following command:

```bash
docker build -t react-app:latest .
```

This command:
- Uses the Dockerfile in the current directory
- Tags the image as `react-app:latest`
- Executes the multi-stage build process

### 3. Run the Docker Container

Run the container on localhost:

```bash
docker run -d -p 80:80 --name react-container react-app:latest
```

Flags explained:
- `-d`: Run in detached mode (background)
- `-p 80:80`: Map port 80 on host to port 80 in container
- `--name react-container`: Assign a name to the container

### 4. Access the Application

Open your browser and navigate to:

```
http://localhost/
```

You should see the React application running!

### 5. Stop and Remove the Container

When done, stop and remove the container:

```bash
# Stop the container
docker stop react-container

# Remove the container
docker rm react-container
```

## Docker Image Sizes

### Without Multi-Stage Build (Not Recommended)
- **Size**: ~900 MB - 1 GB
- **Includes**: Node.js, npm, build tools, and all dev dependencies
- **Problem**: Unnecessary bloat in production

### With Multi-Stage Build (Our Approach)
- **Size**: ~100-150 MB
- **Includes**: Only Nginx and compiled React files
- **Benefit**: ~85-90% smaller image size!

## Understanding the Dockerfile

### Multi-Stage Build Explanation

The Dockerfile has two stages:

#### Stage 1: Build Stage (Node.js)
```dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build
```

**What happens here:**
- Uses lightweight Node.js Alpine image
- Installs all dependencies (including dev dependencies)
- Builds the React app into optimized static files in the `build/` directory
- This stage is temporary and won't be in the final image

#### Stage 2: Production Stage (Nginx)
```dockerfile
FROM nginx:alpine
COPY --from=builder /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

**What happens here:**
- Uses lightweight Nginx Alpine image
- Copies ONLY the built React files from the builder stage
- Configures Nginx to serve the React app
- Exposes port 80
- Starts Nginx as the main process

## .dockerignore File

The `.dockerignore` file prevents unnecessary files from being copied into the Docker build context, speeding up the build process:

```
node_modules
npm-debug.log
.git
.gitignore
.env
.env.local
.DS_Store
CVCS
.idea
.vscode
build
dist
```

## Nginx Configuration

The `nginx.conf` file serves the React app and handles routing:

```nginx
server {
    listen 80;
    location / {
        root /usr/share/nginx/html;
        index index.html;
        try_files $uri $uri/ /index.html;
    }
}
```

**Key points:**
- Listens on port 80
- Serves files from `/usr/share/nginx/html` (where React build files are copied)
- `try_files` directive ensures React Router works correctly by redirecting all routes to `index.html`

## Advanced Commands

### View Docker Image Size

```bash
docker images | grep react-app
```

### Inspect Running Container

```bash
# View logs
docker logs react-container

# Execute command in container
docker exec -it react-container sh
```

### Build with Custom Tag

```bash
docker build -t my-repo/react-app:1.0.0 .
```

### Push to Docker Registry

```bash
# Login to Docker Hub
docker login

# Tag the image
docker tag react-app:latest my-username/react-app:latest

# Push to Docker Hub
docker push my-username/react-app:latest
```

## Troubleshooting

### Port Already in Use

If port 80 is already in use:

```bash
# Use a different port
docker run -d -p 8080:80 --name react-container react-app:latest
# Then access at http://localhost:8080/
```

### Container Exits Immediately

Check logs:

```bash
docker logs react-container
```

### Build Fails

Ensure all files are present and Dockerfile permissions are correct:

```bash
# Check file structure
ls -la

# Rebuild with verbose output
docker build -t react-app:latest . --progress=plain
```

## Best Practices

1. **Use Alpine Images**: Alpine Linux images are much smaller than standard images
2. **Multi-Stage Builds**: Always use multi-stage builds to reduce final image size
3. **Use .dockerignore**: Similar to .gitignore, prevent unnecessary files from being included
4. **Layer Caching**: Order Dockerfile commands to maximize layer caching during builds
5. **Health Checks**: Add health checks for production deployments
6. **Version Pinning**: Use specific version tags instead of `latest`
7. **Security**: Scan images for vulnerabilities using tools like Trivy

## Performance Tips

- **Build Optimization**: Keep dependencies minimal; remove unused packages
- **Nginx Compression**: Enable gzip compression for better performance
- **Caching Strategy**: Separate dependency installation from code copy for better build cache
- **Minimal Base Image**: Alpine versions are 10x smaller than full Ubuntu/Debian images

## Learning Resources

- [Docker Official Documentation](https://docs.docker.com/)
- [Docker Multi-Stage Builds](https://docs.docker.com/build/building/multi-stage/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Create React App Documentation](https://create-react-app.dev/)
- [Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)

## License

MIT License - feel free to use this project as a template for your own Docker deployments.

## Contributing

Contributions are welcome! Feel free to:
- Report bugs
- Suggest improvements
- Submit pull requests

## Author

Created as a learning project for Docker and React deployment.
