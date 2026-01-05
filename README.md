# Record Temple

A vinyl record collection catalog application built with Ruby on Rails. Browse and search through a curated collection of vinyl records with detailed artist, label, genre, and pricing information.

## Overview

Record Temple hosts a comprehensive database of vinyl records:

- **20,000+** records
- **64,000+** artists
- **21,000+** labels
- **20** genres
- High-resolution cover images and audio samples

## Tech Stack

| Category | Technology |
|----------|------------|
| Framework | Rails 8.1 |
| Ruby | 3.2.9 |
| Database | PostgreSQL with pg_trgm and unaccent extensions |
| Search | pg_search (tsvector + trigram fuzzy matching) |
| File Storage | Active Storage with AWS S3 |
| Image Processing | libvips via image_processing gem |
| Background Jobs | Sidekiq + Redis |
| CSS | Tailwind CSS 4 |
| JavaScript | Hotwire (Turbo + Stimulus), importmap |
| Authentication | Passwordless (magic link) |
| Deployment | Fly.io |

## Prerequisites

- Ruby 3.2.9 (via rbenv, asdf, or similar)
- PostgreSQL 14+
- Redis (for Sidekiq)
- libvips (for image processing)
- Node.js (for Tailwind CLI)

### macOS Setup

```bash
brew install postgresql@14 redis libvips node
brew services start postgresql@14
brew services start redis
```

## Getting Started

### 1. Clone and Install Dependencies

```bash
git clone git@github.com:razrfly/recordtemple.git
cd recordtemple
bundle install
```

### 2. Database Setup

```bash
bin/rails db:create
bin/rails db:migrate
```

For development with production data, obtain a database dump and restore:

```bash
pg_restore -d recordtemple_dev path/to/dump.sql
```

### 3. Credentials

Ensure you have the Rails master key for decrypting credentials:

```bash
# Place master.key in config/master.key
# Or set RAILS_MASTER_KEY environment variable
```

Required credentials (edit with `bin/rails credentials:edit`):

```yaml
aws:
  access_key_id: YOUR_KEY
  secret_access_key: YOUR_SECRET
```

### 4. Start the Server

```bash
bin/dev
```

This starts:
- Rails server on http://localhost:3000
- Tailwind CSS watcher

## Development

### File Storage Configuration

**Important**: Production images are stored in S3. By default, development uses S3 to display existing images.

```ruby
# config/environments/development.rb
config.active_storage.service = ENV.fetch("STORAGE_SERVICE", "amazon").to_sym
```

| Scenario | Command |
|----------|---------|
| Normal development (view S3 images) | `bin/dev` |
| Testing local uploads | `STORAGE_SERVICE=local bin/dev` |

When using `STORAGE_SERVICE=local`, uploaded files go to `storage/` directory instead of S3.

### Development Login

In development, bypass passwordless auth:

```
http://localhost:3000/dev_login?email=your@email.com
```

### Search

Records use PostgreSQL full-text search with weighted ranking:

| Weight | Fields |
|--------|--------|
| A (highest) | Artist name |
| B | Label name |
| C | Genre, format, comments |
| D | Price details, years |

Search also supports trigram fuzzy matching for typo tolerance.

```ruby
# Example search
Record.wide_search("beatles")
```

### Background Jobs

Sidekiq processes background jobs (popularity scoring, etc.):

```bash
bundle exec sidekiq
```

Access Sidekiq dashboard (admin only): http://localhost:3000/admin/sidekiq

## Testing

```bash
bin/rails test
bin/rails test:system
```

## Deployment

Deployed on [Fly.io](https://fly.io) with:

- **Region**: Dallas (dfw)
- **Processes**: web (Rails), worker (Sidekiq)
- **Database**: Fly Postgres
- **Storage**: AWS S3 (cdn4.recordtemple.com)

### Deploy

```bash
fly deploy
```

### Useful Commands

```bash
fly logs                    # View logs
fly ssh console             # SSH into app
fly postgres connect        # Connect to database
fly secrets list            # View secrets
```

## Project Structure

```
app/
├── controllers/
│   ├── records_controller.rb   # Main catalog browsing
│   ├── artists_controller.rb   # Artist discovery
│   ├── labels_controller.rb    # Label discovery
│   └── genres_controller.rb    # Genre discovery
├── models/
│   ├── record.rb              # Core model with search
│   ├── artist.rb              # Artist with records
│   ├── label.rb               # Record label
│   ├── genre.rb               # Music genre
│   └── user.rb                # User accounts
├── views/
│   ├── records/               # Record catalog views
│   └── shared/                # Reusable components
└── helpers/
    └── component_helper.rb    # UI component helpers
```

## Key Features

- **Full-text Search**: Fast PostgreSQL-based search with fuzzy matching
- **Image Galleries**: Multiple high-res images per record with variants
- **Audio Samples**: Streamable MP3 samples via signed S3 URLs
- **Responsive Design**: Mobile-first Tailwind CSS design
- **Discovery**: Browse by artist, label, or genre with random discovery
- **Condition Grading**: Mint to Poor condition ratings
- **Price History**: Historical pricing data with year ranges

## License

Private repository. All rights reserved.
