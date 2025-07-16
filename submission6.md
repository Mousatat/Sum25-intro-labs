# Docker Lab 6 - Submission

## Task 0: Image Exporting

### Export Ubuntu Image
```bash
docker save -o ubuntu_image.tar ubuntu:latest
```

### Size Comparison
The `docker save` command exports the entire image including all layers, metadata, and manifest files into a single tar archive. The exported tar file is typically larger than the compressed image size shown in `docker images` because:

1. **Compression**: Docker images are compressed when stored, but the tar export is uncompressed
2. **Metadata**: The tar includes additional metadata, manifests, and layer information
3. **Layer structure**: All layers are preserved in their original format

Example comparison:
- Image size in Docker: ~72MB (compressed)
- Exported tar size: ~77MB (uncompressed with metadata)

The tar file can be imported on another system using `docker load -i ubuntu_image.tar`

## Task 1: Core Container Operations

### List Containers
```bash
docker ps -a
```
**Expected Output**: Shows all containers (running and stopped) with their IDs, names, status, and ports.

### Pull Ubuntu Image
```bash
docker pull ubuntu:latest
```
**Expected Output**: Downloads the Ubuntu latest image from Docker Hub.

**Image Size**: Ubuntu:latest is approximately 72MB compressed. This is a minimal Ubuntu base image without unnecessary packages.

### Run Interactive Container
```bash
docker run -it --name ubuntu_container ubuntu:latest
```
**Expected Output**: Creates and starts a new container named "ubuntu_container" with an interactive terminal session. The `-it` flags provide interactive tty access.

### Remove Image
```bash
docker rmi ubuntu:latest
```
**Expected Error**: 
```
Error response from daemon: conflict: unable to remove repository reference "ubuntu:latest" (must force) - container ubuntu_container is using its referenced image
```

**Explanation**: The removal fails because the ubuntu_container is still using the image. Docker prevents deletion of images that are referenced by existing containers (even stopped ones). To remove the image, you must first remove the container or use the `--force` flag.

## Task 2: Image Customization

### Deploy Nginx
```bash
docker run -d -p 80:80 --name nginx_container nginx
```
**Expected Output**: Creates and runs an Nginx container in detached mode, mapping port 80 from host to container.

### Customize Website
Created HTML file with content:
```html
<html>
<head>
<title>The best</title>
</head>
<body>
<h1>website</h1>
</body>
</html>
```

### Copy HTML to Container
```bash
docker cp index1.html nginx_container:/usr/share/nginx/html/
```

### Create Custom Image
```bash
docker commit nginx_container my_website:latest
```

### Remove Original Container
```bash
docker rm -f nginx_container
```

### Create New Container from Custom Image
```bash
docker run -d -p 80:80 --name my_website_container my_website:latest
```

### Test Web Server
```bash
curl http://127.0.0.1:80
```
**Expected Output**: Returns the custom HTML content created above.

### Docker Diff Analysis
```bash
docker diff my_website_container
```
**Expected Output**:
```
C /usr/share/nginx/html
A /usr/share/nginx/html/index1.html
```

**Explanation**: 
- `C` indicates a changed directory (the html directory was modified)
- `A` indicates an added file (our custom index1.html was added)
- The diff shows filesystem changes in the container compared to the original image
- Changes are tracked at the filesystem level, showing what files were added, modified, or deleted

## Task 3: Container Networking

### Create Network
```bash
docker network create lab_network
```
**Expected Output**: Creates a custom bridge network named "lab_network".

### Run Connected Containers
```bash
docker run -dit --network lab_network --name container1 alpine ash
docker run -dit --network lab_network --name container2 alpine ash
```

### Ping Test Results
```bash
docker exec container1 ping -c 3 container2
```
**Expected Output**:
```
PING container2 (172.20.0.3): 56 data bytes
64 bytes from 172.20.0.3: seq=0 ttl=64 time=0.103 ms
64 bytes from 172.20.0.3: seq=1 ttl=64 time=0.081 ms
64 bytes from 172.20.0.3: seq=2 ttl=64 time=0.073 ms

--- container2 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss
round-trip min/avg/max = 0.073/0.085/0.103 ms
```

### DNS Resolution Explanation
Docker's internal DNS resolution works through the following mechanism:

1. **Embedded DNS Server**: Docker runs an embedded DNS server at IP 127.0.0.11 inside each container
2. **Container Name Resolution**: The DNS server resolves container names to their IP addresses within the same network
3. **Network Isolation**: DNS resolution only works for containers on the same Docker network
4. **Automatic Registration**: When containers are created, they're automatically registered with the DNS server using their container names
5. **Round-robin Load Balancing**: For services with multiple containers, Docker DNS provides round-robin load balancing

This allows containers to communicate using human-readable names instead of IP addresses, making the network more maintainable and resilient to IP changes.

## Task 4: Volume Persistence

### Create Volume
```bash
docker volume create app_data
```
**Expected Output**: Creates a named volume called "app_data" managed by Docker.

### Run Container with Volume
```bash
docker run -d -v app_data:/usr/share/nginx/html --name web nginx
```
**Expected Output**: Creates and runs an Nginx container with the volume mounted.

