module Skylab::CssConvert
  module Grammar
    module Directives
      S = CssConvert::TreetopTools::Sexpesque
    end
  end
  class DirectivesParser
    include CssConvert::Parser::InstanceMethods
    ENTITY_NOUN_STEM = 'directives file'
    def parser_class
      @parser_class ||= begin
        CssConvert::TreetopTools.load_parser_class do |o|
          o.request_runtime = request_runtime
          o.root_dir CssConvert.dir
          o.generated_grammar_dir params.tmpdir_relative
          o.treetop_grammar 'directives-parser/common.treetop'
          o.treetop_grammar 'directives-parser/directives.treetop'
          o.force_overwrite! if params.force_overwrite?
          o.enhance_parser_with CssConvert::TreetopTools::ParserExtlib
        end
      end
    end
  end
end
