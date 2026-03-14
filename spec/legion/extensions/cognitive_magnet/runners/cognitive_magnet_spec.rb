# frozen_string_literal: true

require 'legion/extensions/cognitive_magnet/client'

RSpec.describe Legion::Extensions::CognitiveMagnet::Runners::CognitiveMagnet do
  let(:client) { Legion::Extensions::CognitiveMagnet::Client.new }
  let(:engine) { Legion::Extensions::CognitiveMagnet::Helpers::MagnetEngine.new }

  describe '#create_pole' do
    it 'creates a pole with valid polarity and material' do
      result = client.create_pole(polarity: :positive, content: 'new idea')
      expect(result[:success]).to be true
      expect(result[:pole][:polarity]).to eq(:positive)
    end

    it 'returns error for invalid polarity' do
      result = client.create_pole(polarity: :zap, content: 'x')
      expect(result[:success]).to be false
      expect(result[:error]).to eq(:invalid_polarity)
    end

    it 'includes valid_polarities in error response' do
      result = client.create_pole(polarity: :zap, content: 'x')
      expect(result[:valid_polarities]).to eq(Legion::Extensions::CognitiveMagnet::Helpers::Constants::POLARITY_TYPES)
    end

    it 'returns error for invalid material' do
      result = client.create_pole(polarity: :positive, content: 'x', material_type: :plastic)
      expect(result[:success]).to be false
      expect(result[:error]).to eq(:invalid_material)
    end

    it 'accepts injected engine' do
      result = client.create_pole(polarity: :positive, content: 'injected', engine: engine)
      expect(result[:success]).to be true
      expect(engine.poles.size).to eq(1)
    end

    it 'accepts all polarity types' do
      %i[positive negative neutral bipolar].each do |pol|
        result = client.create_pole(polarity: pol, content: 'test', engine: engine)
        expect(result[:success]).to be true
      end
    end

    it 'includes pole hash with expected keys' do
      result = client.create_pole(polarity: :negative, content: 'shadow')
      expect(result[:pole]).to include(:id, :polarity, :strength, :material_type, :domain, :content)
    end

    it 'ignores extra keyword arguments' do
      result = client.create_pole(polarity: :positive, content: 'test', extra_key: 'ignored')
      expect(result[:success]).to be true
    end
  end

  describe '#create_field' do
    it 'creates a field with a name' do
      result = client.create_field(name: 'reasoning_cluster')
      expect(result[:success]).to be true
      expect(result[:field][:name]).to eq('reasoning_cluster')
    end

    it 'accepts injected engine' do
      result = client.create_field(name: 'test_field', engine: engine)
      expect(result[:success]).to be true
      expect(engine.fields.size).to eq(1)
    end

    it 'returns field hash with expected keys' do
      result = client.create_field(name: 'my_field')
      expect(result[:field]).to include(:id, :name, :pole_ids, :alignment, :flux_density)
    end
  end

  describe '#magnetize' do
    let(:pole_id) do
      client.create_pole(polarity: :positive, content: 'energize')[:pole][:id]
    end

    it 'magnetizes an existing pole' do
      result = client.magnetize(pole_id: pole_id)
      expect(result[:success]).to be true
      expect(result[:magnetized]).to be true
    end

    it 'returns error for unknown pole' do
      result = client.magnetize(pole_id: 'nonexistent')
      expect(result[:success]).to be false
      expect(result[:error]).to eq(:not_found)
    end

    it 'accepts custom rate' do
      result = client.magnetize(pole_id: pole_id, rate: 0.3)
      expect(result[:strength]).to be_within(0.001).of(0.8)
    end

    it 'accepts injected engine' do
      pole = engine.create_pole(polarity: :positive, content: 'x')
      result = client.magnetize(pole_id: pole.id, engine: engine)
      expect(result[:success]).to be true
    end
  end

  describe '#interact' do
    let(:pos_id) { client.create_pole(polarity: :positive, content: 'A')[:pole][:id] }
    let(:neg_id) { client.create_pole(polarity: :negative, content: 'B')[:pole][:id] }

    it 'returns attraction for opposite polarities' do
      result = client.interact(pole_a_id: pos_id, pole_b_id: neg_id)
      expect(result[:success]).to be true
      expect(result[:type]).to eq(:attraction)
    end

    it 'returns repulsion for same-polarity' do
      other_pos = client.create_pole(polarity: :positive, content: 'C')[:pole][:id]
      result    = client.interact(pole_a_id: pos_id, pole_b_id: other_pos)
      expect(result[:success]).to be true
      expect(result[:type]).to eq(:repulsion)
    end

    it 'returns error for unknown pole_a' do
      result = client.interact(pole_a_id: 'bad', pole_b_id: neg_id)
      expect(result[:success]).to be false
      expect(result[:error]).to eq(:pole_a_not_found)
    end

    it 'returns error for unknown pole_b' do
      result = client.interact(pole_a_id: pos_id, pole_b_id: 'bad')
      expect(result[:success]).to be false
      expect(result[:error]).to eq(:pole_b_not_found)
    end

    it 'returns error for same pole id' do
      result = client.interact(pole_a_id: pos_id, pole_b_id: pos_id)
      expect(result[:success]).to be false
      expect(result[:error]).to eq(:same_pole)
    end

    it 'accepts injected engine' do
      pa = engine.create_pole(polarity: :positive, content: 'eng_a')
      pb = engine.create_pole(polarity: :negative, content: 'eng_b')
      result = client.interact(pole_a_id: pa.id, pole_b_id: pb.id, engine: engine)
      expect(result[:success]).to be true
    end

    it 'includes force in result' do
      result = client.interact(pole_a_id: pos_id, pole_b_id: neg_id)
      expect(result[:force]).to be_a(Numeric)
    end
  end

  describe '#list_poles' do
    it 'returns empty list when no poles exist' do
      result = client.list_poles
      expect(result[:success]).to be true
      expect(result[:poles]).to eq([])
      expect(result[:count]).to eq(0)
    end

    it 'returns created poles' do
      client.create_pole(polarity: :positive, content: 'x')
      client.create_pole(polarity: :negative, content: 'y')
      result = client.list_poles
      expect(result[:count]).to eq(2)
    end

    it 'respects the limit' do
      5.times { |i| client.create_pole(polarity: :positive, content: "p#{i}") }
      result = client.list_poles(limit: 3)
      expect(result[:count]).to eq(3)
    end

    it 'accepts injected engine' do
      engine.create_pole(polarity: :positive, content: 'eng_pole')
      result = client.list_poles(engine: engine)
      expect(result[:poles].size).to eq(1)
    end
  end

  describe '#magnetic_status' do
    it 'returns a status report' do
      result = client.magnetic_status
      expect(result[:success]).to be true
      expect(result[:report]).to include(:total_poles, :total_fields, :total_interactions)
    end

    it 'reflects created state' do
      client.create_pole(polarity: :positive, content: 'a')
      client.create_field(name: 'f1')
      result = client.magnetic_status
      expect(result[:report][:total_poles]).to eq(1)
      expect(result[:report][:total_fields]).to eq(1)
    end

    it 'accepts injected engine' do
      result = client.magnetic_status(engine: engine)
      expect(result[:success]).to be true
    end
  end
end
