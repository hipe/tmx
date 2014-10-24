module Skylab::TanMan::TestSupport

  class Parse < TanMan_::Models_::DotFile::Actors__::Produce_document_via_parse::Parse__


    # customize an ancillary component of our main business parser to work
    # with our smaller ad-hoc grammars.


    def initialize
      @grammar_path_a = []
      super
    end

    def produce_parser_class  # we don't memoize the result here. parent does
      build_parser_class
    end

    def add_grammar_path s
      @grammar_path_a.push s ; nil
    end

    def add_grammar_paths_to_load o
      @grammar_path_a.each do |s|
        o.treetop_grammar s
      end ; nil
    end

    def root_for_relative_paths_for_load
      @root_for_relative_paths_for_load
    end

    def set_root_for_relative_paths_for_load x
      @root_for_relative_paths_for_load = x ; nil
    end
  end
end
