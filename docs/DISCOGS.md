# Discogs Integration

Record Temple automatically matches records to Discogs releases for price validation and metadata enrichment.

## Overview

The integration provides:
- **Automatic Matching**: Records are matched to Discogs releases using a cascading search strategy
- **Price Validation**: Guide prices are compared against Discogs median prices
- **Confidence Scoring**: Matches are scored based on multiple factors (title, label, catalog number, year)
- **Manual Review Queue**: Uncertain high-value matches can be reviewed by admins

## Matching System

### Confidence Thresholds

Thresholds vary by record value to prioritize accuracy for expensive items:

| Value Tier | Auto-High | Auto-Low | Minimum |
|------------|-----------|----------|---------|
| High ($100+) | 92% | 80% | 70% |
| Medium ($25-99) | 85% | 65% | 55% |
| Standard (<$25) | 85% | 60% | 50% |

### Matching Methods

Matches are attempted in order of specificity:

1. **Track matching**: Compare tracklist when available
2. **Catalog number**: Direct catno match
3. **Label + Year**: Label name and release year
4. **Label only**: Just label name
5. **Artist only**: Fallback to artist search

### Validation Statuses

After matching, records receive a validation status:

| Status | Description |
|--------|-------------|
| `verified` | High confidence, prices align well |
| `probable` | Good confidence, minor price variance |
| `uncertain` | Lower confidence, needs review |
| `likely_wrong` | Match appears incorrect |
| `guide_undervalued` | Discogs price significantly higher |
| `no_price` | No Discogs pricing available |

## Rake Tasks

### Monitoring

```bash
# View overall matching statistics
bin/rails discogs:stats

# Breakdown by validation status
bin/rails discogs:validation_status

# Compare guide vs Discogs prices
bin/rails discogs:compare_prices

# View sample matches by validation status
bin/rails discogs:sample
```

### Matching

```bash
# Match unmatched records (default: 500, rate limited)
bin/rails discogs:match

# Match specific number of records
bin/rails discogs:match LIMIT=1000

# Enqueue matching as background job
bin/rails discogs:enqueue
```

### Maintenance

```bash
# Preview clearing likely_wrong matches
bin/rails discogs:clear_wrong DRY_RUN=true

# Clear likely_wrong matches for high-value records
bin/rails discogs:clear_wrong CONFIRM=yes MIN_VALUE=100

# Recalculate validation status for all matches
bin/rails discogs:populate_validation

# Reset all Discogs matches (DESTRUCTIVE)
bin/rails discogs:reset CONFIRM=yes
```

## Re-Matching Workflow

When matches need to be refreshed (e.g., after algorithm improvements):

```bash
# 1. Check current state
bin/rails discogs:stats
bin/rails discogs:validation_status

# 2. Preview and clear bad matches
bin/rails discogs:clear_wrong DRY_RUN=true MIN_VALUE=100
bin/rails discogs:clear_wrong CONFIRM=yes MIN_VALUE=100

# 3. Re-run matching
bin/rails discogs:match

# 4. Recalculate validation
bin/rails discogs:populate_validation

# 5. Verify results
bin/rails discogs:validation_status
```

## Admin Review Queue

Access the manual review queue at `/admin/discogs_review`.

### Features

- **Value-based tabs**: High Value ($100+), Medium Value ($25-99), Skipped
- **Discogs search**: Search Discogs directly from the review interface
- **Manual linking**: Link records to specific Discogs releases by ID
- **Skip tracking**: Skip records with reason (no match, not on Discogs, compilation, other)

### Manual Link Process

1. Navigate to `/admin/discogs_review`
2. Select a record from the queue
3. Use the search to find the correct Discogs release
4. Click "Link" or enter a Discogs ID directly
5. Manual links are saved with 100% confidence

## API Rate Limiting

The Discogs API has rate limits. The matching service:
- Pauses 1 second between API calls
- Stops after 3 consecutive failures
- Uses authenticated requests for higher limits

Configure Discogs credentials in Rails credentials:

```yaml
discogs:
  consumer_key: YOUR_KEY
  consumer_secret: YOUR_SECRET
```

## Database Schema

### discogs_releases table

| Column | Type | Description |
|--------|------|-------------|
| `discogs_id` | integer | Discogs release ID |
| `title` | string | Release title |
| `artist_name` | string | Artist name |
| `label_name` | string | Label name |
| `catno` | string | Catalog number |
| `year` | integer | Release year |
| `lowest_price` | decimal | Discogs lowest price |
| `median_price` | decimal | Discogs median price |
| `highest_price` | decimal | Discogs highest price |

### records table (Discogs fields)

| Column | Type | Description |
|--------|------|-------------|
| `discogs_release_id` | integer | FK to discogs_releases |
| `discogs_match_confidence` | decimal | Match confidence (0-100) |
| `discogs_match_method` | string | How match was found |
| `discogs_price_validation` | string | Validation status |
| `discogs_matched_at` | datetime | When matched |

## Services

### DiscogsApiClient

Low-level API client for Discogs. Handles authentication and rate limiting.

```ruby
client = DiscogsApiClient.new
results = client.search_releases("Artist Name", "Album Title")
release = client.get_release(12345)
```

### DiscogsMatchingService

High-level matching logic. Finds best Discogs match for a record.

```ruby
service = DiscogsMatchingService.new
service.match_record(record)
service.match_unmatched_records(limit: 500)
```
