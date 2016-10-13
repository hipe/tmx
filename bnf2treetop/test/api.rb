module Skylab::BNF2Treetop::TestSupport

  module API

    def self.[] tcc
      tcc.include Instance_Methods___
    end
  end

  module API::Instance_Methods___

    attr_reader :info

    def out
      @out ||= @paystream_string.split NEWLINE_
    end

    def translate request

      request[:upstream] = ::StringIO.new request.delete( :string )

      request[:paystream] = ::StringIO.new

      request[:infostream] = infostream = ::StringIO.new

      ::Skylab::BNF2Treetop::API.translate(request) # t or nil

      @info = infostream.string.split("\n")
      @out = nil
      @paystream_string = request[:paystream].string

      request[:paystream].string
    end
  end
end
