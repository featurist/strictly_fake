# frozen_string_literal: true

require_relative 'spec_helper'

# rubocop:disable Metrics/ParameterLists
class RealThing
  def self.foo(aaa, ddd = 2, *args, bbb:, ccc: 5, **opts); end

  def self.bar; end

  def foo(aaa, ddd = 2, *args, bbb:, ccc: 5, **opts); end

  def bar; end
end

# rubocop:disable Metrics/BlockLength
RSpec.describe StrictFake do
  it 'has a version number' do
    expect(StrictFake::VERSION)
  end

  it 'raises if stubbed object does not have stubbed method' do
    fake = StrictFake.new(RealThing.new)

    expect do
      fake.stub(:fiction) {}
    end.to raise_error(StrictFake::Error, "Can't stub non-existent method RealThing#fiction")
  end

  it 'raises if stubbed object does not have stubbed class method' do
    fake = StrictFake.new(RealThing)

    expect do
      fake.stub(:fiction) {}
    end.to raise_error(StrictFake::Error, "Can't stub non-existent method RealThing.fiction")
  end

  it 'raises if stubbed method signature does not match the real thing' do
    fake = StrictFake.new(RealThing.new)

    expect do
      fake.stub(:foo) {}
    end.to raise_error(
      StrictFake::Error,
      'Expected RealThing#foo stub to accept (req, opt=, *rest, :bbb, :ccc, **keyrest), but was ()'
    )

    fake = StrictFake.new(RealThing)

    expect do
      fake.stub(:bar) { |nnn, aaa:, **opts| }
    end.to raise_error(
      StrictFake::Error,
      'Expected RealThing.bar stub to accept (), but was (req, :aaa, **keyrest)'
    )
  end

  it 'defines stubbed method' do
    fake = StrictFake.new(RealThing.new)
    n = 0

    fake.stub(:bar) { n = 1 }

    fake.bar
    fake.method :bar

    expect(n).to eq(1)
  end

  it 'keyword arguments can be in any order' do
    fake = StrictFake.new(RealThing.new)

    expect do
      fake.stub(:foo) { |aaa, ddd = 6, *restargs, bbb:, ccc: 5, **keyopts| }
    end.to_not raise_error
  end

  it 'stubbed methods can have minitest assertions inside' do
    fake = StrictFake.new(RealThing.new)

    fake.stub(:bar) do
      assert(true)
    end

    fake.bar
  end

  it 'ignores block parameter' do
    fake = StrictFake.new(RealThing.new)

    expect { fake.stub(:bar) { |&block| } }.to_not raise_error
  end
end
# rubocop:enable Metrics/BlockLength
# rubocop:enable Metrics/ParameterLists
