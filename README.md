GeoLearner - Interactive Geography Learning App
Overview
GeoLearner is an interactive web application that teaches geography using the REST Countries API. It provides flashcards, quizzes, and daily challenges to help users learn about countries, capitals, and currencies.
Core Functionality

Interactive Flashcards: Learn countries, capitals, and currencies
Multiple Choice Quiz: Test knowledge with randomized questions
Daily Challenge: Special country challenge that changes daily
Continent Filtering: Focus learning on specific geographic regions
Real-time Statistics: Track accuracy, streaks, and progress
Dark Mode Toggle: Switch between light and dark themes
Responsive Design: Works on desktop and mobile devices

API Integration

External API: REST Countries API (https://restcountries.com/v3.1/)
Endpoint: /all?fields=name,capital,currencies,flag,region,flags
Data Usage: Real-time country information including names, capitals, currencies, flags, and regions
Error Handling: Graceful fallbacks for API failures
API Documentation: https://restcountries.com/

Project Structure
geolearner/
├── public/
│   └── index.html          # Main application file
├── Dockerfile              # Container configuration
├── package.json            # Node.js dependencies
├── .dockerignore          # Docker ignore file
└── README.md              # Documentation
Docker Hub Repository

Repository URL: https://hub.docker.com/r/kimanzialu/geolearner
Image Name: kimanzialu/geolearner
Available Tags: v1, latest

Local Development
Prerequisites

Docker installed on your system
Git for cloning the repository

Running Locally
bash# Clone the repository
git clone https://github.com/kimanzialu/GeoLearner.git
cd GeoLearner

# Build the Docker image
docker build -t kimanzialu/geolearner:v1 .

# Run locally
docker run -p 8080:8080 kimanzialu/geolearner:v1

# Verify it works
curl http://localhost:8080
# Or open http://localhost:8080 in your browser
Docker Hub Deployment
Build Instructions
bash# Build the Docker image with proper tags
docker build -t kimanzialu/geolearner:v1 .
docker build -t kimanzialu/geolearner:latest .

# Test the image locally before pushing
docker run -p 8080:8080 kimanzialu/geolearner:v1
Push to Docker Hub
bash# Login to Docker Hub
docker login

# Push both tags
docker push kimanzialu/geolearner:v1
docker push kimanzialu/geolearner:latest
Pull and Run from Docker Hub
bash# Pull the latest image
docker pull kimanzialu/geolearner:v1

# Run the pulled image
docker run -d --name geolearner-app --restart unless-stopped -p 8080:8080 kimanzialu/geolearner:v1
Production Deployment
Prerequisites - Lab Infrastructure Setup
Note: This project requires the separate lab infrastructure. Set it up first:
bash# Clone lab infrastructure separately
git clone https://github.com/waka-man/web_infra_lab.git
cd web_infra_lab
docker compose up -d --build

# Verify containers are running
docker compose ps
Container Setup

web-01 (172.20.0.11): SSH port 2211, HTTP port 8080
web-02 (172.20.0.12): SSH port 2212, HTTP port 8081
lb-01 (172.20.0.10): SSH port 2210, HTTP port 8082

Deployment Steps
1. Deploy Application on Web Servers
On web-01:
bash# SSH into web-01
ssh ubuntu@localhost -p 2211  # Password: pass123

# Pull and run the Docker image
docker pull kimanzialu/geolearner:v1
docker run -d --name geolearner-app --restart unless-stopped -p 8080:8080 kimanzialu/geolearner:v1

# Verify the container is running
docker ps
curl http://localhost:8080
On web-02:
bash# SSH into web-02
ssh ubuntu@localhost -p 2212  # Password: pass123

# Pull and run the same Docker image
docker pull kimanzialu/geolearner:v1
docker run -d --name geolearner-app --restart unless-stopped -p 8080:8080 kimanzialu/geolearner:v1

# Verify the container is running
docker ps
curl http://localhost:8080
2. Configure Load Balancer
On lb-01:
bash# SSH into lb-01
ssh ubuntu@localhost -p 2210  # Password: pass123

# Install HAProxy
sudo apt update && sudo apt install -y haproxy

# Configure HAProxy
sudo nano /etc/haproxy/haproxy.cfg
HAProxy Configuration:
global
    daemon
    maxconn 256

defaults
    mode http
    timeout connect 5s
    timeout client 50s
    timeout server 50s

frontend http-in
    bind *:80
    default_backend webapps

backend webapps
    balance roundrobin
    server web01 172.20.0.11:8080 check
    server web02 172.20.0.12:8080 check
    http-response set-header X-Served-By %[srv_name]
Start HAProxy:
bash# Test configuration
sudo haproxy -f /etc/haproxy/haproxy.cfg -c

# Start HAProxy
sudo service haproxy restart

# Verify HAProxy is running
sudo service haproxy status
Testing and Verification
Individual Server Testing
bash# Test web-01 directly
curl http://localhost:8080

# Test web-02 directly  
curl http://localhost:8081
Load Balancer Testing
bash# Test load balancing with headers
curl -I http://localhost:8082

# Automated round-robin test with evidence
for i in {1..6}; do 
    echo "Request $i:"; 
    curl -I http://localhost:8082 2>/dev/null | grep X-Served-By; 
    sleep 1; 
done
Expected Testing Results
You should see alternating responses like:
Request 1:
X-Served-By: web01

Request 2:
X-Served-By: web02

Request 3:
X-Served-By: web01
Security Considerations
API Key Handling

The REST Countries API is public and doesn't require API keys
For applications with sensitive API keys, use environment variables:

bash# Example for applications with API keys
docker run -e API_KEY=your_secret_key -p 8080:8080 kimanzialu/geolearner:v1
Production Hardening

Use HTTPS in production environments
Implement rate limiting
Add proper logging and monitoring
Use secrets management for sensitive data

Troubleshooting
Common Issues

Container not starting: Check Docker logs with docker logs geolearner-app
Port conflicts: Ensure port 8080 is not in use by other services
API failures: The app includes error handling for REST Countries API downtime
Load balancer issues: Verify HAProxy configuration and backend server health

Docker Commands for Debugging
bash# View container logs
docker logs geolearner-app

# Access container shell
docker exec -it geolearner-app sh

# Stop and remove container
docker stop geolearner-app
docker rm geolearner-app
Technology Stack

Frontend: Vanilla HTML/CSS/JavaScript
Containerization: Docker with Node.js Alpine base image
Web Server: Node.js Express server
Load Balancing: HAProxy with round-robin algorithm
Health Checks: HAProxy monitors backend server availability
API: REST Countries API for real-time country data

Credits and Attribution

REST Countries API: https://restcountries.com/ - Provides comprehensive country data
Docker: Containerization platform
HAProxy: High-performance load balancer
Lab Infrastructure: Based on https://github.com/waka-man/web_infra_lab

Demo Video
Demo Video Link: https://www.veed.io/view/86f83d27-4d15-4541-8b64-549cd17a268b?panel=share
The demo video showcases:

Local application functionality
Docker container deployment
Load balancer configuration
Round-robin traffic distribution
Interactive geography learning features