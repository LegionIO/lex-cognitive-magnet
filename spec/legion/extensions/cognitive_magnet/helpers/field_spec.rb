# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveMagnet::Helpers::Field do
  subject(:field) { described_class.new(name: 'semantic_cluster') }

  let(:pole_pos) do
    Legion::Extensions::CognitiveMagnet::Helpers::Pole.new(
      polarity: :positive, content: 'idea A', strength: 0.7
    )
  end
  let(:pole_neg) do
    Legion::Extensions::CognitiveMagnet::Helpers::Pole.new(
      polarity: :negative, content: 'idea B', strength: 0.6
    )
  end
  let(:pole_pos2) do
    Legion::Extensions::CognitiveMagnet::Helpers::Pole.new(
      polarity: :positive, content: 'idea C', strength: 0.8
    )
  end
  let(:poles_hash) do
    { pole_pos.id => pole_pos, pole_neg.id => pole_neg }
  end

  describe '#initialize' do
    it 'assigns a uuid id' do
      expect(field.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'sets name' do
      expect(field.name).to eq('semantic_cluster')
    end

    it 'initializes with empty pole_ids' do
      expect(field.pole_ids).to eq([])
    end

    it 'initializes alignment to 0.0' do
      expect(field.alignment).to eq(0.0)
    end

    it 'initializes flux_density to 0.0' do
      expect(field.flux_density).to eq(0.0)
    end

    it 'sets created_at' do
      expect(field.created_at).to be_a(Time)
    end
  end

  describe '#add_pole' do
    it 'adds a pole id and returns true' do
      result = field.add_pole(pole_pos.id)
      expect(result).to be true
      expect(field.pole_ids).to include(pole_pos.id)
    end

    it 'does not add duplicates and returns false' do
      field.add_pole(pole_pos.id)
      result = field.add_pole(pole_pos.id)
      expect(result).to be false
      expect(field.pole_ids.count(pole_pos.id)).to eq(1)
    end

    it 'can add multiple poles' do
      field.add_pole(pole_pos.id)
      field.add_pole(pole_neg.id)
      expect(field.pole_ids.size).to eq(2)
    end
  end

  describe '#remove_pole' do
    before { field.add_pole(pole_pos.id) }

    it 'removes a pole and returns true' do
      result = field.remove_pole(pole_pos.id)
      expect(result).to be true
      expect(field.pole_ids).not_to include(pole_pos.id)
    end

    it 'returns false when pole not in field' do
      result = field.remove_pole('nonexistent-id')
      expect(result).to be false
    end
  end

  describe '#calculate_alignment!' do
    it 'returns self for chaining' do
      expect(field.calculate_alignment!({})).to eq(field)
    end

    it 'does nothing with empty poles hash' do
      field.add_pole(pole_pos.id)
      field.calculate_alignment!({})
      expect(field.alignment).to eq(0.0)
    end

    it 'computes alignment with attraction pair (positive+negative)' do
      field.add_pole(pole_pos.id)
      field.add_pole(pole_neg.id)
      field.calculate_alignment!(poles_hash)
      expect(field.alignment).to be > 0.5
    end

    it 'computes alignment with repulsion pair (positive+positive)' do
      pos2_h = { pole_pos.id => pole_pos, pole_pos2.id => pole_pos2 }
      field.add_pole(pole_pos.id)
      field.add_pole(pole_pos2.id)
      field.calculate_alignment!(pos2_h)
      expect(field.alignment).to be <= 0.5
    end

    it 'updates flux_density' do
      field.add_pole(pole_pos.id)
      field.add_pole(pole_neg.id)
      field.calculate_alignment!(poles_hash)
      expect(field.flux_density).to be > 0.0
    end

    it 'handles single pole gracefully' do
      field.add_pole(pole_pos.id)
      field.calculate_alignment!({ pole_pos.id => pole_pos })
      expect(field.alignment).to eq(0.0)
    end
  end

  describe '#coherent?' do
    it 'returns false by default' do
      expect(field.coherent?).to be false
    end

    it 'returns true when alignment >= 0.6' do
      field.add_pole(pole_pos.id)
      field.add_pole(pole_neg.id)
      field.calculate_alignment!(poles_hash)
      if field.alignment >= 0.6
        expect(field.coherent?).to be true
      else
        expect(field.coherent?).to be false
      end
    end
  end

  describe '#chaotic?' do
    it 'returns true by default (alignment 0.0)' do
      expect(field.chaotic?).to be true
    end

    it 'returns false when alignment is moderate' do
      field.add_pole(pole_pos.id)
      field.add_pole(pole_neg.id)
      field.calculate_alignment!(poles_hash)
      expect(field.chaotic?).to be(field.alignment < 0.2)
    end
  end

  describe '#alignment_label' do
    it 'returns a symbol' do
      expect(field.alignment_label).to be_a(Symbol)
    end

    it 'returns :chaotic for default alignment 0.0' do
      expect(field.alignment_label).to eq(:chaotic)
    end
  end

  describe '#pole_count' do
    it 'returns 0 initially' do
      expect(field.pole_count).to eq(0)
    end

    it 'returns correct count after adding poles' do
      field.add_pole(pole_pos.id)
      field.add_pole(pole_neg.id)
      expect(field.pole_count).to eq(2)
    end
  end

  describe '#to_h' do
    it 'includes all expected keys' do
      h = field.to_h
      expect(h).to include(:id, :name, :pole_ids, :alignment, :flux_density, :pole_count,
                           :coherent, :chaotic, :alignment_label, :created_at)
    end

    it 'returns a copy of pole_ids' do
      field.add_pole(pole_pos.id)
      h = field.to_h
      h[:pole_ids] << 'injected'
      expect(field.pole_ids.size).to eq(1)
    end
  end
end
