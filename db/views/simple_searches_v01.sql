SELECT artists.id AS searchable_id, artists.name AS term,
  'Artist' AS searchable_type
FROM artists

UNION
SELECT labels.id AS searchable_id, labels.name AS term,
  'Label' AS searchable_type
FROM labels

UNION
SELECT record_formats.id AS searchable_id, record_formats.name AS term,
  'RecordFormat' AS searchable_type
FROM record_formats

UNION
SELECT genres.id AS searchable_id, genres.name AS term,
  'Genre' AS searchable_type
FROM genres

UNION
SELECT records.id AS searchable_id, records.comment AS term,
  'Record' AS searchable_type
FROM records
