#!/bin/bash

# Configuration
CONNECT_URL="http://localhost:8083"
CONNECTOR_CONFIG_FILE="sink-connector-config.json"
CONNECTOR_NAME="jdbc-postgres-sink"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if config file exists
if [ ! -f "$CONNECTOR_CONFIG_FILE" ]; then
    print_error "Connector config file not found: $CONNECTOR_CONFIG_FILE"
    exit 1
fi

# Wait for Kafka Connect to be ready
print_status "Waiting for Kafka Connect to be ready at $CONNECT_URL..."
MAX_RETRIES=30
RETRY_COUNT=0

until curl -s "$CONNECT_URL/connectors" > /dev/null; do
    RETRY_COUNT=$((RETRY_COUNT+1))
    if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
        print_error "Kafka Connect not available after $MAX_RETRIES attempts"
        exit 1
    fi
    print_status "Waiting for Kafka Connect... (attempt $RETRY_COUNT/$MAX_RETRIES)"
    sleep 2
done

print_status "✅ Kafka Connect is ready!"

# Check if connector already exists
print_status "Checking if connector '$CONNECTOR_NAME' already exists..."
HTTP_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$CONNECT_URL/connectors/$CONNECTOR_NAME")

if [ "$HTTP_RESPONSE" = "200" ]; then
    print_warning "Connector '$CONNECTOR_NAME' already exists."
    read -p "Do you want to delete it and recreate? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Deleting existing connector..."
        curl -X DELETE "$CONNECT_URL/connectors/$CONNECTOR_NAME"
        sleep 2
    else
        print_status "Keeping existing connector. Exiting."
        exit 0
    fi
fi

# Register the connector
print_status "Registering JDBC Sink Connector from $CONNECTOR_CONFIG_FILE..."

# Register using the config file
RESPONSE=$(curl -s -X POST "$CONNECT_URL/connectors" \
  -H "Content-Type: application/json" \
  -d @"$CONNECTOR_CONFIG_FILE")

# Check if registration was successful
if echo "$RESPONSE" | grep -q "error_code"; then
    print_error "Failed to register connector:"
    echo "$RESPONSE" | jq '.'
    exit 1
else
    print_status "✅ Connector registered successfully!"
    echo "$RESPONSE" | jq '.'
fi

echo ""
print_status "Checking connector status..."
sleep 2

STATUS_RESPONSE=$(curl -s "$CONNECT_URL/connectors/$CONNECTOR_NAME/status")
if command -v jq &> /dev/null; then
    echo "$STATUS_RESPONSE" | jq '.'
else
    echo "$STATUS_RESPONSE"
fi

# Check if connector is running
if echo "$STATUS_RESPONSE" | grep -q '"state":"RUNNING"'; then
    print_status "✅ Connector is running successfully!"
else
    print_warning "Connector may not be running properly. Check logs for details."
fi

echo ""
print_status "To view connector logs, run: docker logs kafka-connect --tail 50"
print_status "To delete connector, run: curl -X DELETE $CONNECT_URL/connectors/$CONNECTOR_NAME"
