# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveMagnet::Helpers::Constants do
  describe 'POLARITY_TYPES' do
    it 'includes expected polarity types' do
      expect(described_class::POLARITY_TYPES).to include(:positive, :negative, :neutral, :bipolar)
    end

    it 'is frozen' do
      expect(described_class::POLARITY_TYPES).to be_frozen
    end
  end

  describe 'MATERIAL_TYPES' do
    it 'includes expected material types' do
      expect(described_class::MATERIAL_TYPES).to include(:iron, :cobalt, :nickel, :lodestone, :ferrite)
    end

    it 'is frozen' do
      expect(described_class::MATERIAL_TYPES).to be_frozen
    end
  end

  describe 'capacity constants' do
    it 'defines MAX_POLES as 500' do
      expect(described_class::MAX_POLES).to eq(500)
    end

    it 'defines MAX_FIELDS as 50' do
      expect(described_class::MAX_FIELDS).to eq(50)
    end
  end

  describe 'rate constants' do
    it 'defines ATTRACTION_RATE as 0.08' do
      expect(described_class::ATTRACTION_RATE).to eq(0.08)
    end

    it 'defines REPULSION_RATE as 0.06' do
      expect(described_class::REPULSION_RATE).to eq(0.06)
    end

    it 'defines DECAY_RATE as 0.02' do
      expect(described_class::DECAY_RATE).to eq(0.02)
    end
  end

  describe 'STRENGTH_LABELS' do
    it 'covers 0.0 to 1.0 range' do
      expect(described_class::STRENGTH_LABELS).to be_a(Hash)
      expect(described_class::STRENGTH_LABELS.size).to be >= 5
    end

    it 'is frozen' do
      expect(described_class::STRENGTH_LABELS).to be_frozen
    end
  end

  describe 'ALIGNMENT_LABELS' do
    it 'covers alignment range' do
      expect(described_class::ALIGNMENT_LABELS).to be_a(Hash)
      expect(described_class::ALIGNMENT_LABELS.size).to be >= 4
    end

    it 'is frozen' do
      expect(described_class::ALIGNMENT_LABELS).to be_frozen
    end
  end

  describe '.label_for' do
    it 'returns correct label for strength 0.05' do
      label = described_class.label_for(described_class::STRENGTH_LABELS, 0.05)
      expect(label).to eq(:negligible)
    end

    it 'returns correct label for strength 0.95' do
      label = described_class.label_for(described_class::STRENGTH_LABELS, 0.95)
      expect(label).to eq(:overwhelming)
    end

    it 'returns correct alignment label for 0.9' do
      label = described_class.label_for(described_class::ALIGNMENT_LABELS, 0.9)
      expect(label).to eq(:perfect)
    end

    it 'returns correct alignment label for 0.1' do
      label = described_class.label_for(described_class::ALIGNMENT_LABELS, 0.1)
      expect(label).to eq(:chaotic)
    end

    it 'returns :unknown for a value not in any range' do
      label = described_class.label_for({}, 0.5)
      expect(label).to eq(:unknown)
    end
  end

  describe '.valid_polarity?' do
    it 'returns true for valid polarities' do
      %i[positive negative neutral bipolar].each do |p|
        expect(described_class.valid_polarity?(p)).to be true
      end
    end

    it 'returns false for invalid polarity' do
      expect(described_class.valid_polarity?(:zap)).to be false
    end
  end

  describe '.valid_material?' do
    it 'returns true for valid materials' do
      %i[iron cobalt nickel lodestone ferrite].each do |m|
        expect(described_class.valid_material?(m)).to be true
      end
    end

    it 'returns false for invalid material' do
      expect(described_class.valid_material?(:plastic)).to be false
    end
  end
end
