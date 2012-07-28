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
      { :on      => true,
        :use     => :FlexToTreetop,
        :read    => 'css2.1.flex',
        :write   => 'css-2.1-tokens.treetop.rb',
        :grammar => 'Hipe::CssParser::Tokens'
      },
      { :on      => true,
        :use     => :YaccToTreetop,
        :read    => 'css2.1.yacc3wc',
        :write   => 'css-2.1-document.treetop.rb',
        :grammar => 'Hipe::CssParser::CssDocument'
      },
      { :on      => nil,
        :use     => :FlexToTreetop,
        :read    => 'tokens.flex',
        :write   => 'css-tokensXXX.treetop.rb',
        :grammar => 'Hipe::CssParser::TokensXXX'
      },
      { :on      => nil,
        :use     => :YaccToTreetop,
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
        p.key?(:on) and ! p[:on] and next
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
