module Skylab::CssConvert
  module CSS end
  class CSS::Parser
    include CssConvert::Parser::InstanceMethods
    ENTITY_NOUN_STEM = 'css file'
    PARSER_PARSERS = {
      FlexToTreetop: { path: '../../../bin/flex2treetop' },
      YaccToTreetop: { path: '../../../bin/yacc2treetop' }
    }
    PARSERS = [
      { on:       true,
        use:      :FlexToTreetop,
        read:     'css2.1.flex',
        write:    'css-2.1-tokens.treetop.rb',
        grammar:  'Skylab::CssParser::Tokens'
      },
      { on:       true,
        use:      :YaccToTreetop,
        read:     'css2.1.yacc3wc',
        write:    'css-2.1-document.treetop.rb',
        grammar:  'Skylab::CssParser::CssDocument'
      },
      { on:       nil,
        use:      :FlexToTreetop,
        read:     'tokens.flex',
        write:    'css-tokensXXX.treetop.rb',
        grammar:  'Skylab::CssParser::TokensXXX'
      },
      { on:       nil,
        use:      :YaccToTreetop,
        read:     'selectors.yaccw3c',
        write:    'css-selectors.treetob.rb',
        grammar:  'Skylab::CssParser::Selectors'
      }
    ]
    class ParserMeta < Struct.new(:on, :use, :read, :write, :grammar,
                                                     :indir, :outdir)
      def initialize params
        params.each { |k, v| send("#{k}=", v) }
      end
      def inpath
        indir.join(read)
      end
      def outpath
        outdir.join(write)
      end
    end
    def build_big_parser
      f = params[:force_overwrite]
      v = params[:verbose]
      indir  = MyPathname.new(CssConvert.dir.join('css-parser'))
      outdir = MyPathname.new(CssConvert.dir.join(params[:tmpdir_relative]))
      PARSERS.each do |parser|
        parser[:on] or next
        parser = ParserMeta.new(parser.merge(indir: indir, outdir: outdir))
        if (f || v || ! parser.outpath.exist?)
          build_parser_parser(parser) or return
        end
      end
    end
    alias_method :build_parser, :build_big_parser
    def build_parser_parser parser
      _klass = parser_parser_module(parser.use)::Translator
      require 'debugger' ; debugger ; puts "TOLERANCE IS HAPPY"
      _translator = _klass.new(params)
      _result = _translator.translate(parser.inpath, parser.outpath,
        force:   params[:force_overwrite],
        grammar: params[:gramamr]
      )
      _result
    end
    def parser_parser_module const
      unless parser_parser_module_module.const_defined?(const)
        _tail = PARSER_PARSERS[const][:path]
        _path = CssConvert.dir.join(_tail)
        load _path.to_s
      end
      parser_parser_module_module.const_get(const)
    end
    PARSER_PARSER_MODULE_MODULE = ::Skylab
    def parser_parser_module_module
      PARSER_PARSER_MODULE_MODULE
    end
  end
end
