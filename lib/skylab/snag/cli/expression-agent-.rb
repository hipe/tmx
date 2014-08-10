module Skylab::Snag

  class CLI

    EXPRESSION_AGENT_ = class Expression_Agent_

      alias_method :calculate, :instance_exec

      h = { strong: 1, green: 32 }.freeze
      o = -> * i_a do
        fmt = "\e[#{ i_a.map { |i| h.fetch i } * ';' }m"
        -> x do
          "#{ fmt }#{ x }\e[0m"
        end
      end

      define_method :em, o[ :strong, :green ]

      def ick x
        Snag_::Lib_::Strange[ x ]
      end

      def val x
        em x
      end

      new
    end
  end
end
