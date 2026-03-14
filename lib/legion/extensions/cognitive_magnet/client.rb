# frozen_string_literal: true

require 'legion/extensions/cognitive_magnet/helpers/constants'
require 'legion/extensions/cognitive_magnet/helpers/pole'
require 'legion/extensions/cognitive_magnet/helpers/field'
require 'legion/extensions/cognitive_magnet/helpers/magnet_engine'
require 'legion/extensions/cognitive_magnet/runners/cognitive_magnet'

module Legion
  module Extensions
    module CognitiveMagnet
      class Client
        include Runners::CognitiveMagnet

        def initialize(**)
          @magnet_engine = Helpers::MagnetEngine.new
        end

        private

        attr_reader :magnet_engine
      end
    end
  end
end
