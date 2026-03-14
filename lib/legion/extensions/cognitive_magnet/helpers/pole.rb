# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module CognitiveMagnet
      module Helpers
        class Pole
          attr_reader :id, :polarity, :strength, :material_type, :domain, :content, :created_at

          def initialize(polarity:, content:, strength: 0.5, material_type: :iron, domain: :general)
            @id            = SecureRandom.uuid
            @polarity      = polarity
            @content       = content
            @strength      = strength.to_f.clamp(0.0, 1.0).round(10)
            @material_type = material_type
            @domain        = domain
            @created_at    = Time.now.utc
          end

          def magnetize!(rate = Constants::ATTRACTION_RATE)
            @strength = (@strength + rate.to_f).clamp(0.0, 1.0).round(10)
            self
          end

          def demagnetize!(rate = Constants::DECAY_RATE)
            @strength = (@strength - rate.to_f).clamp(0.0, 1.0).round(10)
            self
          end

          def attracts?(other_pole)
            return false if @polarity == :neutral || other_pole.polarity == :neutral
            return true if @polarity == :bipolar || other_pole.polarity == :bipolar

            @polarity != other_pole.polarity
          end

          def repels?(other_pole)
            return false if @polarity == :neutral || other_pole.polarity == :neutral
            return false if @polarity == :bipolar || other_pole.polarity == :bipolar

            @polarity == other_pole.polarity
          end

          def saturated?
            @strength >= 1.0
          end

          def weak?
            @strength <= 0.1
          end

          def strength_label
            Constants.label_for(Constants::STRENGTH_LABELS, @strength)
          end

          def to_h
            {
              id:            @id,
              polarity:      @polarity,
              strength:      @strength,
              material_type: @material_type,
              domain:        @domain,
              content:       @content,
              saturated:     saturated?,
              weak:          weak?,
              strength_label: strength_label,
              created_at:    @created_at
            }
          end
        end
      end
    end
  end
end
