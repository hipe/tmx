module Hipe::CssConvert
  require ROOT + '/treetop-tools'
  class CssParser
    def initialize(ctx)
      @c = ctx
    end
    def parse_file path
      whole_string = File.read(path)
      @parser ||= build_big_parser
    end
  private
    ParserParsers = {
      :FlexToTreetop => {
        :path => '../../bin/flex-to-treetop'
      },
      :YaccToTreetop => {
        :path => '../../bin/yacc-to-treetop'
      }
    }
    Parsers = [
      { :use     => :FlexToTreetop,
        :read    => 'tokens.flex',
        :write   => 'css-tokens.treetop.rb',
        :grammar => 'Hipe::CssParser::Tokens'
      },
      { :use     => :YaccToTreetop,
        :read    => 'selectors.yaccw3c',
        :write   => 'css-selectors.treetob.rb',
        :grammar => 'Hipe::CssParser::Selectors'
      }
    ]
    def build_big_parser
      f = @c[:force_overwrite]
      v = @c[:verbose]
      parsers = "#{ROOT}/#{@c[:tmpdir_relative]}"
      Parsers.each do |p|
        p.key?(:on) and ! p[:on] and continue
        output = "#{parsers}/#{p[:write]}"
        if (f || v || ! File.exist?(output))
          build_parser_parser(p, output) or return
        end
      end
    end
    def build_parser_parser p, output
      parser_parser_module(p[:use])::Translator.new(@c.merge(:root => ROOT)).
        translate("#{ROOT}/css-parser/#{p[:read]}", output,
          :force   => @c[:force_overwrite],
          :grammar => p[:grammar]
        )
    end
    def parser_parser_module mod
      ::Hipe.const_defined?(mod) or
        load("#{ROOT}/#{ParserParsers[mod][:path]}")
      ::Hipe.const_get(mod)
    end
  end
end
