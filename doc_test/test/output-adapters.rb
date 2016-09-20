module Skylab::DocTest::TestSupport

  module Output_Adapters

    module Quickie

      def self.[] tcc
        tcc.include self
      end

      # -

        def output_adapter_test_document_parser_
          output_adapter_module_::Models::TestDocument::PARSER
        end

        def output_adapter_module_
          output_adapters_module_::Quickie
        end

        def begin_simple_chunker_for_ big_s
          Simple_chunker__[].for big_s
        end

        def begin_forwards_synchronization_session_for_tests_
          this_magnetic_just_for_tests_.new
        end

        def this_magnetic_just_for_tests_
          ForwardsSyncSession___
        end

      # -

      # ==

      Simple_chunker__ = Lazy_.call do

        o = SimpleChunker___.begin
        o.example_opening_regex = %r(^ +it "([^"]+)")
        o.finish
      end
    end

    # ==

    class ForwardsSyncSession___  # why this exists: [#029] #note-6

      attr_writer(
        :asset_path,
        :choices,
        :original_test_path,
      )

      def to_string__
        to_line_stream.reduce_into_by "" do |m, s|
          m << s
        end
      end

      def to_line_stream
        o = self.class.operation_.new
        o.asset_line_stream = ::File.open @asset_path
        o.instance_variable_set :@choices, @choices
        o.original_test_line_stream = ::File.open @original_test_path
        o.to_line_stream
      end

      def self.operation_
        Home_::Operations_::Synchronize
      end
    end

    # ==

    class SimpleChunker___

      class << self
        alias_method :begin, :new
        undef_method :new
      end  # >>

      def initialize
        Shared___[].each_pair do |sym, x|
          instance_variable_set sym, x
        end
      end

      attr_writer(
        :example_opening_regex,
      )

      def finish
        freeze
      end

      def for big_s
        dup.___for big_s
      end

      def ___for s
        @_scn = ::StringScanner.new s
        self
      end

      def to_box

        bx = Common_::Box.new

        index = -1
        begin

          s = @_scn.scan @nonblank_lines_rx_
          md = @example_opening_regex.match s

          d = @_scn.skip @blank_lines_rx_

          index += 1
          key = md[ 1 ]

          if d
            o = Item__.new( key, index, d, s )
            bx.add o.description_string, o
            redo
          end
          o = Item__.new( key, index, 0, s )
          bx.add o.description_string, o
          @_scn.eos? or Home_._SANITY
          break
        end while nil

        bx
      end

      def skip_a_postseparated_chunk
        skip_some_nonblank_lines
        skip_some_blank_lines
      end

      def skip_some_nonblank_lines
        s = @_scn.scan @nonblank_lines_rx_
        s || fail
      end

      def skip_some_blank_lines
        d = @_scn.skip @blank_lines_rx_
        d.zero? && fail
      end

      Shared___ = Lazy_.call do
        h = {}
        h[ :@blank_lines_rx_ ] = %r(\n+)
        h[ :@nonblank_lines_rx_ ] = %r((?:^[ ]*[^ \n].*\n)+)
        h
      end
    end

    # ==

    Item__ = ::Struct.new :description_string, :index, :num_trailing_lines, :full_string

    # ==

    Here_ = self
  end
end
# #history: #rename-and-rewrite of a quickie-specific node
