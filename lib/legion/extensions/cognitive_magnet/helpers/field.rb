# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module CognitiveMagnet
      module Helpers
        class Field
          attr_reader :id, :name, :pole_ids, :alignment, :flux_density, :created_at

          def initialize(name:)
            @id          = SecureRandom.uuid
            @name        = name
            @pole_ids    = []
            @alignment   = 0.0
            @flux_density = 0.0
            @created_at  = Time.now.utc
          end

          def add_pole(pole_id)
            return false if @pole_ids.include?(pole_id)

            @pole_ids << pole_id
            true
          end

          def remove_pole(pole_id)
            removed = @pole_ids.delete(pole_id)
            !removed.nil?
          end

          def calculate_alignment!(poles)
            field_poles = poles.values.select { |p| @pole_ids.include?(p.id) }
            return self if field_poles.empty?

            @flux_density = field_poles.sum(&:strength) / field_poles.size.to_f
            @alignment    = compute_alignment(field_poles).round(10)
            self
          end

          def coherent?
            @alignment >= 0.6
          end

          def chaotic?
            @alignment < 0.2
          end

          def alignment_label
            Constants.label_for(Constants::ALIGNMENT_LABELS, @alignment)
          end

          def pole_count
            @pole_ids.size
          end

          def to_h
            {
              id:           @id,
              name:         @name,
              pole_ids:     @pole_ids.dup,
              alignment:    @alignment,
              flux_density: @flux_density,
              pole_count:   pole_count,
              coherent:     coherent?,
              chaotic:      chaotic?,
              alignment_label: alignment_label,
              created_at:   @created_at
            }
          end

          private

          def compute_alignment(field_poles)
            return 0.0 if field_poles.size < 2

            total_pairs    = 0
            aligned_weight = 0.0

            field_poles.combination(2) do |a, b|
              total_pairs += 1
              pair_weight  = (a.strength + b.strength) / 2.0

              if a.attracts?(b)
                aligned_weight += pair_weight
              elsif a.repels?(b)
                aligned_weight -= pair_weight * 0.5
              end
            end

            return 0.5 if total_pairs.zero?

            raw = aligned_weight / total_pairs.to_f
            ((raw + 1.0) / 2.0).clamp(0.0, 1.0)
          end
        end
      end
    end
  end
end
