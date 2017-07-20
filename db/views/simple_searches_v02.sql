SELECT artists.id AS searchable_id, artists.name AS term,
  'Artist' AS searchable_type
FROM artists
INNER JOIN records ON records.artist_id = artists.id

UNION
SELECT labels.id AS searchable_id, labels.name AS term,
  'Label' AS searchable_type
FROM labels
INNER JOIN records ON records.label_id = labels.id

UNION
SELECT genres.id AS searchable_id, genres.name AS term,
  'Genre' AS searchable_type
FROM genres
INNER JOIN records ON records.genre_id = genres.id

UNION
SELECT records.id AS searchable_id,
  array_to_string(ARRAY[prices.detail, records.comment], ' ') AS term,
  'Record' AS searchable_type
FROM records
LEFT OUTER JOIN prices ON records.price_id = prices.id

UNION
SELECT songs.id AS searchable_id, songs.title AS term,
  'Song' AS searchable_type
FROM songs
INNER JOIN records ON songs.record_id = records.id
