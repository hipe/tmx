require_relative '../test-support'

module Skylab::TanMan::TestSupport::CLI

  ::Skylab::TanMan::TestSupport[ TS_ = self ]

  include CONSTANTS # so we can say TanMan_ in the spec's module

  extend TestSupport_::Quickie

  module ModuleMethods

    include CONSTANTS

  end

  module InstanceMethods

    include CONSTANTS

    # extend MetaHell::Let

    # include MetaHell::Class::Creator::InstanceMethods

    def invoke * argv
      if 1 == argv.length and argv[ 0 ].respond_to?( :each_with_index )
        argv = argv[ 0 ]
      end
      do_debug and some_debug_stream.puts "(argv: #{ argv.inspect })"
      @result = simplified_client.invoke argv
    end

    def expect_section *a, &p
      require_relative 'expect-section'
      expect_section( *a, &p )
    end

    def expect_oldschool_result_for_ui_success
      @result.should eql( true )
    end

    def expect_oldschool_result_for_ui_failure
      @result.should eql( nil )
    end

    def expect_newschool_result_for_ui_success
      @result.should eql( nil )
    end

    def expect_newschool_result_for_success
      @result.should eql( nil )
    end

    def meta_hell_anchor_module
      TS_::Sandbox
    end

    let :action do
      k = klass
      if ! k.ancestors.include? TanMan_::CLI::Action
        fail "sanity - klass looks funny: #{ k }"
      end
      client or fail 'client?'
      o = k.new client
      o
    end

    let :cli do
      spy = output
      o = TanMan_::CLI.new nil, spy.for(:paystream), spy.for(:infostream)
      o.program_name = 'ferp'
      o
    end

    def client
      @client ||= build_client
    end

    def simplified_client
      @client ||= build_simplified_client
    end

    def build_client
      ioa = IO_adapter_spy[].new
      ioa.do_debug_proc = -> { do_debug }
      build_client_wired_with ioa
    end

    def build_simplified_client
      ioa = Spy__.new
      do_debug and ioa.debug!
      build_client_wired_with ioa
    end
    #
    class Spy__ < TestSupport_::IO::Spy::Triad
      def initialize
        super nil
      end
      attr_accessor :pen

      def emit i, x
        ::String === x or fail 'do me'
        ( :payload == i ? outstream : errstream ).puts x
        nil
      end
    end

    def build_client_wired_with ioa
      o = TanMan_::CLI.new :tanman_nosee_1, :tanman_nosee_2, :tanman_nosee_3
      o.program_name = 'tanmun'
      ioa_ = o.io_adapter
      ioa.pen = ioa_.pen
      o.io_adapter_notify ioa
      o
    end

    def peek_any_next_info_line
      baked.peek_any_next_line_in :errstream
    end

    def nonstyled_info_line
      expect_line_is_not_styled some_info_line
    end

    def nonstyled_pay_line
      expect_line_is_not_styled some_pay_line
    end

    def styled_info_line
      expect_line_is_styled some_info_line
    end

    def some_info_line
      baked.some_line_in :errstream
    end

    def some_pay_line
      baked.some_line_in :outstream
    end

    def expect_no_more_lines
      expect_no_more_info_lines
      expect_no_more_pay_lines
    end

    def expect_no_more_info_lines
      baked.num_lines_remaining_in( :errstream ).should be_zero
    end

    def expect_no_more_pay_lines
      baked.num_lines_remaining_in( :outstream ).should be_zero
    end

    def expect_line_is_styled line
      unstyled = TestLib_::Unstyle_styled[ line ]
      unstyled or fail "expecting styled line, had - #{ line.inspect }"
      unstyled
    end

    def expect_line_is_not_styled line
      unstyled = TestLib_::Unstyle_styled[ line ]
      unstyled and fail "expecting non-styled line, had - #{ line.inspect }"
      line
    end

    def baked
      @baked ||= bake
    end

    def bake
      instance_variable_defined? :@__memoized and @__memoized and
        @__memoized.key?( :output ) and fail "sanity - use simplified client."
      ioa = @client.send :io_adapter
      @client.instance_variable_set :@io_adapter, :was_baked
      Baked__.new ioa.members, ioa.to_a
    end
    #
    class Baked__
      def initialize i_a, val_a
        @a = i_a
        @h = ::Hash[ i_a.length.times.map do |d|
          if (( x = val_a.fetch d ))
            x = x.string.split( "\n" )
          end
          [ i_a.fetch( d ), x ]
        end ]
        nil
      end

      def peek_any_next_line_in stream_i
        @h.fetch( stream_i )[ 0 ]
      end

      def some_line_in stream_i
        @h[ stream_i ].length.zero? and
          fail "expected line in '#{ stream_i }' - had no lines"
        @h[ stream_i ].shift
      end

      def num_lines_remaining_in stream_i
        @h[ stream_i ].length
      end
    end
  end

  module Sandbox
    # do not touch! (we got bit before when we had `Actions` both as a module
    # here and in tests doh!)
  end
end
