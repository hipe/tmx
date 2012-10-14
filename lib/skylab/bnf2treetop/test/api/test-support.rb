require_relative '../test-support'

module Skylab::Bnf2Treetop::API::TestSupport
  def self.extended mod
    mod.module_eval do
      include InstanceMethods
    end
  end
  module InstanceMethods
    StreamSpy = ::Skylab::TestSupport::StreamSpy

    attr_reader :info

    def out ; @out ||= @paystream_string.split("\n") end

    def translate request

      request[:upstream] = ::StringIO.new(request.delete(:string))

      request[:paystream] = paystream =
        ::StringIO.new
        # StreamSpy.standard.debug!('      FOO')
      request[:infostream] = infostream =
        ::StringIO.new
        # StreamSpy.standard.debug!('      WTF!? - ')

      ::Skylab::Bnf2Treetop::API.translate(request) # t or nil

      @info = infostream.string.split("\n")
      @out = nil
      @paystream_string = request[:paystream].string

      request[:paystream].string
    end
  end
end
