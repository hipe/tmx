require_relative '../test-support'

module Skylab::Snag::TestSupport::CLI
  ::Skylab::Snag::TestSupport[ CLI_TestSupport = self ]

  include CONSTANTS

  extend TestSupport::Quickie  # try running a _spec.rb file with `ruby -w`

  FUN = -> do

    o = { }

    o[:output] = -> do
      output = TestSupport::IO::Spy::Group.new
      output.line_filter! -> s do
        Headless::CLI::Pen::FUN.unstyle[ s ]
      end
      output
    end

    o[:client] = -> output do
      client = Snag::CLI.new nil, output.for( :pay ), output.for( :info )
      client.send :program_name=, 'sn0g'
      client
    end

    fun = ::Struct.new(* o.keys).new ; o.each { |k, v| fun[k] = v } ; fun.freeze

    fun
  end.call

  module ModuleMethods
    include CONSTANTS  # so we can reach m.h from methods

    def use_memoized_client
      if ! method_defined? :memo_frame
        define_method :memo_frame, & MetaHell::FUN.memoize[ -> do
          output = FUN.output[]
          client = FUN.client[ output ]
          { output: output, client: client }
        end ]

        define_method :output do
          memo_frame[:output]
        end

        define_method :client do
          mf = memo_frame
          # (what would be ideal is to be able to turn debugging on on a per-
          # scenario basis, even though it is a memoized frame.. is that crazy?
          # b.c our io spy has the most sophisticaated debugging interface
          # possible, hopefully..)
          if do_debug
            op = memo_frame[:output]
            if ! op.debug  # it is a struct. if it was set hopefully it was here
              op.do_debug_proc = -> { do_debug }  # and etc. the idea is awesome
            end
          end
          mf[:client]
        end
      end
    end
  end

  module InstanceMethods
    include CONSTANTS

    def client_invoke *argv
      output.lines.clear
      @result = client.invoke argv
      @result
    end

    let :output do  # careful - this gets rewritten by `use_memoized_client`
      output = CLI_TestSupport::FUN::output[]
      output.do_debug_proc = -> { do_debug }
      output
    end

    let :client do # careful - this gets rewritten by `use_memoized_client`
      FUN.client[ output ]
    end

    def o *a
      if a.empty?
        output.lines.length.should eql( 0 )
      else
        if 1 == a.length
          a.unshift :info
        end
        if 2 != a.length
          raise "sanity - expecting [type] [rx], had #{ a.inspect }"
        end
        stream_name, rx = a
        curr = output.lines.shift
        if curr
          curr.string.should match( rx )
          curr.stream_name.should eql( stream_name )
        else
          fail "Had no more events in queue, #{
            }expecting #{ [stream_name, rx].inspect }"
        end
      end
      nil
    end

    attr_reader :result
  end
end
