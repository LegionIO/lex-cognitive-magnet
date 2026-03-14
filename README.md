# lex-cognitive-magnet

Magnetic field metaphor for cognitive attraction and repulsion in LegionIO agents. Poles represent ideas or beliefs with polarities; interacting poles strengthen or weaken each other; fields group poles and measure their collective alignment.

## What It Does

- Four polarity types: `positive`, `negative`, `neutral`, `bipolar`
- Five material types: `iron`, `cobalt`, `nickel`, `lodestone`, `ferrite`
- Attraction: opposite polarities strengthen each other on interaction
- Repulsion: matching polarities weaken each other on interaction
- `bipolar` attracts everything; `neutral` never attracts or repels
- Fields group poles and compute alignment via pair-wise strength-weighted analysis
- Coherent fields (alignment >= 0.6) and chaotic fields (< 0.2) are classified
- `demagnetize_all` provides a global decay cycle

## Usage

```ruby
# Create poles
a = runner.create_pole(polarity: :positive, content: 'hypothesis_A',
                        strength: 0.6, material_type: :iron, domain: :reasoning)
b = runner.create_pole(polarity: :negative, content: 'counter_hypothesis',
                        strength: 0.5, material_type: :iron, domain: :reasoning)

# Interact — opposite polarities attract, both strengthen
runner.interact(pole_a_id: a[:pole][:id], pole_b_id: b[:pole][:id])
# => { type: :attraction, force: 0.3, ... }

# Create a field and add poles
field = runner.create_field(name: 'reasoning_cluster')
# (add poles to field via engine directly or via future runner method)

# Status
runner.magnetic_status
# => { success: true, total_poles: 2, coherent_fields: 0, chaotic_fields: 0, ... }

# Strongest poles
runner.list_poles(limit: 5)
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
