module Skylab::CSS_Convert

  module Grammars

    module Directive__
      S = Home_::Parser_::Models::Sexpesque
    end
  end

  class Directive__::Parser < Home_::Parser_::Common_Base
  private

    def produce_parser_class

      dir_o = DIR_N11N__.against_path @out_dir_head do | * _i_a, & ev_p |

        self._COVER_ME  # used to use @delegate
      end

      if dir_o
        __produce_parser_class_via_generate_grammar_dir dir_o
      else
        dir_o
      end
    end

    def __produce_parser_class_via_generate_grammar_dir ggd

      _relpath_root = Directive__::Parser.dir_path

      o = start_treetop_require_

      o.add_parser_enhancer_module Home_::Parser_::Parser_Instance_Methods

      # o.force_overwrite!

      o.add_treetop_grammar 'common.treetop'
      o.add_treetop_grammar 'directive.treetop'
      o.input_path_head_for_relative_paths = _relpath_root
      o.output_path_head_for_relative_paths = ggd.to_path
      o.execute
    end

    _ = Home_.lib_.system.filesystem :Existent_Directory

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
