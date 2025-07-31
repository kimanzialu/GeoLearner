# GeoLearner - Interactive Geography Learning App

## Overview
GeoLearner is an interactive web application that teaches geography using the REST Countries API. It provides flashcards, quizzes, and daily challenges to help users learn about countries, capitals, and currencies.

## Core Functionality
- **Interactive Flashcards**: Learn countries, capitals, and currencies
- **Multiple Choice Quiz**: Test knowledge with randomized questions  
- **Daily Challenge**: Special country challenge that changes daily
- **Continent Filtering**: Focus learning on specific geographic regions
- **Real-time Statistics**: Track accuracy, streaks, and progress
- **Dark Mode Toggle**: Switch between light and dark themes
- **Responsive Design**: Works on desktop and mobile devices

## API Integration
- **External API**: REST Countries API (https://restcountries.com/v3.1/)
- **Endpoint**: `/all?fields=name,capital,currencies,flag,region,flags`
- **Data Usage**: Real-time country information including names, capitals, currencies, flags, and regions
- **Error Handling**: Graceful fallbacks for API failures

## Project Structure
```
geolearner/
├── public/
│   └── index.html          # Main application file
├── Dockerfile              # Container configuration
├── package.json            # Node.js dependencies
└── README.md              # Documentation
```

## Docker Setup

### Build Instructions
```bash
# Build the Docker image
docker build -t yourusername/geolearner:v1 .

# Test locally
docker run -p 8080:8080 yourusername/geolearner:v1

# Verify it works
curl http://localhost:8080
```

### Push to Docker Hub
```bash
# Login to Docker Hub
docker login

# Tag and push
docker tag yourusername/geolearner:v1 yourusername/geolearner:latest
docker push yourusername/geolearner:v1
docker push yourusername/geolearner:latest
```

## Lab Infrastructure Deployment

### Prerequisites
```bash
# Clone and start lab infrastructure
git clone https://github.com/waka-man/web_infra_lab.git
cd web_infra_lab
docker compose up -d --build

# Verify containers are running
docker compose ps
```

### Container Setup
- **web-01** (172.20.0.11): SSH port 2211, HTTP port 8080
- **web-02** (172.20.0.12): SSH port 2212, HTTP port 8081  
- **lb-01** (172.20.0.10): SSH port 2210, HTTP port 8082

### Deployment Steps

#### 1. Deploy Application on Web Servers

**On web-01:**
```bash
# SSH into web-01
ssh ubuntu@localhost -p 2211  # Password: pass123

# Create and start application
mkdir -p geolearner/public
cd geolearner/public
nano index.html  # Paste GeoLearner HTML content

# Start web server
sudo python3 -m http.server 80 &
```

**On web-02:** 
```bash
# SSH into web-02
ssh ubuntu@localhost -p 2212  # Password: pass123

# Same setup as web-01
mkdir -p geolearner/public
cd geolearner/public
nano index.html  # Paste same GeoLearner HTML content
sudo python3 -m http.server 80 &
```

#### 2. Configure Load Balancer

**On lb-01:**
```bash
# SSH into lb-01
ssh ubuntu@localhost -p 2210  # Password: pass123

# Install HAProxy
sudo apt update && sudo apt install -y haproxy

# Configure HAProxy
sudo nano /etc/haproxy/haproxy.cfg
```

**HAProxy Configuration:**
```
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
    server web01 172.20.0.11:80 check
    server web02 172.20.0.12:80 check
    http-response set-header X-Served-By %[srv_name]
```

**Start HAProxy:**
```bash
# Test configuration
sudo haproxy -f /etc/haproxy/haproxy.cfg -c

# Start HAProxy
sudo service haproxy restart
```

## Testing and Verification

### Individual Server Testing
```bash
# Test web-01
curl http://localhost:8080

# Test web-02
curl http://localhost:8081
```

### Load Balancer Testing
```bash
# Test load balancing with headers
curl -I http://localhost:8082
curl -I http://localhost:8082
curl -I http://localhost:8082

# Automated round-robin test
for i in {1..6}; do 
    echo "Request $i:"; 
    curl -I http://localhost:8082 | grep X-Served-By; 
    sleep 1; 
done
```

## Expected Results
- Applications accessible at localhost:8080 (web-01) and localhost:8081 (web-02)
- Load balancer accessible at localhost:8082
- Round-robin distribution with X-Served-By headers alternating between web01 and web02
- Full interactive geography learning functionality on all endpoints
- Proper handling of REST Countries API data integration

## Technical Implementation
- **Frontend**: Vanilla HTML/CSS/JavaScript
- **Containerization**: Docker with Node.js Alpine base image
- **Web Server**: Python HTTP server for simplicity
- **Load Balancing**: HAProxy with round-robin algorithm
- **Health Checks**: HAProxy monitors backend server availability
- **Headers**: Custom X-Served-By header for load balancer verification

Demo Video Link: https://www.veed.io/view/86f83d27-4d15-4541-8b64-549cd17a268b?panel=share