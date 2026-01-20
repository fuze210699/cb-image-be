#!/bin/bash

# Docker Helper Script for CB Image Project

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Detect docker compose command (v2 uses 'docker compose' instead of 'docker-compose')
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
elif docker compose version &> /dev/null 2>&1; then
    DOCKER_COMPOSE="docker compose"
else
    echo -e "${RED}[ERROR]${NC} Docker Compose is not installed. Please install Docker Desktop or Docker Compose."
    exit 1
fi

# Function to print colored messages
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
    print_info "Docker is running ✓"
}

# Function to show usage
usage() {
    cat << EOF
Usage: ./docker.sh [COMMAND]

Commands:
    setup       - Build and start all services for the first time
    start       - Start all services
    stop        - Stop all services
    restart     - Restart all services
    down        - Stop and remove all containers
    logs        - Show logs for all services
    console     - Open Rails console
    bash        - Open bash in web container
    db-seed     - Run database seed
    db-reset    - Reset database and seed
    ps          - Show running containers
    rebuild     - Rebuild all containers
    clean       - Remove all containers, volumes, and images

Examples:
    ./docker.sh setup       # First time setup
    ./docker.sh start       # Start the application
    ./docker.sh console     # Open Rails console
    ./docker.sh logs        # View logs

EOF
}

# Main script logic
case "$1" in
    setup)
        print_info "Setting up CB Image project with Docker..."
        check_docker
        
        print_info "Building Docker images..."
        $DOCKER_COMPOSE build
        
        print_info "Starting services..."
        $DOCKER_COMPOSE up -d
        
        print_info "Waiting for MongoDB to be ready..."
        sleep 10
        
        print_info "Running database seed..."
        $DOCKER_COMPOSE exec web bundle exec rails db:seed_data
        
        print_info "Setup complete! ✓"
        print_info "Application is running at http://localhost:3000"
        print_info "MailCatcher is running at http://localhost:1080"
        print_info "MongoDB is running at localhost:27017"
        ;;

    start)
        print_info "Starting all services..."
        check_docker
        $DOCKER_COMPOSE up -d
        print_info "Services started ✓"
        print_info "Application: http://localhost:3000"
        print_info "MailCatcher: http://localhost:1080"
        ;;

    stop)
        print_info "Stopping all services..."
        $DOCKER_COMPOSE stop
        print_info "Services stopped ✓"
        ;;

    restart)
        print_info "Restarting all services..."
        $DOCKER_COMPOSE restart
        print_info "Services restarted ✓"
        ;;

    down)
        print_info "Stopping and removing containers..."
        $DOCKER_COMPOSE down
        print_info "Containers removed ✓"
        ;;

    logs)
        $DOCKER_COMPOSE logs -f
        ;;

    console)
        print_info "Opening Rails console..."
        $DOCKER_COMPOSE exec web bundle exec rails console
        ;;

    bash)
        print_info "Opening bash in web container..."
        $DOCKER_COMPOSE exec web bash
        ;;

    db-seed)
        print_info "Running database seed..."
        $DOCKER_COMPOSE exec web bundle exec rails db:seed_data
        print_info "Database seeded ✓"
        ;;

    db-reset)
        print_info "Resetting database..."
        $DOCKER_COMPOSE exec web bundle exec rails db:drop
        $DOCKER_COMPOSE exec web bundle exec rails db:seed_data
        print_info "Database reset complete ✓"
        ;;

    ps)
        $DOCKER_COMPOSE ps
        ;;

    rebuild)
        print_info "Rebuilding all containers..."
        $DOCKER_COMPOSE down
        $DOCKER_COMPOSE build --no-cache
        $DOCKER_COMPOSE up -d
        print_info "Rebuild complete ✓"
        ;;

    clean)
        print_warn "This will remove all containers, volumes, and images!"
        read -p "Are you sure? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "Cleaning up..."
            $DOCKER_COMPOSE down -v --rmi all
            print_info "Cleanup complete ✓"
        else
            print_info "Cancelled"
        fi
        ;;

    *)
        usage
        exit 1
        ;;
esac

exit 0