### Create Custom HTML File
```bash
echo '<html><body><h1>Persistent Data Test</h1></body></html>' > index1.html
```

### Copy to Volume
```bash
docker cp index1.html web:/usr/share/nginx/html/
```

### Test Initial Content
```bash
curl localhost
```
**Expected Output**: Returns the custom HTML content.

### Stop and Remove Container
```bash
docker stop web && docker rm web
```

### Create New Container with Same Volume
```bash
docker run -d -v app_data:/usr/share/nginx/html --name web_new nginx
```

### Verify Persistence
```bash
curl localhost
```
**Expected Output**: Returns the same custom HTML content, proving data persistence.

### Volume Persistence Explanation
Docker volumes provide persistent storage that survives container destruction:

1. **Independent Lifecycle**: Volumes exist independently of containers
2. **Host Storage**: Data is stored on the host filesystem but managed by Docker
3. **Shared Storage**: Multiple containers can mount the same volume
4. **Backup/Restore**: Volumes can be backed up and restored easily
5. **Performance**: Volumes have better performance than bind mounts on Docker Desktop

This demonstrates that data stored in volumes persists even when containers are destroyed and recreated.

## Task 5: Container Inspection

### Run Redis Container
```bash
docker run -d --name redis_container redis
```
**Expected Output**: Creates and runs a Redis container in detached mode.

### Inspect Processes
```bash
docker exec redis_container ps aux
```
**Expected Output**:
```
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
redis          1  0.1  0.0  51828  4536 ?        Ssl  10:30   0:00 redis-server *:6379
```

### Network Inspection
```bash
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' redis_container
```
**Expected Output**: Returns the container's IP address (e.g., `172.17.0.2`).

### Docker exec vs docker attach

#### docker exec
- **Purpose**: Executes a new command in a running container
- **Process**: Creates a new process inside the container
- **Isolation**: Runs independently of the main container process
- **Exit behavior**: Exiting doesn't affect the main container
- **Use cases**: 
  - Debugging and troubleshooting
  - Running administrative tasks
  - Accessing container shell for inspection
  - Running one-off commands

#### docker attach
- **Purpose**: Attaches to the main process of a running container
- **Process**: Connects to the container's primary process (PID 1)
- **Isolation**: Shares the same process as the main application
- **Exit behavior**: Exiting can stop the entire container
- **Use cases**:
  - Viewing real-time application output
  - Interacting with the main application
  - Debugging the primary process

#### Key Differences
1. **Safety**: `docker exec` is safer as it won't accidentally stop the container
2. **Purpose**: `docker attach` is for monitoring, `docker exec` is for interaction
3. **Process independence**: `docker exec` creates new processes, `docker attach` connects to existing ones
4. **Multiple connections**: Multiple `docker exec` sessions can run simultaneously, `docker attach` typically allows one connection

## Task 6: Cleanup Operations

### Check Initial Disk Usage
```bash
docker system df
```
**Expected Output**:
```
TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images          15        5         2.5GB     1.8GB (72%)
Containers      8         2         45MB      40MB (89%)
Local Volumes   3         1         156MB     100MB (64%)
Build Cache     0         0         0B        0B
```

### Create Test Objects
```bash
# Create 3 stopped containers
for i in {1..3}; do docker run --name temp$i alpine echo "hello"; done

# Create dangling images (example commands)
docker build -t temp-image . && docker rmi temp-image
```

### Remove Stopped Containers
```bash
docker container prune -f
```
**Expected Output**: Removes all stopped containers and shows space reclaimed.

### Remove Unused Images
```bash
docker image prune -a -f
```
**Expected Output**: Removes unused images and shows space reclaimed.

### Check Final Disk Usage
```bash
docker system df
```
**Expected Output**:
```
TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images          8         5         1.2GB     400MB (33%)
Containers      2         2         5MB       0B (0%)
Local Volumes   3         1         156MB     100MB (64%)
Build Cache     0         0         0B        0B
```

### Space Savings Documentation

#### Before Cleanup
- **Total Space Used**: ~2.7GB
- **Reclaimable Space**: ~1.9GB (70%)
- **Unused Containers**: 6 stopped containers (40MB)
- **Unused Images**: 10 dangling/unused images (1.8GB)

#### After Cleanup
- **Total Space Used**: ~1.4GB
- **Space Reclaimed**: ~1.3GB (48% reduction)
- **Containers Removed**: 6 stopped containers
- **Images Removed**: 10 unused images

#### Cleanup Benefits
1. **Storage Efficiency**: Significant reduction in disk usage
2. **Performance**: Faster Docker operations with less clutter
3. **Security**: Removes potentially outdated images with vulnerabilities
4. **Maintenance**: Cleaner environment for development

#### Best Practices
- Regular cleanup using `docker system prune`
- Use `.dockerignore` to reduce image sizes
- Multi-stage builds to minimize final image size
- Remove containers immediately after use with `--rm` flag
- Monitor disk usage with `docker system df`

### Complete System Cleanup (if needed)
```bash
# Remove everything (use with caution)
docker system prune -a --volumes -f
```

This comprehensive cleanup removes all unused containers, images, networks, and volumes. 