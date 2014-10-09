module Skylab::Headless

  module CLI::Pen  # [#084]

    FUN = Headless_::Lib_::FUN_module[].new
    module FUN

      o = definer

      o[ :stylize ] = -> str, * style_a do
        Stylify[ style_a, str ]
      end
      #
      Stylify = -> style_a, str do
        "\e[#{ style_a.map { |s| CODE_H__[s] }.compact * ';' }m#{ str }\e[0m"
      end
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
        str.to_s.dup.gsub! SIMPLE_STYLE_RX, EMPTY_STRING_
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

      # the below methods follow [#fa-052]-#the-semantic-markup-guidelines

      def em s
        stylize s, :strong, :green
      end

      def h2 s
        stylize s, :green
      end

      def ick mixed
        %|"#{ mixed }"|
      end

      def kbd s
        stylize s, :green
      end

      def omg x
        x = x.to_s
        x = x.inspect unless x.index TERM_SEPARATOR_STRING_
        stylize x, :strong, :red
      end

      def par x
        kbd "<#{ x.to_s.gsub '_', '-' }>"
      end

      def param i
        i
      end

      # def `val` - how may votes? (1: sg) [#051]

      module_exec( & Define_stylize_methods__ )

    end

    class Minimal
      include InstanceMethods
    end

    SERVICES = MINIMAL = Minimal.new

  end
end
