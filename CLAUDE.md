# lex-cognitive-magnet

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`

## Purpose

Magnetic field metaphor for cognitive attraction and repulsion. Poles represent cognitive elements with a polarity (positive, negative, neutral, bipolar) and a material type. When poles interact, attraction strengthens both; repulsion weakens both. Fields group poles and compute alignment scores via pair-wise interaction analysis. Models how ideas, beliefs, or preferences cluster and conflict in cognitive space.

## Gem Info

- **Gem name**: `lex-cognitive-magnet`
- **Module**: `Legion::Extensions::CognitiveMagnet`
- **Version**: `0.1.0`
- **Ruby**: `>= 3.4`
- **License**: MIT

## File Structure

```
lib/legion/extensions/cognitive_magnet/
  version.rb
  client.rb
  helpers/
    constants.rb
    pole.rb
    field.rb
    magnet_engine.rb
  runners/
    cognitive_magnet.rb
```

## Key Constants

| Constant | Value | Purpose |
|---|---|---|
| `POLARITY_TYPES` | `%i[positive negative neutral bipolar]` | Valid pole polarity values |
| `MATERIAL_TYPES` | `%i[iron cobalt nickel lodestone ferrite]` | Valid material types |
| `MAX_POLES` | `500` | Per-engine pole capacity |
| `MAX_FIELDS` | `50` | Per-engine field capacity |
| `ATTRACTION_RATE` | `0.08` | Base strength increase per attraction interaction |
| `REPULSION_RATE` | `0.06` | Base strength decrease per repulsion interaction |
| `DECAY_RATE` | `0.02` | Default strength reduction per demagnetize cycle |
| `STRENGTH_LABELS` | range hash | From `:negligible` to `:overwhelming` |
| `ALIGNMENT_LABELS` | range hash | From `:chaotic` to `:perfect` |

## Helpers

### `Helpers::Pole`
Individual magnetic pole. Has `id`, `polarity`, `strength` (0.0–1.0), `material_type`, `domain`, `content`, and `created_at`.

- `magnetize!(rate)` — increases strength by rate
- `demagnetize!(rate)` — decreases strength by rate
- `attracts?(other_pole)` — true if polarities are opposite; always true for `:bipolar`, always false for `:neutral`
- `repels?(other_pole)` — true if polarities match; always false for `:neutral` or `:bipolar`
- `saturated?` — strength >= 1.0
- `weak?` — strength <= 0.1
- `strength_label`
- `to_h`

### `Helpers::Field`
Named container for poles. Has `id`, `name`, `pole_ids`, `alignment`, and `flux_density`.

- `add_pole(pole_id)` — adds pole ID (idempotent)
- `remove_pole(pole_id)` — removes pole ID
- `calculate_alignment!(poles)` — pair-wise computation: attraction pairs add `(a.strength + b.strength) / 2.0`, repulsion pairs subtract half that weight; result normalized to [0.0, 1.0]
- `coherent?` — alignment >= 0.6
- `chaotic?` — alignment < 0.2
- `alignment_label`
- `pole_count`
- `to_h`

### `Helpers::MagnetEngine`
Top-level store. Enforces `MAX_POLES` and `MAX_FIELDS`.

- `create_pole(polarity:, content:, strength:, material_type:, domain:)` → pole or capacity error
- `create_field(name:)` → field or capacity error
- `magnetize(pole_id, rate:)` → strength hash
- `interact(pole_a_id, pole_b_id)` — mutual magnetize/demagnetize based on attraction/repulsion; logs interaction event
- `demagnetize_all!(rate:)` → count hash
- `most_aligned_fields(limit:)` → top N fields by alignment (recalculates before sort)
- `strongest_poles(limit:)` → top N poles by strength (excludes weak poles)
- `field_report` → aggregate stats including coherent/chaotic field counts
- `add_pole_to_field(field_id:, pole_id:)` → status hash
- `remove_pole_from_field(field_id:, pole_id:)` → status hash

## Runners

Module: `Runners::CognitiveMagnet`

| Runner Method | Description |
|---|---|
| `create_pole(polarity:, content:, strength:, material_type:, domain:)` | Register a new pole |
| `create_field(name:)` | Create a field |
| `magnetize(pole_id:, rate:)` | Strengthen a pole |
| `interact(pole_a_id:, pole_b_id:)` | Trigger mutual interaction |
| `list_poles(limit:)` | Strongest poles |
| `magnetic_status` | Full field report |

All runners return `{success: true/false, ...}` hashes.

## Integration Points

- No direct dependencies on other agentic LEX gems
- Fields with high coherence represent stable belief clusters; can feed `lex-emotion` valence
- Repulsion events between poles can register as `lex-conflict` conflicts
- `interact` drives organic reinforcement and weakening as ideas encounter each other in `lex-tick` cycles
- Chaotic fields (low alignment) can trigger `lex-prediction` uncertainty signals

## Development Notes

- `Client` instantiates `@magnet_engine = Helpers::MagnetEngine.new`
- `attract?` / `repels?` are asymmetric: `:bipolar` always attracts any polarity, `:neutral` never attracts or repels
- `interact` logs to `@interaction_log` (unbounded array — callers should periodically prune for long-running sessions)
- `most_aligned_fields` calls `recalculate_all_fields` before sorting — this is O(fields * poles^2/2) pairs
- Alignment formula maps raw weighted average to [0.0, 1.0] via `(raw + 1.0) / 2.0`
