# frozen_string_literal: true

require 'securerandom'
require 'legion/extensions/cognitive_magnet/version'
require 'legion/extensions/cognitive_magnet/helpers/constants'
require 'legion/extensions/cognitive_magnet/helpers/pole'
require 'legion/extensions/cognitive_magnet/helpers/field'
require 'legion/extensions/cognitive_magnet/helpers/magnet_engine'
require 'legion/extensions/cognitive_magnet/runners/cognitive_magnet'
require 'legion/extensions/cognitive_magnet/client'

module Legion
  module Extensions
    module CognitiveMagnet
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
