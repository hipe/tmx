module Skylab::CssConvert
  class CssParser
    # include CssConvert::SubClient::InstanceMethods
    def initialize(_)
      $stderr.puts("CssParser is skipping")

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
        :grammar => 'Skylab::CssParser::Tokens'
      },
      { :on      => true,
        :use     => :YaccToTreetop,
        :read    => 'css2.1.yacc3wc',
        :write   => 'css-2.1-document.treetop.rb',
        :grammar => 'Skylab::CssParser::CssDocument'
      },
      { :on      => nil,
        :use     => :FlexToTreetop,
        :read    => 'tokens.flex',
        :write   => 'css-tokensXXX.treetop.rb',
        :grammar => 'Skylab::CssParser::TokensXXX'
      },
      { :on      => nil,
        :use     => :YaccToTreetop,
        :read    => 'selectors.yaccw3c',
        :write   => 'css-selectors.treetob.rb',
        :grammar => 'Skylab::CssParser::Selectors'
      }
    ]
    def build_big_parser
      f = params[:force_overwrite]
      v = params[:verbose]
      parsers = params[:tmpdir_relative].dup
      Parsers.each do |p|
        p.key?(:on) and ! p[:on] and next
        output = "#{parsers}/#{p[:write]}"
        if (f || v || ! File.exist?(output))
          build_parser_parser(p, output) or return
        end
      end
    end
    def build_parser_parser p, output
      parser_parser_module(p[:use])::Translator.new(params).
        translate("#{ROOT}/css-parser/#{p[:read]}", output,
          force:   params[:force_overwrite],
          grammar: params[:gramamr]
        )
    end
    def parser_parser_module mod
      ::Skylab.const_defined?(mod) or
        load("#{ROOT}/#{ParserParsers[mod][:path]}")
      ::Skylab.const_get(mod)
    end
  end
end
