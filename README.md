# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
# boodle_scraper



```

gem install bundler

source ~/.zprofile  
rbenv init 
rbenv install 3.1.0 
bundle
```

```
gem install rails
```


```
brew install postgresql@14 
brew services start postgresql@14 
psql --version  
```


# Create Alex user (seems to be default)
```
createuser -s alex     
```

Checkout databases
```
psql -U alex -h localhost -l  
```

# Create postgres user (special rpostgres role needed for restore)
```
createuser -s postgres 
```

# Restore DB
```
pg_restore -U alex -h localhost -d boodle_scraper_development /Volumes/Untitled/boodle1.dump
```

# Environment Variables

1. Install the dotenv-rails gem (if not already done):
   ```
   bundle install
   ```

2. Create a `.env` file in the root directory with the following variables:
   ```
   # SportRadar API Configuration
   # Get your API key from https://sportradar.com/
   SPORTRADAR_API_KEY=your_sportradar_api_key_here
   SPORTRADAR_ACCESS_LEVEL=trial
   SPORTRADAR_BASE_URL=https://api.sportradar.com/nfl/official

   # Database Configuration
   POSTGRES_USERNAME=alex
   POSTGRES_PASSWORD=
   BOODLE_SCRAPER_DATABASE_PASSWORD=

   # External Services
   SPORTSODDSHISTORY_BASE_URL=https://www.sportsoddshistory.com
   PFF_BASE_URL=https://www.pff.com

   # Redis Configuration (for production)
   REDIS_URL=redis://localhost:6379/1

   # Rails Configuration
   RAILS_ENV=development
   RAILS_MAX_THREADS=5
   ```

3. Add `.env` to your `.gitignore` file to keep your API keys secure

# Docker

Run the app with Docker (no Ruby, PostgreSQL, or other dependencies needed on the host).

### Prerequisites

- [Docker Engine](https://docs.docker.com/engine/install/) with the Compose plugin
  - **macOS**: `brew install --cask docker` (then open Docker Desktop)
  - **Linux (Ubuntu/Debian)**: `sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin`

### Setup

1. Create a `.env` file in the project root (see Environment Variables above)

2. Build and start:
   ```
   docker compose up --build -d
   ```

3. The app will be available at `http://localhost:3000`

The entrypoint automatically runs `db:prepare` on startup, which creates the database and runs migrations.

### Common Commands

```bash
docker compose up -d          # Start in background
docker compose down           # Stop services
docker compose logs -f web    # Follow web logs
docker compose run web bin/rails console   # Rails console
docker compose run web bin/rails db:seed   # Seed data
```