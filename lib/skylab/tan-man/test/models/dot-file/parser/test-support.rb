require_relative '../../../../core'
require_relative '../../../test-support'

# (reference: http://solnic.eu/2014/01/14/custom-rspec-2-matchers.html)
RSpec::Matchers.define :be_sexp do |expected|
  match do |actual|
    not
    if /\ASexps\z/ !~ (_ = actual.class.to_s.split('::')[-2]) then
      @message = "expected containing module to be Sexps,  had #{_}"
    elsif (_ = actual.class.nt_name) != expected
      @message = "expected nt_name to be #{expected.inspect} had #{_.inspect}"
    end
  end
  failure_message_for_should do |actual|
    @message or "unknown failure!"
  end
end

Skylab::TanMan::Models::DotFile::Parser and nil # necessary :(

module Skylab::TanMan::Models::DotFile::Parser::TestSupport
  def self.extended mod
    mod.module_eval do
      extend ModuleMethods
      include ::Skylab::TanMan::TestSupport::InstanceMethods
      before(:all) { _my_before_all }
      let(:client) do
        _runtime = TanMan::API::Achtung::BUILD_RUNTIME_F.call($stderr, $stderr)
        ParserProxy.new _runtime, dir_path: ::File.expand_path('..', __FILE__)
      end
      let(:input_pathname) do
        client.dir_pathname.join("../fixtures/#{input_path_stem}")
      end
    end
  end
  TanMan = ::Skylab::TanMan
  class ParserProxy
    # the point of this (somewhat experimentally) is to see if we can have
    # a 'pure' parser thing that is divorced from our client controller
    # with a minimal amount of dedicated logic

    include TanMan::API::Achtung::SubClient::InstanceMethods
    include TanMan::Models::DotFile::Parser::InstanceMethods

    def initialize runtime, opts
      super runtime
      opts.each { |k, v| send("#{k}=", v) }
    end
    attr_accessor :dir_path
    def dir_pathname
      @dir_pathname ||= (dir_path and ::Pathname.new(dir_path))
    end

    SIMPLE_ABSPATH_RX = %r{/[-_./a-z0-9]*}i # just a jerky experiment
    PATH_TOOLS = ::Object.new.extend(::Skylab::Face::PathTools::InstanceMethods)
      # this looks awful but we want to avoid any interference with tests etc

    def on_parser_info msg
      msg = msg.gsub(SIMPLE_ABSPATH_RX) { |p| PATH_TOOLS.pretty_path p }
      info "      (#{msg})"
    end
  end
  module ModuleMethods
    def input string
      let(:input_string) { string }
      let(:frame) do
        frame = { }
        frame[:result] = client.parse_string string
        frame
      end
      let(:result) { frame[:result] }
    end
    def it_unparses_losslessly(*tags)
      it 'unparses losslessly', *tags do
        result.unparse.should eql(input_string)
      end
    end
  end
end
