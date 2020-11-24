# frozen_string_literal: true

require_relative './strictly_fake/version'

# StrictlyFake - verifying fake
class StrictlyFake
  class Error < StandardError; end

  # Actual fake
  class Fake
    begin
      require 'minitest'
      include Minitest::Assertions
    rescue LoadError
      # wtf rubocop
    end

    attr_accessor :assertions

    def initialize
      @assertions = 0
    end
  end

  def initialize(real)
    @real = real
    @fake = Fake.new
  end

  def stub(meth, &block)
    raise Error, "Can't stub #stub" if meth.to_s == 'stub'

    assert_method_defined(meth)

    expected_parameters = @real.method(meth).parameters
    actual_parameters = convert_to_lambda(&block).parameters

    assert_method_signature_match(meth, expected_parameters, actual_parameters)

    stub_method(meth, &block)
  end

  # rubocop:disable Lint/MissingSuper
  def method_missing(meth, *args)
    @fake.send(meth, *args)
  end
  # rubocop:enable Lint/MissingSuper

  def respond_to_missing?(meth, *_args)
    @fake.respond_to?(meth) || super
  end

  private

  def stub_method(meth, &block)
    if respond_to?(meth)
      (class << self; self; end).class_eval do
        undef_method meth
      end
    end

    (class << @fake; self; end).class_eval do
      define_method(meth, &block)
    end
  end

  def real_class_name
    @real.is_a?(Class) ? @real.name : @real.class.name
  end

  def assert_method_defined(meth)
    return if @real.respond_to?(meth)

    method_type = @real.is_a?(Class) ? '.' : '#'
    raise Error, "Can't stub non-existent method #{real_class_name}#{method_type}#{meth}"
  end

  def assert_method_signature_match(meth, expected_parameters, actual_parameters)
    return if method_signatures_match?(expected_parameters, actual_parameters)

    method_type = @real.is_a?(Class) ? '.' : '#'

    raise Error, "Expected #{real_class_name}#{method_type}#{meth} stub to "\
      "accept (#{format_parametes(expected_parameters)}), but was (#{format_parametes(actual_parameters)})"
  end

  def format_parametes(parameters)
    parameters.map do |(type, name)|
      {
        req: 'req',
        opt: 'opt=',
        rest: '*rest',
        key: ":#{name}",
        keyreq: ":#{name}",
        keyrest: '**keyrest'
      }.fetch(type)
    end.join(', ')
  end

  def method_signatures_match?(expected_parameters, actual_parameters)
    expected_keyword_parameters, expected_positional_parameters = split_parameters_by_type(expected_parameters)
    actual_keyword_parameters, actual_positional_parameters = split_parameters_by_type(actual_parameters)

    positional_arguments_match = expected_positional_parameters == actual_positional_parameters
    keyword_arguments_match = expected_keyword_parameters == actual_keyword_parameters

    positional_arguments_match && keyword_arguments_match
  end

  def split_parameters_by_type(parameters)
    keyword_parameters, positional_parameters = parameters.partition { |(arg_type)| arg_type.to_s =~ /^key/ }
    keyrest = pop_keyrest(keyword_parameters)

    [
      keyword_parameters.map(&:last).sort + (keyrest ? [:keyrest] : []),
      positional_parameters.map(&:first).reject { |p| p == :block }
    ]
  end

  def pop_keyrest(keyword_parameters)
    return unless keyword_parameters.last && keyword_parameters.last.first == :keyrest

    keyword_parameters.pop
  end

  # Procs don't have `req` parameters, but lambdas do
  def convert_to_lambda(&block)
    obj = Object.new
    obj.define_singleton_method(:_, &block)
    obj.method(:_).to_proc
  end
end
