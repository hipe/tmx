module Skylab::CSS_Convert

  module Grammars

    module Directive__
      S = CSSC_::Parser_::Sexpesque
    end
  end

  class Directive__::Parser

    include CSSC_::Parser_::InstanceMethods

  private

    def produce_parser_class
      load_parser_class_with do |o|
        o.enhance_parser_with CSSC_::Parser_::Extlib::InstanceMethods
        actual_parameters.force_overwrite? and o.force_overwrite!
        o.root_for_relative_paths CSSC_.dir_pathname
        o.generated_grammar_dir "#{ actual_parameters.tmpdir_relative }"
        head_pn = Directive__::Parser.dir_pathname
        o.treetop_grammar head_pn.join( 'common.treetop' ).to_path
        o.treetop_grammar head_pn.join( 'directive.treetop' ).to_path
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
