# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveMagnet::Helpers::Pole do
  subject(:pole) { described_class.new(polarity: :positive, content: 'curiosity about X', domain: :cognition) }

  describe '#initialize' do
    it 'assigns a uuid id' do
      expect(pole.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'sets polarity' do
      expect(pole.polarity).to eq(:positive)
    end

    it 'sets content' do
      expect(pole.content).to eq('curiosity about X')
    end

    it 'sets domain' do
      expect(pole.domain).to eq(:cognition)
    end

    it 'sets default strength to 0.5' do
      expect(pole.strength).to eq(0.5)
    end

    it 'accepts custom strength' do
      p = described_class.new(polarity: :negative, content: 'x', strength: 0.8)
      expect(p.strength).to eq(0.8)
    end

    it 'clamps strength to 0-1' do
      p = described_class.new(polarity: :positive, content: 'x', strength: 2.0)
      expect(p.strength).to eq(1.0)
    end

    it 'sets default material_type to :iron' do
      expect(pole.material_type).to eq(:iron)
    end

    it 'accepts custom material_type' do
      p = described_class.new(polarity: :positive, content: 'x', material_type: :cobalt)
      expect(p.material_type).to eq(:cobalt)
    end

    it 'sets created_at' do
      expect(pole.created_at).to be_a(Time)
    end
  end

  describe '#magnetize!' do
    it 'increases strength by default rate' do
      pole.magnetize!
      expect(pole.strength).to be_within(0.001).of(0.58)
    end

    it 'increases strength by custom rate' do
      pole.magnetize!(0.2)
      expect(pole.strength).to be_within(0.001).of(0.7)
    end

    it 'does not exceed 1.0' do
      p = described_class.new(polarity: :positive, content: 'x', strength: 0.99)
      p.magnetize!(0.5)
      expect(p.strength).to eq(1.0)
    end

    it 'returns self for chaining' do
      expect(pole.magnetize!).to eq(pole)
    end
  end

  describe '#demagnetize!' do
    it 'decreases strength by default decay rate' do
      pole.demagnetize!
      expect(pole.strength).to be_within(0.001).of(0.48)
    end

    it 'decreases strength by custom rate' do
      pole.demagnetize!(0.3)
      expect(pole.strength).to be_within(0.001).of(0.2)
    end

    it 'does not go below 0.0' do
      p = described_class.new(polarity: :negative, content: 'x', strength: 0.01)
      p.demagnetize!(0.5)
      expect(p.strength).to eq(0.0)
    end

    it 'returns self for chaining' do
      expect(pole.demagnetize!).to eq(pole)
    end
  end

  describe '#attracts?' do
    it 'positive attracts negative' do
      pos = described_class.new(polarity: :positive, content: 'a')
      neg = described_class.new(polarity: :negative, content: 'b')
      expect(pos.attracts?(neg)).to be true
    end

    it 'negative attracts positive' do
      neg = described_class.new(polarity: :negative, content: 'a')
      pos = described_class.new(polarity: :positive, content: 'b')
      expect(neg.attracts?(pos)).to be true
    end

    it 'positive does not attract positive' do
      a = described_class.new(polarity: :positive, content: 'a')
      b = described_class.new(polarity: :positive, content: 'b')
      expect(a.attracts?(b)).to be false
    end

    it 'neutral does not attract anything' do
      neutral = described_class.new(polarity: :neutral, content: 'n')
      pos     = described_class.new(polarity: :positive, content: 'p')
      expect(neutral.attracts?(pos)).to be false
    end

    it 'bipolar attracts everything non-neutral' do
      bipolar = described_class.new(polarity: :bipolar, content: 'b')
      pos     = described_class.new(polarity: :positive, content: 'p')
      neg     = described_class.new(polarity: :negative, content: 'n')
      expect(bipolar.attracts?(pos)).to be true
      expect(bipolar.attracts?(neg)).to be true
    end

    it 'bipolar attracted to by positive' do
      pos     = described_class.new(polarity: :positive, content: 'p')
      bipolar = described_class.new(polarity: :bipolar, content: 'b')
      expect(pos.attracts?(bipolar)).to be true
    end
  end

  describe '#repels?' do
    it 'positive repels positive' do
      a = described_class.new(polarity: :positive, content: 'a')
      b = described_class.new(polarity: :positive, content: 'b')
      expect(a.repels?(b)).to be true
    end

    it 'negative repels negative' do
      a = described_class.new(polarity: :negative, content: 'a')
      b = described_class.new(polarity: :negative, content: 'b')
      expect(a.repels?(b)).to be true
    end

    it 'positive does not repel negative' do
      pos = described_class.new(polarity: :positive, content: 'a')
      neg = described_class.new(polarity: :negative, content: 'b')
      expect(pos.repels?(neg)).to be false
    end

    it 'neutral does not repel anything' do
      neutral = described_class.new(polarity: :neutral, content: 'n')
      pos     = described_class.new(polarity: :positive, content: 'p')
      expect(neutral.repels?(pos)).to be false
    end

    it 'bipolar does not repel' do
      bipolar = described_class.new(polarity: :bipolar, content: 'b')
      pos     = described_class.new(polarity: :positive, content: 'p')
      expect(bipolar.repels?(pos)).to be false
    end
  end

  describe '#saturated?' do
    it 'returns false for default strength' do
      expect(pole.saturated?).to be false
    end

    it 'returns true when strength is 1.0' do
      p = described_class.new(polarity: :positive, content: 'x', strength: 1.0)
      expect(p.saturated?).to be true
    end
  end

  describe '#weak?' do
    it 'returns false for default strength' do
      expect(pole.weak?).to be false
    end

    it 'returns true when strength is 0.05' do
      p = described_class.new(polarity: :negative, content: 'x', strength: 0.05)
      expect(p.weak?).to be true
    end
  end

  describe '#strength_label' do
    it 'returns a symbol' do
      expect(pole.strength_label).to be_a(Symbol)
    end

    it 'returns :moderate for strength 0.5' do
      expect(pole.strength_label).to eq(:moderate)
    end
  end

  describe '#to_h' do
    it 'returns a hash with all expected keys' do
      h = pole.to_h
      expect(h).to include(:id, :polarity, :strength, :material_type, :domain, :content,
                            :saturated, :weak, :strength_label, :created_at)
    end

    it 'reflects current state' do
      pole.magnetize!(0.3)
      expect(pole.to_h[:strength]).to be_within(0.001).of(0.8)
    end
  end
end
