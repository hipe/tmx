module Skylab::CssConvert
  module Grammars
    module Directive
      S = CssConvert::Parser::Sexpesque
    end
  end
  class Directive::Parser
    include CssConvert::Parser::InstanceMethods
    ENTITY_NOUN_STEM = 'directives file'
  protected
    def load_parser_class
      super do |o|
        o.enhance_parser_with(
          CssConvert::Parser::Extlib::InstanceMethods )
        o.force_overwrite! if params.force_overwrite?
        o.generated_grammar_dir "#{params.tmpdir_relative}"
        o.root_for_relative_paths CssConvert.dir_pathname
        o.treetop_grammar 'directive/parser/common.treetop'
        o.treetop_grammar 'directive/parser/directive.treetop'
      end
    end
  end
end
