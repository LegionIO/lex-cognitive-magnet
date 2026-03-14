# frozen_string_literal: true

require_relative 'lib/legion/extensions/cognitive_magnet/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-cognitive-magnet'
  spec.version       = Legion::Extensions::CognitiveMagnet::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX Cognitive Magnet'
  spec.description   = 'Magnetic attraction and repulsion between ideas — polarity-driven cognitive clustering for LegionIO agentic AI'
  spec.homepage      = 'https://github.com/LegionIO/lex-cognitive-magnet'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']        = spec.homepage
  spec.metadata['source_code_uri']     = 'https://github.com/LegionIO/lex-cognitive-magnet'
  spec.metadata['documentation_uri']   = 'https://github.com/LegionIO/lex-cognitive-magnet'
  spec.metadata['changelog_uri']       = 'https://github.com/LegionIO/lex-cognitive-magnet'
  spec.metadata['bug_tracker_uri']     = 'https://github.com/LegionIO/lex-cognitive-magnet/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.start_with?('spec/') }
  spec.require_paths = ['lib']
end
