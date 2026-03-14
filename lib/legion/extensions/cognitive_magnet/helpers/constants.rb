# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveMagnet
      module Helpers
        module Constants
          POLARITY_TYPES   = %i[positive negative neutral bipolar].freeze
          MATERIAL_TYPES   = %i[iron cobalt nickel lodestone ferrite].freeze
          MAX_POLES        = 500
          MAX_FIELDS       = 50
          ATTRACTION_RATE  = 0.08
          REPULSION_RATE   = 0.06
          DECAY_RATE       = 0.02

          STRENGTH_LABELS = {
            (0.0..0.1) => :negligible,
            (0.1..0.3) => :faint,
            (0.3..0.5) => :moderate,
            (0.5..0.7) => :strong,
            (0.7..0.9) => :intense,
            (0.9..1.0) => :overwhelming
          }.freeze

          ALIGNMENT_LABELS = {
            (0.0..0.2) => :chaotic,
            (0.2..0.4) => :discordant,
            (0.4..0.6) => :neutral,
            (0.6..0.8) => :coherent,
            (0.8..1.0) => :perfect
          }.freeze

          module_function

          def label_for(table, value)
            table.each do |range, label|
              return label if range.cover?(value)
            end
            :unknown
          end

          def valid_polarity?(polarity)
            POLARITY_TYPES.include?(polarity)
          end

          def valid_material?(material)
            MATERIAL_TYPES.include?(material)
          end
        end
      end
    end
  end
end
