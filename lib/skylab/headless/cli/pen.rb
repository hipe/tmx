module Skylab::Headless

  module CLI::Pen  # [#084]

    module Bundles
      module Expressive_agent
        p = -> _ do
          include Expressive_agent
        end ; define_singleton_method :to_proc do p end
      private
        def say &p
          expression_agent.calculate( & p )
        end
      end
    end

    FUN = MetaHell::FUN::Module.new
    module FUN

      o = definer

      o[ :stylize ] = -> str, * style_a do
        Stylify[ style_a, str ]
      end
      #
      Stylify = -> style_a, str do
        "\e[#{ style_a.map { |s| CODE_H__[s] }.compact * ';' }m#{ str }\e[0m"
      end
      o[ :curriable_stylize ] = Stylify
      #
      CODE_H__ = ::Hash[ [ [ :strong, 1 ], [ :reverse, 7 ] ].
        concat [ :red, :green, :yellow, :blue, :purple, :cyan, :white ].
          each.with_index.map { |v, i| [ v, i + 31 ] } ]
            # ascii-table.com/ansi-escape-sequences.php  (red = 31, etc)

      o[ :unstyle ] = -> str do                # the safer alternative, for when
        Unstyle_styled[ str ] || str           # you don't care whether it was
      end                                      # stylzed in the first place
      #
      Unstyle_styled = -> str do  # nil IFF str.to_s is not already styled
        str.to_s.dup.gsub! SIMPLE_STYLE_RX, ''
      end
      o[ :unstyle_styled ] = Unstyle_styled

      # see also CLI::FUN for extended support for working with styles
    end

    SIMPLE_STYLE_RX = /\e  \[  \d+  (?: ; \d+ )*  m  /x

    Define_stylize_methods__ = -> do

      define_method :stylize, & FUN.stylize

      define_method :unstyle, & FUN.unstyle

      define_method :unstyle_styled, & FUN::Unstyle_styled

    end
    #
    CODE_NAME_A = FUN::CODE_H__.keys.freeze
    #
    module Methods  # API-public access to what amounts to instance-method-
      # versions of a subset of the FUN functions - if for e.g. you want
      # `stylize` or `unstyle` and you don't want to pollute your namespace
      # or coupling with all of the view-y-style names of Pen::I_M. note,
      # however, that this is still low-level: avoid calling `stylize` in
      # application code when you can instead use existing, modality-portable
      # styles.

      module_exec( & Define_stylize_methods__ )

      ( CODE_NAME_A - [ :strong ] ).each do |c|   # away at [#pl-013]
        define_method c do |s| stylize s, c end
        define_method c.to_s.upcase do |s| stylize s, :strong, c end
      end
    end

    module InstanceMethods

      include Headless::Pen::InstanceMethods   # (see)

      def em s                                 # style a header
        stylize s, :strong, :green             # (`hdr` may delegate to this)
      end

      def h2 s                                 # style a smaller header
        stylize s, :green
      end

      def ick mixed                            # style an invalid value
        %|"#{ mixed }"|
      end

      def kbd s                                # style as e.g kbd input
        stylize s, :green                      # or code
      end

      def omg x                                # style an error with
        x = x.to_s                             #  excessive & exuberant emphasis
        x = x.inspect unless x.index ' '       # (opposite human_escape)
        stylize x, :strong, :red               # may be overkill
      end

      def par x                                # simplified variant of [#036]
        kbd "<#{ x.to_s.gsub '_', '-' }>"
      end

      # def `val` - how may votes? (1: sg) [#hl-051]

      module_exec( & Define_stylize_methods__ )

    end

    class Minimal
      include InstanceMethods
    end

    SERVICES = MINIMAL = Minimal.new

  end
end
