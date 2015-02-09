module Skylab::TanMan::TestSupport

  class Parse

    # insulate testing from production with this testing-only adapter that
    # encapsulates the ancillary session of our business parser to work with
    # the smaller ad-hoc grammars we have in testing.

    def initialize oes_p
      @bx = TanMan_::Callback_::Box.new
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
      @bx.set :parse_method, :parse_file
      @bx.set :parse_argument, path
      _work
    end

    def parse_string s
      @bx.set :parse_method, :parse_string
      @bx.set :parse_argument, s
      _work
    end

    def _work
      Customized_Session__.new( @bx, & @on_event_selectively ).produce_parse_tree
    end

    class Customized_Session__ < TanMan_::Models_::DotFile::Sessions__::Produce_Parse_Tree

      def initialize bx, & oes_p
        @_h = bx.h_
        super
      end

      def produce_parser_class  # override the parent's version of this :#hook-out for [ttt]

        TanMan_::Input_Adapters_::Treetop::Load.new( :_xxx_,
          -> o do
            o.generated_grammar_dir @_h.fetch :generated_grammar_dir_path
            o.root_for_relative_paths @_h.fetch :root_for_relative_paths_for_load
            o.treetop_grammar @_h.fetch :grammar_path
          end,
          -> o do

            # for clarity, we may below duplicate some of parent's wiring logic

            o.on_info do | ev |
              @on_event_selectively.call :info, ev.terminal_channel_i do
                ev
              end
            end
            o.on_error do | ev |
              @on_event_selectively.call :error, ev.terminal_channel_i do
                ev
              end
            end
          end ).invoke  # a transient load session is created that produces (hopefully) a parser class

      end
    end
  end
end
