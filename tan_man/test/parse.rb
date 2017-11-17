module Skylab::TanMan::TestSupport

  class Parse

    # insulate testing from production with this testing-only adapter that
    # encapsulates the ancillary session of our business parser to work with
    # the smaller ad-hoc grammars we have in testing.

    def initialize p
      @bx = Home_::Common_::Box.new
      @listener = p
      yield self
    end

    # ~ edit phase

    def generated_grammar_dir_path x
      @bx.add :generated_grammar_dir_path, x
      nil
    end

    def root_for_relative_paths_for_load x
      @bx.add :root_for_relative_paths_for_load, x
      nil
    end

    def grammar_path x  # in theory we could support a list of grammars
      @bx.add :grammar_path, x
      nil
    end

    # ~ work phase

    def parse_file path
      @bx.set :buid, Byte_upstream_reference_[].via_path( path )
      _work
    end

    def parse_string s
      @bx.set :buid, Byte_upstream_reference_[].via_string( s )
      _work
    end

    def _work
      Produce_parse_tree_custom___.new( @bx, & @listener ).execute
    end

    class Produce_parse_tree_custom___ < Home_::Models_::DotFile::ParseTree_via_ByteUpstreamReference

      def initialize bx, & p
        @_h = bx.h_
        @listener = p
        @byte_upstream_reference = @_h.fetch :buid
        nil
      end

      def produce_parser_class_  # override the parent's version of this :#hook-out for [ttt]

        # create a load session that produces (hopefully) a parser class

        Home_::InputAdapters_::Treetop::RequireGrammars_via_Paths.call_by do |o|

          o.input_path_head_for_relative_paths =
            @_h.fetch :root_for_relative_paths_for_load

          o.output_path_head_for_relative_paths =
            @_h.fetch :generated_grammar_dir_path

          o.add_treetop_grammar @_h.fetch :grammar_path

          o.listener = @listener
        end
      end

      # ==
      # ==
    end
  end
end
