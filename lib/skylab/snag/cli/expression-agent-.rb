module Skylab::Snag

  class CLI

    EXPRESSION_AGENT_ = class Expression_Agent_

      # subclass Snag_::Lib_::CLI[]::Pen::Minimal for less DIY

      alias_method :calculate, :instance_exec

      h = { strong: 1, green: 32 }.freeze
      o = -> * i_a do
        fmt = "\e[#{ i_a.map { |i| h.fetch i } * ';' }m"
        -> x do
          "#{ fmt }#{ x }\e[0m"
        end
      end

      define_method :em, o[ :strong, :green ]

      define_method :h2, o[ :green ]

      def ick x
        Snag_::Lib_::Strange[ x ]
      end

      define_method :kbd, o[ :green ]

      def param i
        "#{ i }"
      end

      def pth x
        Snag_::Lib_::Pretty_path[ x.to_path ]
      end

      def val x
        em x
      end

      # ~

      def and_ a
        And__[ a ]
      end

      And__ = -> do
        p = -> a do
          p = Snag_::Lib_::EN_mini[]::Oxford_comma_.curry[ ', ', ' and ' ]
          p[ a ]
        end
        -> a { p[ a ] }
      end.call

      def s x
        Snag_::Lib_::EN_mini[]::FUN.s[ x ]
      end

      new
    end
  end
end
