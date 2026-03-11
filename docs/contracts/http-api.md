# HTTP API

MVP API contract for the current `today-lunch` bootstrap.

## Conventions

- Base path: `/v1`
- Auth: none for MVP
- Content type: `application/json`

## Error format

```json
{
  "error": {
    "code": "INVALID_ARGUMENT",
    "message": "radius_meters must be between 100 and 3000"
  }
}
```

## `GET /health`

Returns basic process health.

### Response

```json
{
  "status": "ok",
  "version": "0.1.0"
}
```

## `GET /v1/places/nearby`

Returns nearby candidate places.

### Query parameters

- `lat`: required, `double`
- `lng`: required, `double`
- `radius_meters`: optional, default `700`
- `category`: optional, lowercase category slug
- `limit`: optional, default `20`, max `50`

### Response

```json
{
  "items": [
    {
      "id": "plc_123",
      "name": "Baekban House",
      "category": "korean",
      "latitude": 37.5665,
      "longitude": 126.9780,
      "distanceMeters": 230,
      "address": "Seoul ..."
    }
  ]
}
```

## `POST /v1/recommendations/pick`

Returns a single recommendation after applying filters and exclusions.

### Request

```json
{
  "criteria": {
    "latitude": 37.5665,
    "longitude": 126.9780,
    "radiusMeters": 700,
    "category": "korean"
  },
  "excludePlaceIds": ["plc_111", "plc_222"]
}
```

### Response

```json
{
  "recommendationId": "rec_20260311_001",
  "generatedAt": "2026-03-11T03:00:00Z",
  "place": {
    "id": "plc_333",
    "name": "Noodle Spot",
    "category": "korean",
    "latitude": 37.5663,
    "longitude": 126.9779,
    "distanceMeters": 190,
    "address": "Seoul ..."
  },
  "map": {
    "latitude": 37.5663,
    "longitude": 126.9779,
    "label": "Noodle Spot"
  }
}
```
