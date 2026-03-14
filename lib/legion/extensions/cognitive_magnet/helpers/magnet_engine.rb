# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveMagnet
      module Helpers
        class MagnetEngine
          attr_reader :poles, :fields, :interaction_log

          def initialize
            @poles           = {}
            @fields          = {}
            @interaction_log = []
          end

          def create_pole(polarity:, content:, strength: 0.5, material_type: :iron, domain: :general)
            return { error: :capacity_exceeded, max: Constants::MAX_POLES } if at_pole_capacity?

            pole = Pole.new(
              polarity:      polarity,
              content:       content,
              strength:      strength,
              material_type: material_type,
              domain:        domain
            )
            @poles[pole.id] = pole
            pole
          end

          def create_field(name:)
            return { error: :capacity_exceeded, max: Constants::MAX_FIELDS } if at_field_capacity?

            field = Field.new(name: name)
            @fields[field.id] = field
            field
          end

          def magnetize(pole_id, rate: Constants::ATTRACTION_RATE)
            pole = @poles[pole_id]
            return { error: :not_found } unless pole

            pole.magnetize!(rate)
            { magnetized: true, id: pole_id, strength: pole.strength }
          end

          def interact(pole_a_id, pole_b_id)
            pole_a = @poles[pole_a_id]
            pole_b = @poles[pole_b_id]
            return { error: :pole_a_not_found } unless pole_a
            return { error: :pole_b_not_found } unless pole_b
            return { error: :same_pole } if pole_a_id == pole_b_id

            force = compute_force(pole_a, pole_b)
            type  = determine_interaction_type(pole_a, pole_b)

            apply_interaction(pole_a, pole_b, type)

            event = build_interaction_event(pole_a, pole_b, type, force)
            @interaction_log << event
            event
          end

          def demagnetize_all!(rate: Constants::DECAY_RATE)
            count = 0
            @poles.each_value do |pole|
              pole.demagnetize!(rate)
              count += 1
            end
            { demagnetized: count, rate: rate }
          end

          def most_aligned_fields(limit: 5)
            recalculate_all_fields
            @fields.values
                   .sort_by { |f| -f.alignment }
                   .first(limit)
          end

          def strongest_poles(limit: 5)
            @poles.values
                  .reject(&:weak?)
                  .sort_by { |p| -p.strength }
                  .first(limit)
          end

          def field_report
            recalculate_all_fields
            coherent  = @fields.values.select(&:coherent?)
            chaotic   = @fields.values.select(&:chaotic?)
            saturated = @poles.values.select(&:saturated?)
            weak      = @poles.values.select(&:weak?)

            {
              total_poles:        @poles.size,
              total_fields:       @fields.size,
              coherent_fields:    coherent.size,
              chaotic_fields:     chaotic.size,
              saturated_poles:    saturated.size,
              weak_poles:         weak.size,
              total_interactions: @interaction_log.size,
              strongest:          strongest_poles(limit: 3).map(&:to_h),
              top_fields:         most_aligned_fields(limit: 3).map(&:to_h)
            }
          end

          def add_pole_to_field(field_id:, pole_id:)
            field = @fields[field_id]
            return { error: :field_not_found } unless field
            return { error: :pole_not_found } unless @poles[pole_id]

            added = field.add_pole(pole_id)
            { added: added, field_id: field_id, pole_id: pole_id }
          end

          def remove_pole_from_field(field_id:, pole_id:)
            field = @fields[field_id]
            return { error: :field_not_found } unless field

            removed = field.remove_pole(pole_id)
            { removed: removed, field_id: field_id, pole_id: pole_id }
          end

          private

          def at_pole_capacity?
            @poles.size >= Constants::MAX_POLES
          end

          def at_field_capacity?
            @fields.size >= Constants::MAX_FIELDS
          end

          def compute_force(pole_a, pole_b)
            (pole_a.strength * pole_b.strength).round(10)
          end

          def determine_interaction_type(pole_a, pole_b)
            if pole_a.attracts?(pole_b)
              :attraction
            elsif pole_a.repels?(pole_b)
              :repulsion
            else
              :neutral
            end
          end

          def apply_interaction(pole_a, pole_b, type)
            case type
            when :attraction
              pole_a.magnetize!(Constants::ATTRACTION_RATE * pole_b.strength)
              pole_b.magnetize!(Constants::ATTRACTION_RATE * pole_a.strength)
            when :repulsion
              pole_a.demagnetize!(Constants::REPULSION_RATE * pole_b.strength)
              pole_b.demagnetize!(Constants::REPULSION_RATE * pole_a.strength)
            end
          end

          def build_interaction_event(pole_a, pole_b, type, force)
            {
              type:      type,
              pole_a_id: pole_a.id,
              pole_b_id: pole_b.id,
              force:     force,
              at:        Time.now.utc
            }
          end

          def recalculate_all_fields
            @fields.each_value { |f| f.calculate_alignment!(@poles) }
          end
        end
      end
    end
  end
end
