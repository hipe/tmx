module Skylab::TanMan::TestSupport

  class Parse

    # insulate testing from production with this testing-only adapter that
    # encapsulates the ancillary session of our business parser to work with
    # the smaller ad-hoc grammars we have in testing.

    def initialize oes_p
      @bx = Home_::Common_::Box.new
      @on_event_selectively = oes_p
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
      @bx.set :buid, Home_::Brazen_.byte_upstream_identifier.via_path( path )
      _work
    end

    def parse_string s
      @bx.set :buid, Home_::Brazen_.byte_upstream_identifier.via_string( s )
      _work
    end

    def _work
      Produce_parse_tree_custom___.new( @bx, & @on_event_selectively ).execute
    end

    class Produce_parse_tree_custom___ < Home_::Models_::DotFile::Sessions__::Produce_Parse_Tree

      def initialize bx, & oes_p
        @_h = bx.h_
        @on_event_selectively = oes_p
        @byte_upstream_identifier = @_h.fetch :buid
        nil
      end

      def produce_parser_class_  # override the parent's version of this :#hook-out for [ttt]

        # create a load session that produces (hopefully) a parser class

        o = Home_::Input_Adapters_::Treetop::Sessions::Require.new(
          & @on_event_selectively )

        o.input_path_head_for_relative_paths =
          @_h.fetch :root_for_relative_paths_for_load

        o.output_path_head_for_relative_paths =
          @_h.fetch :generated_grammar_dir_path

        o.add_treetop_grammar @_h.fetch :grammar_path

        o.execute
      end
    end
  end
end
