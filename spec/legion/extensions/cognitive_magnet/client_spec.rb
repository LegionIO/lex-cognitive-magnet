# frozen_string_literal: true

require 'legion/extensions/cognitive_magnet/client'

RSpec.describe Legion::Extensions::CognitiveMagnet::Client do
  it 'responds to all runner methods' do
    client = described_class.new
    expect(client).to respond_to(:create_pole)
    expect(client).to respond_to(:create_field)
    expect(client).to respond_to(:magnetize)
    expect(client).to respond_to(:interact)
    expect(client).to respond_to(:list_poles)
    expect(client).to respond_to(:magnetic_status)
  end

  it 'initializes with a fresh magnet engine' do
    client = described_class.new
    result = client.magnetic_status
    expect(result[:report][:total_poles]).to eq(0)
    expect(result[:report][:total_fields]).to eq(0)
  end

  it 'maintains isolated state per instance' do
    a = described_class.new
    b = described_class.new
    a.create_pole(polarity: :positive, content: 'only in a')
    expect(a.magnetic_status[:report][:total_poles]).to eq(1)
    expect(b.magnetic_status[:report][:total_poles]).to eq(0)
  end
end
