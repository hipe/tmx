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
      fo = @c[:force_overwrite]
      parsers = "#{ROOT}/#{@c[:tmpdir_relative]}"
      toks = "#{parsers}/css-tokens.treetop.rb"
      sels = "#{parsers}/css-selectors.treetop.rb"
      (fo or ! File.exist?(toks)) and (build_tokens_parser(toks) or return)
      puts "put selectors yacc grammar thing here"
    end
    def build_tokens_parser path
      ftt = flex_to_treetop::FlexToTreetop.new
      ftt.execution_context.err = @c.err
      ftt.execution_context[:grammar] = "Hipe::CssParser::Tokens"
      ftt.translate(ROOT + '/css-parser/tokens.flex', path)
      true
    end
    def flex_to_treetop
      ::Hipe.const_defined?(:FlexToTreetop) or
        load(ROOT + '/../../bin/flex-to-treetop') # kind of awful but meh
      ::Hipe::FlexToTreetop
    end
  end
  #
  #
  # module CssParsing
  #   here = File.dirname(__FILE__)+'/css-parsing'
  #   S = ::Hipe::CssConvert::CssParsing::DifferentSexpie
  #   require "#{here}/node-classes.rb"
  #   Grammars.load "#{here}/common"
  #   Grammars.load "#{here}/xml-subset"
  #   Grammars.load "#{here}/css-file"
  # end
  # class CssParser < CssParsing::CssFileParser
  #
  # end
end
