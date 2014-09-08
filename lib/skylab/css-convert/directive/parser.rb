module Skylab::CssConvert

  module Grammars

    module Directive
      S = CssConvert::Parser::Sexpesque
    end
  end

  class Directive::Parser

    include CssConvert::Parser::InstanceMethods

  private

    def load_parser_class
      load_parser_class_with do |o|
        o.enhance_parser_with(
          CssConvert::Parser::Extlib::InstanceMethods )
        actual_parameters.force_overwrite? and o.force_overwrite!
        o.generated_grammar_dir "#{ actual_parameters.tmpdir_relative }"
        o.root_for_relative_paths CssConvert.dir_pathname
        o.treetop_grammar 'directive/parser/common.treetop'
        o.treetop_grammar 'directive/parser/directive.treetop'
      end
    end

    def entity_noun_stem
      ENS__
    end
    ENS__ = 'directives file'.freeze

    def receieve_parser_error_message s
      send_error_messgae s
    end
  end
end
