require_relative '../../../../..' # bootstrap-in skylab.rb here :/
require_relative '../../../../core'

class ::String
  # note you will still have a trailing newline, for which u could chop
  def here # aka unindent, deindent
    gsub(/^#{::Regexp.escape(match(/\A(?<margin>[[:space:]]+)/)[:margin])}/, '')
  end
end

# (reference: http://solnic.eu/2011/01/14/custom-rspec-2-matchers.html)
RSpec::Matchers.define :be_sexp do |expected|
  match do |actual|
    not
    if /Sexp\z/ !~ (_ = actual.class.to_s.split('::').last) then
      @message = "expected Sexp had #{_}"
    elsif (_ = actual.class.nt_name) != expected
      @message = "expected #{expected} had #{_}"
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
    end
  end
  TanMan = ::Skylab::TanMan
  class ParserProxy
    # the point of this (somewhat experimentally) is to see if we can have
    # a 'pure' parser thing that is divorced from our client controller
    # with a minimal amount of dedicated logic

    include TanMan::API::Achtung::SubClient::InstanceMethods
    include TanMan::Models::DotFile::Parser::InstanceMethods
  end
  module ModuleMethods
    def input string
      frame_f = ->() do
        frame = { }
        runtime = TanMan::API::Achtung::BUILD_RUNTIME_F.call($stderr, $stderr)
        parser = ParserProxy.new runtime
        frame[:sexp] = parser.parse_string(string)
        ( frame_f = ->() { frame } ).call
      end
      let(:input) { string }
      let(:sexp) { frame_f.call[:sexp] }
    end
  end
end
