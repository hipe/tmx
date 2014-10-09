module Skylab::CssConvert

  CSS = ::Module.new

  class CSS::Parser

    include CssConvert::Parser::InstanceMethods

                                  # maybe [#sl-115] clean up below

    ENTITY_NOUN_STEM = 'css file'
    PARSER_PARSERS = {
      Flex2Treetop: { path: '../flex2treetop/core.rb' },  # when you fall down,
      Yacc2Treetop: { path: '../../../bin/yacc2treetop' } # i will catch you
    }
    PARSERS = [
      { on:       true,
        use:      :Flex2Treetop,
        read:     'css2.1.flex',
        write:    'css-2.1-tokens.treetop.rb',
        grammar:  'Skylab::CssParser::Tokens'
      },
      { on:       true,
        use:      :Yacc2Treetop,
        read:     'css2.1.yacc3wc',
        write:    'css-2.1-document.treetop.rb',
        grammar:  'Skylab::CssPrser::CssDocument'
      },
      { on:       nil,
        use:      :Flex2Treetop,
        read:     'tokens.flex',
        write:    'css-tokensXXX.treetop.rb',
        grammar:  'Skylab::CssParser::TokensXXX'
      },
      { on:       nil,
        use:      :Yacc2Treetop,
        read:     'selectors.yaccw3c',
        write:    'css-selectors.treetob.rb',
        grammar:  'Skylab::CssParser::Selectors'
      }
    ]

    class ParserMeta < ::Struct.new :on, :use, :read, :write, :grammar,
                                                     :indir, :outdir
      def initialize actual_h
        actual_h.each { |k, v| send "#{k}=", v }
      end
      def inpath
        indir.join(read)
      end
      def outpath
        outdir.join(write)
      end
    end

    def build_big_parser
      actuals = actual_parameters
      f = actuals[:force_overwrite]
      v = actuals[:verbose]
      indir  = CssConvert.dir_pathname.join 'css/parser'
      outdir = CssConvert.dir_pathname.join actuals[:tmpdir_relative]
      PARSERS.each do |parser|
        parser[:on] or next
        parser = ParserMeta.new(parser.merge(indir: indir, outdir: outdir))
        if (f || v || ! parser.outpath.exist?)
          build_parser_parser(parser) or return
        end
      end
      nil
    end

    alias_method :build_parser, :build_big_parser

    def build_parser_parser parser
      api_mod = parser_parser_module(parser.use)::API
      request = {
        force: actual_parameters[:force_overwrite],
        grammar: parser.grammar,
        inpath: parser.inpath.to_s,
        outpath: parser.outpath.to_s
      }
      _result = api_mod.translate request
      _result
    end

    def parser_parser_module const
      unless parser_parser_module_module.const_defined?(const)
        tail = PARSER_PARSERS[const][:path]
        path = CssConvert.dir_pathname.join tail
        load path.to_s
      end
      parser_parser_module_module.const_get const, false
    end

    PARSER_PARSER_MODULE_MODULE = ::Skylab

    def parser_parser_module_module
      PARSER_PARSER_MODULE_MODULE
    end

    def receive_parser_error_message s
      error s
    end
  end
end
