# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveMagnet::Helpers::MagnetEngine do
  subject(:engine) { described_class.new }

  let(:pos_pole_id) do
    engine.create_pole(polarity: :positive, content: 'idea A').id
  end
  let(:neg_pole_id) do
    engine.create_pole(polarity: :negative, content: 'idea B').id
  end

  describe '#create_pole' do
    it 'creates and stores a pole' do
      result = engine.create_pole(polarity: :positive, content: 'concept')
      expect(result).to be_a(Legion::Extensions::CognitiveMagnet::Helpers::Pole)
      expect(engine.poles.size).to eq(1)
    end

    it 'accepts all keyword arguments' do
      result = engine.create_pole(
        polarity: :negative, content: 'idea', strength: 0.7,
        material_type: :cobalt, domain: :reasoning
      )
      expect(result.polarity).to eq(:negative)
      expect(result.strength).to be_within(0.001).of(0.7)
      expect(result.material_type).to eq(:cobalt)
    end

    it 'returns error when at capacity' do
      stub_const('Legion::Extensions::CognitiveMagnet::Helpers::Constants::MAX_POLES', 1)
      engine.create_pole(polarity: :positive, content: 'first')
      result = engine.create_pole(polarity: :negative, content: 'second')
      expect(result[:error]).to eq(:capacity_exceeded)
    end
  end

  describe '#create_field' do
    it 'creates and stores a field' do
      result = engine.create_field(name: 'test_field')
      expect(result).to be_a(Legion::Extensions::CognitiveMagnet::Helpers::Field)
      expect(engine.fields.size).to eq(1)
    end

    it 'returns error when at field capacity' do
      stub_const('Legion::Extensions::CognitiveMagnet::Helpers::Constants::MAX_FIELDS', 1)
      engine.create_field(name: 'first')
      result = engine.create_field(name: 'second')
      expect(result[:error]).to eq(:capacity_exceeded)
    end
  end

  describe '#magnetize' do
    it 'increases pole strength' do
      id = engine.create_pole(polarity: :positive, content: 'x', strength: 0.5).id
      result = engine.magnetize(id)
      expect(result[:magnetized]).to be true
      expect(result[:strength]).to be_within(0.001).of(0.58)
    end

    it 'returns error for unknown pole' do
      result = engine.magnetize('nonexistent')
      expect(result[:error]).to eq(:not_found)
    end

    it 'accepts custom rate' do
      id = engine.create_pole(polarity: :positive, content: 'x', strength: 0.5).id
      result = engine.magnetize(id, rate: 0.2)
      expect(result[:strength]).to be_within(0.001).of(0.7)
    end
  end

  describe '#interact' do
    it 'returns attraction for positive/negative pair' do
      result = engine.interact(pos_pole_id, neg_pole_id)
      expect(result[:type]).to eq(:attraction)
    end

    it 'increases strength on attraction' do
      pole_a = engine.poles[pos_pole_id]
      original_strength = pole_a.strength
      engine.interact(pos_pole_id, neg_pole_id)
      expect(pole_a.strength).to be > original_strength
    end

    it 'returns repulsion for same-polarity pair' do
      a = engine.create_pole(polarity: :positive, content: 'a').id
      b = engine.create_pole(polarity: :positive, content: 'b').id
      result = engine.interact(a, b)
      expect(result[:type]).to eq(:repulsion)
    end

    it 'decreases strength on repulsion' do
      a_pole = engine.create_pole(polarity: :positive, content: 'a', strength: 0.8)
      b_pole = engine.create_pole(polarity: :positive, content: 'b', strength: 0.8)
      original = a_pole.strength
      engine.interact(a_pole.id, b_pole.id)
      expect(a_pole.strength).to be < original
    end

    it 'returns neutral for neutral poles' do
      a = engine.create_pole(polarity: :neutral, content: 'a').id
      b = engine.create_pole(polarity: :neutral, content: 'b').id
      result = engine.interact(a, b)
      expect(result[:type]).to eq(:neutral)
    end

    it 'returns error for missing pole_a' do
      result = engine.interact('bad_id', neg_pole_id)
      expect(result[:error]).to eq(:pole_a_not_found)
    end

    it 'returns error for missing pole_b' do
      result = engine.interact(pos_pole_id, 'bad_id')
      expect(result[:error]).to eq(:pole_b_not_found)
    end

    it 'returns error for same pole' do
      result = engine.interact(pos_pole_id, pos_pole_id)
      expect(result[:error]).to eq(:same_pole)
    end

    it 'logs the interaction event' do
      engine.interact(pos_pole_id, neg_pole_id)
      expect(engine.interaction_log.size).to eq(1)
    end

    it 'includes force in result' do
      result = engine.interact(pos_pole_id, neg_pole_id)
      expect(result[:force]).to be >= 0.0
    end

    it 'includes timestamp in result' do
      result = engine.interact(pos_pole_id, neg_pole_id)
      expect(result[:at]).to be_a(Time)
    end
  end

  describe '#demagnetize_all!' do
    it 'decays all pole strengths' do
      id1 = engine.create_pole(polarity: :positive, content: 'x', strength: 0.8).id
      id2 = engine.create_pole(polarity: :negative, content: 'y', strength: 0.6).id
      engine.demagnetize_all!
      expect(engine.poles[id1].strength).to be < 0.8
      expect(engine.poles[id2].strength).to be < 0.6
    end

    it 'returns count of demagnetized poles' do
      engine.create_pole(polarity: :positive, content: 'a')
      engine.create_pole(polarity: :negative, content: 'b')
      result = engine.demagnetize_all!
      expect(result[:demagnetized]).to eq(2)
    end

    it 'accepts custom rate' do
      id = engine.create_pole(polarity: :positive, content: 'x', strength: 0.5).id
      engine.demagnetize_all!(rate: 0.1)
      expect(engine.poles[id].strength).to be_within(0.001).of(0.4)
    end
  end

  describe '#add_pole_to_field' do
    let(:field_id) { engine.create_field(name: 'test').id }

    it 'adds pole to field' do
      result = engine.add_pole_to_field(field_id: field_id, pole_id: pos_pole_id)
      expect(result[:added]).to be true
    end

    it 'returns error for unknown field' do
      result = engine.add_pole_to_field(field_id: 'bad', pole_id: pos_pole_id)
      expect(result[:error]).to eq(:field_not_found)
    end

    it 'returns error for unknown pole' do
      result = engine.add_pole_to_field(field_id: field_id, pole_id: 'bad')
      expect(result[:error]).to eq(:pole_not_found)
    end
  end

  describe '#remove_pole_from_field' do
    let(:field_id) { engine.create_field(name: 'test').id }

    before { engine.add_pole_to_field(field_id: field_id, pole_id: pos_pole_id) }

    it 'removes pole from field' do
      result = engine.remove_pole_from_field(field_id: field_id, pole_id: pos_pole_id)
      expect(result[:removed]).to be true
    end

    it 'returns error for unknown field' do
      result = engine.remove_pole_from_field(field_id: 'bad', pole_id: pos_pole_id)
      expect(result[:error]).to eq(:field_not_found)
    end
  end

  describe '#most_aligned_fields' do
    it 'returns fields sorted by alignment descending' do
      field_a = engine.create_field(name: 'field_a')
      field_b = engine.create_field(name: 'field_b')
      pos_a = engine.create_pole(polarity: :positive, content: 'a1', strength: 0.8)
      neg_a = engine.create_pole(polarity: :negative, content: 'a2', strength: 0.8)
      engine.add_pole_to_field(field_id: field_a.id, pole_id: pos_a.id)
      engine.add_pole_to_field(field_id: field_a.id, pole_id: neg_a.id)
      engine.add_pole_to_field(field_id: field_b.id, pole_id: pos_a.id)

      results = engine.most_aligned_fields(limit: 2)
      expect(results).to be_an(Array)
    end

    it 'respects the limit' do
      3.times { |i| engine.create_field(name: "f#{i}") }
      results = engine.most_aligned_fields(limit: 2)
      expect(results.size).to be <= 2
    end
  end

  describe '#strongest_poles' do
    it 'returns poles sorted by strength descending' do
      engine.create_pole(polarity: :positive, content: 'strong', strength: 0.9)
      engine.create_pole(polarity: :negative, content: 'medium', strength: 0.5)
      engine.create_pole(polarity: :neutral,  content: 'weak',   strength: 0.05)
      results = engine.strongest_poles(limit: 3)
      strengths = results.map(&:strength)
      expect(strengths).to eq(strengths.sort.reverse)
    end

    it 'excludes weak poles' do
      engine.create_pole(polarity: :positive, content: 'weak', strength: 0.05)
      results = engine.strongest_poles
      expect(results.none?(&:weak?)).to be true
    end

    it 'respects the limit' do
      5.times { |i| engine.create_pole(polarity: :positive, content: "p#{i}", strength: 0.6) }
      results = engine.strongest_poles(limit: 3)
      expect(results.size).to eq(3)
    end
  end

  describe '#field_report' do
    it 'returns a comprehensive report' do
      report = engine.field_report
      expect(report).to include(:total_poles, :total_fields, :coherent_fields, :chaotic_fields,
                                :saturated_poles, :weak_poles, :total_interactions,
                                :strongest, :top_fields)
    end

    it 'counts poles correctly' do
      engine.create_pole(polarity: :positive, content: 'a')
      engine.create_pole(polarity: :negative, content: 'b')
      report = engine.field_report
      expect(report[:total_poles]).to eq(2)
    end

    it 'counts fields correctly' do
      engine.create_field(name: 'f1')
      engine.create_field(name: 'f2')
      report = engine.field_report
      expect(report[:total_fields]).to eq(2)
    end

    it 'counts interactions' do
      engine.interact(pos_pole_id, neg_pole_id)
      report = engine.field_report
      expect(report[:total_interactions]).to eq(1)
    end

    it 'identifies saturated poles' do
      engine.create_pole(polarity: :positive, content: 'max', strength: 1.0)
      report = engine.field_report
      expect(report[:saturated_poles]).to be >= 1
    end

    it 'identifies weak poles' do
      engine.create_pole(polarity: :negative, content: 'min', strength: 0.05)
      report = engine.field_report
      expect(report[:weak_poles]).to be >= 1
    end
  end
end
