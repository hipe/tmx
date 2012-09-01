require_relative '../../test-support'

module Skylab::Bnf2Treetop::API::Parameter end

module Skylab::Bnf2Treetop::API::Parameter::TestSupport
  def self.extended mod
    mod.module_eval do
      include InstanceMethods
    end
  end
  module InstanceMethods
    StreamSpy = ::Skylab::TestSupport::StreamSpy

    def translate request
      request[:paystream] = ::StringIO.new
      # request[:paystream] = StreamSpy.standard.debug!('      FOO')

      request[:upstream] = ::StringIO.new(request.delete(:string))

      # request[:infostream] # leave blank intentionally. should not get used.
      request[:infostream] = StreamSpy.standard.debug!('      WTF!? - ')

      Skylab::Bnf2Treetop::API.translate(request) # t or nil
      request[:paystream].string
    end
  end
end
