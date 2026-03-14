# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveMagnet
      module Runners
        module CognitiveMagnet
          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex)

          extend self

          def create_pole(polarity:, content:, strength: 0.5, material_type: :iron,
                          domain: :general, engine: nil, **)
            unless Helpers::Constants.valid_polarity?(polarity)
              return { success: false, error: :invalid_polarity,
                       valid_polarities: Helpers::Constants::POLARITY_TYPES }
            end

            unless Helpers::Constants.valid_material?(material_type)
              return { success: false, error: :invalid_material,
                       valid_materials: Helpers::Constants::MATERIAL_TYPES }
            end

            eng    = engine || magnet_engine
            result = eng.create_pole(
              polarity:      polarity,
              content:       content,
              strength:      strength,
              material_type: material_type,
              domain:        domain
            )

            if result.is_a?(Hash) && result[:error]
              Legion::Logging.warn "[cognitive_magnet] create_pole failed: #{result[:error]}"
              return { success: false, **result }
            end

            Legion::Logging.debug "[cognitive_magnet] pole created id=#{result.id[0..7]} " \
                                  "polarity=#{polarity} strength=#{strength}"
            { success: true, pole: result.to_h }
          rescue ArgumentError => e
            { success: false, error: :argument_error, message: e.message }
          end

          def create_field(name:, engine: nil, **)
            eng    = engine || magnet_engine
            result = eng.create_field(name: name)

            if result.is_a?(Hash) && result[:error]
              Legion::Logging.warn "[cognitive_magnet] create_field failed: #{result[:error]}"
              return { success: false, **result }
            end

            Legion::Logging.debug "[cognitive_magnet] field created id=#{result.id[0..7]} name=#{name}"
            { success: true, field: result.to_h }
          rescue ArgumentError => e
            { success: false, error: :argument_error, message: e.message }
          end

          def magnetize(pole_id:, rate: Helpers::Constants::ATTRACTION_RATE, engine: nil, **)
            eng    = engine || magnet_engine
            result = eng.magnetize(pole_id, rate: rate)

            if result[:error]
              Legion::Logging.warn "[cognitive_magnet] magnetize failed: #{result[:error]}"
              return { success: false, **result }
            end

            Legion::Logging.debug "[cognitive_magnet] magnetized id=#{pole_id[0..7]} strength=#{result[:strength]}"
            { success: true, **result }
          rescue ArgumentError => e
            { success: false, error: :argument_error, message: e.message }
          end

          def interact(pole_a_id:, pole_b_id:, engine: nil, **)
            eng    = engine || magnet_engine
            result = eng.interact(pole_a_id, pole_b_id)

            if result[:error]
              Legion::Logging.warn "[cognitive_magnet] interact failed: #{result[:error]}"
              return { success: false, **result }
            end

            Legion::Logging.debug "[cognitive_magnet] interaction type=#{result[:type]} " \
                                  "force=#{result[:force].round(4)}"
            { success: true, **result }
          rescue ArgumentError => e
            { success: false, error: :argument_error, message: e.message }
          end

          def list_poles(engine: nil, limit: 50, **)
            eng   = engine || magnet_engine
            poles = eng.poles.values.first(limit).map(&:to_h)
            Legion::Logging.debug "[cognitive_magnet] list_poles count=#{poles.size}"
            { success: true, poles: poles, count: poles.size }
          rescue ArgumentError => e
            { success: false, error: :argument_error, message: e.message }
          end

          def magnetic_status(engine: nil, **)
            eng    = engine || magnet_engine
            report = eng.field_report
            Legion::Logging.debug "[cognitive_magnet] status: poles=#{report[:total_poles]} " \
                                  "fields=#{report[:total_fields]} interactions=#{report[:total_interactions]}"
            { success: true, report: report }
          rescue ArgumentError => e
            { success: false, error: :argument_error, message: e.message }
          end

          private

          def magnet_engine
            @magnet_engine ||= Helpers::MagnetEngine.new
          end
        end
      end
    end
  end
end
