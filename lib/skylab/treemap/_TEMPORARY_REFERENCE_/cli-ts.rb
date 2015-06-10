require_relative '../test-support'

module Skylab::Treemap::TestSupport::CLI

  ::Skylab::Treemap::TestSupport[ TS_ = self ]

  include Constants

  extend TestSupport::Quickie

  NUM_STREAMS = { 2 => 2, 3 => 3 }  # hack something..

  module ModuleMethods
    define_method :num_streams do |num|
      NUM_STREAMS.fetch num
      define_method :_num_streams do num end
      num
    end
  end

  module InstanceMethods
    include Constants  # `TestSupport` is called upon in i.m's

    def _num_streams
      :set_number_of_streams_with_num_streams
    end

    #         ~ for the 3-stream version ~

    def client
      @client ||= begin
        streams = self.streams
        cli = Treemap::CLI.new(* streams.values )
        cli.program_name = 'nerkiss'
        cli
      end
    end

    define_method :debug! do |*a|
      case NUM_STREAMS.fetch( _num_streams )
      when 2
        stream.sout.debug!(* a )
        stream.serr.debug!(* a )
      when 3
        streams.debug!(* a )
      end
      nil
    end

    def serrs
      @serrs ||= streams.errstream.string.split "\n"
    end

    def streams
      @streams ||= TestSupport::IO.spy.triad.new nil  # no $stdin
    end

    def styled s

      LIB_.brazen::CLI::Styling.unstyle_styled s
    end

    def styld exp
      str = styled serrs.shift
      if ::Regexp === exp
        str.should match( exp )
      else
        str.should eql( exp )
      end
      nil
    end

    def white
      str = serrs.shift
      str.should eql( '' )
    end

    #         ~ for the 2-stream form ~

    def serr
      _unstyle :serr
    end

    def sout
      _unstyle :sout
    end

    def _unstyle k
      Treemap_.lib_.CLI_lib.pen.unstyle stream[ k ].string
    end

    def stream
      @stream ||= Stream__.new( TestSupport::IO.spy.new, TestSupport::IO.spy.new )
    end

    Stream__ = ::Struct.new :sout, :serr

    def tmx_cli # (was [#051] legacy test wiring)
      @tmx_cli ||= begin
        require 'skylab/tmx/core'
        cli = ::Skylab::TMX::CLI.new( program_name: 'tmx',
          sin: nil, out: stream.sout, err: stream.serr )
        cli
      end
    end
  end
end
