#!/bin/bash
set -e

wait_for_postgres() {
    echo "Waiting for PostgreSQL to be ready..."
    until PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -c "SELECT 1" > /dev/null 2>&1; do
        echo "PostgreSQL is unavailable - sleeping"
        sleep 2
    done
    echo "PostgreSQL is ready!"
}

create_database() {
    echo "Checking if database ${DB_NAME} exists..."
    if ! PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -lqt | cut -d \| -f 1 | grep -qw "${DB_NAME}"; then
        echo "Creating database ${DB_NAME}..."
        PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -c "CREATE DATABASE \"${DB_NAME}\";"
        echo "Database ${DB_NAME} created."
    else
        echo "Database ${DB_NAME} already exists."
    fi
}

initialize_tryton() {
    echo "Initializing Tryton database..."
    if [ ! -f /app/db/.initialized ]; then
        # Create password file for admin user
        # TRYTONPASSFILE (no underscore) is the correct environment variable
        echo "${ADMIN_PASSWORD:-admin}" > /tmp/admin_password
        
        # Initialize database with admin password
        # -p flag prompts for password, TRYTONPASSFILE provides it
        TRYTONPASSFILE=/tmp/admin_password trytond-admin -c /app/trytond.conf -d "${DB_NAME}" --all -p -v
        
        # Clean up password file
        rm -f /tmp/admin_password
        
        touch /app/db/.initialized
        echo "Tryton database initialized."
        echo "Admin password set to: ${ADMIN_PASSWORD:-admin}"
    else
        echo "Tryton database already initialized."
    fi
}

start_server() {
    echo "Starting Tryton server on port 8001..."
    exec trytond -c /app/trytond.conf
}

export DB_HOST="${DB_HOST:-postgres-dev}"
export DB_PORT="${DB_PORT:-5432}"
export DB_NAME="${DB_NAME:-tryton_mirror}"
export DB_USER="${DB_USER:-postgres}"
export DB_PASSWORD="${DB_PASSWORD:-postgres_grist}"
export ADMIN_PASSWORD="${ADMIN_PASSWORD:-admin}"

mkdir -p /app/db /app/www

wait_for_postgres
create_database
initialize_tryton
start_server
