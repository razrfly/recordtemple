# SQL Query: Aggregate Most Valuable Records Based on Condition and Price Guide

## Problem Statement

We need to create a SQL query for Metabase that identifies the most valuable records for a specific user by intelligently combining:
1. Personal value from the `records` table (which is out of date)
2. Price guide values from the `prices` table (low and high values)
3. Record condition from the `records` table to determine which price to use

## Current Schema

### Records Table
- `value`: Personal/estimated value (out of date)
- `condition`: Integer indicating record condition
- `price_id`: Links to prices table
- `user_id`: Record owner

### Prices Table
- `price_low`: Minimum market value
- `price_high`: Maximum market value

## Requirements

1. **Condition-Based Price Selection**: We need to determine how the `condition` value maps to using either `price_low`, `price_high`, or some weighted average
2. **Value Aggregation**: Combine the outdated personal value with the condition-appropriate price guide value
3. **Sorting**: Return top 1000 most valuable records for a given user

## Questions to Research/Resolve

1. **Condition Mapping**: 
   - What are the possible condition values (1-10? 1-5?)
   - How should condition map to price selection?
     - Poor condition → price_low?
     - Excellent condition → price_high?
     - Mid conditions → weighted average?

2. **Aggregation Strategy**:
   - Should we completely ignore the personal value since it's out of date?
   - Or use a weighted combination of personal value and price guide?
   - How to handle records with no price guide data?

3. **Edge Cases**:
   - Records with NULL price_id
   - Records where only price_low OR price_high is set
   - Records with condition = NULL

## Proposed Approach

```sql
-- Pseudocode for condition-based pricing
CASE 
  WHEN condition <= 3 THEN price_low
  WHEN condition >= 8 THEN price_high
  WHEN condition BETWEEN 4 AND 7 THEN 
    price_low + ((price_high - price_low) * (condition - 3) / 4)
  ELSE (price_low + price_high) / 2
END as condition_adjusted_price
```

## Research Findings

### Common Vinyl Record Condition Scales

1. **Goldmine Standard (Most Common)**:
   - M (Mint) = 10
   - NM (Near Mint) = 9
   - VG+ (Very Good Plus) = 8
   - VG (Very Good) = 7
   - G+ (Good Plus) = 6
   - G (Good) = 5
   - F (Fair) = 4
   - P (Poor) = 3

2. **Price Impact by Condition**:
   - Mint/Near Mint (9-10): 90-100% of high price
   - VG+ (8): 75-85% of high price
   - VG (7): 50-70% of high price
   - G+ (6): 35-50% of high price
   - G (5): 25-35% of high price
   - Fair (4): 15-25% of high price
   - Poor (3 or less): 10-15% of high price

### Recommended SQL Implementation

```sql
WITH condition_pricing AS (
  SELECT 
    r.*,
    p.price_low,
    p.price_high,
    -- Calculate condition-adjusted price
    CASE 
      WHEN r.condition >= 9 THEN p.price_high * 0.95  -- Mint/Near Mint
      WHEN r.condition = 8 THEN p.price_high * 0.80   -- VG+
      WHEN r.condition = 7 THEN p.price_low + (p.price_high - p.price_low) * 0.60  -- VG
      WHEN r.condition = 6 THEN p.price_low + (p.price_high - p.price_low) * 0.40  -- G+
      WHEN r.condition = 5 THEN p.price_low + (p.price_high - p.price_low) * 0.30  -- G
      WHEN r.condition = 4 THEN p.price_low + (p.price_high - p.price_low) * 0.20  -- Fair
      WHEN r.condition <= 3 THEN p.price_low * 1.1    -- Poor (slightly above low)
      ELSE (p.price_low + p.price_high) / 2           -- Unknown condition
    END as market_value
  FROM records r
  LEFT JOIN prices p ON r.price_id = p.id
  WHERE r.user_id = 1
)
SELECT 
  *,
  -- Use market value if available, otherwise fall back to personal value
  COALESCE(market_value, value, 0) as estimated_value
FROM condition_pricing
WHERE COALESCE(market_value, value, 0) > 0
ORDER BY estimated_value DESC
LIMIT 1000;
```

## Next Steps

1. Confirm the condition scale used in the application
2. Validate the percentage mappings with domain experts
3. Consider adding condition descriptions to the UI
4. Test query performance and consider indexing strategies
5. Handle special cases (promos, test pressings, etc.)