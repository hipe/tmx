module Skylab::CSS_Convert

  module Grammars

    module Directive__
      S = Home_::Parser_::Sexpesque
    end
  end


  class Directive__::Parser < Home_::Parser_::Common_Base
  private

    def produce_parser_class

      dir_o = DIR_N11N__.against_path @actuals.tmpdir_absolute do | *, & ev_p |
        @delegate.receive_event ev_p[]
        UNABLE_
      end

      if dir_o
        produce_parser_class_via_generate_grammar_dir dir_o
      else
        dir_o
      end
    end

    def produce_parser_class_via_generate_grammar_dir ggd

      _relpath_root = Directive__::Parser.dir_pathname

      load_parser_class_with__ do |o|
        o.enhance_parser_with Home_::Parser_::Extlib::InstanceMethods
        @actuals.force_overwrite? and o.force_overwrite!
        o.treetop_grammar 'common.treetop'
        o.treetop_grammar 'directive.treetop'
        o.root_for_relative_paths _relpath_root
        o.generated_grammar_dir ggd.to_path
      end

    end

    _ = LIB_.system.filesystem :Existent_Directory

    DIR_N11N__ = _.new_with(
      :create_if_not_exist,
      :max_mkdirs, 1,
    )

    def entity_noun_stem
      ENS__
    end
    ENS__ = 'directives file'.freeze

    def receieve_parser_error_message s
      send_error_messgae s
    end
  end
end
