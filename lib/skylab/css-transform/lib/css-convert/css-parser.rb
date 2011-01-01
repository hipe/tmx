module Hipe::CssConvert
  require ROOT + '/treetop-tools'
  class CssParser
    def initialize(ctx)
      @c = ctx
    end
    def parse_file path
      whole_string = File.read(path)
      @parser ||= build_treetop_parser
    end
  private
    def build_treetop_parser
      f = @c[:force_overwrite]
      v = @c[:verbose]
      parsers = "#{ROOT}/#{@c[:tmpdir_relative]}"
      docu = "#{parsers}/css2.1.yacc3wc"
      toks = "#{parsers}/css-tokens.treetop.rb"
      sels = "#{parsers}/css-selectors.treetop.rb"
      f || v || !File.exist?(toks) and build_tokens_parser(toks)   || return
      f || v || !File.exist?(sels) and build_selector_parser(sels) || return
    end
    def build_tokens_parser path
      flex_to_treetop::Translator.new(@c.merge(:root => ROOT)).
        translate(ROOT + '/css-parser/tokens.flex', path,
          :force   => @c[:force_overwrite],
          :grammar => "Hipe::CssParser::Tokens"
        )
    end
    def build_selector_parser path
      yacc_to_treetop::Translator.new(@c.merge(:root => ROOT)).
        translate(ROOT + '/css-parser/selectors.yaccw3c', path,
          :force   => @c[:force_overwrite],
          :grammar => "Hipe::CssParser::Selectors"
        )
    end
    def flex_to_treetop
      ::Hipe.const_defined?(:FlexToTreetop) or
        load(ROOT + '/../../bin/flex-to-treetop') # kind of awful but meh
      ::Hipe::FlexToTreetop
    end
    def yacc_to_treetop
      ::Hipe.const_defined?(:YaccToTreetop) or
        load(ROOT + '/../../bin/yacc-to-treetop') # kind of awful but meh
      ::Hipe::YaccToTreetop
    end
  end
end
