module Skylab::Basic

  module String

  module Via_Mixed__  # :[#019] #:+[#hu-002] summarization (trivial)

    # like sending `inspect` to a mixed value; but with some ad-hoc heuristics
    # for avoiding (but not preventing) outputting strings that meet or exceed
    # a certain length, and with certain cosmetic styling for some shapes.

    class << self

      def call_via_arglist a
        case a.length
        when 0
          self
        when 1
          Via_x___[ a.first ]
        else
          Proc__[ * a ]
        end
      end

      def curry
        Proc__.curry
      end

      def to_proc
        Proc__
      end
    end

    Proc__ = -> length_d, x do

      _use_inspect = if x

        is_probably_string = x.respond_to? :ascii_only?

        if is_probably_string
          length_d >= x.length
        else
          x.respond_to?( :divmod ) ||  # is probably ::Numeric
            true == x ||
              x.respond_to?( :included_modules )  #  is probaby ::Module
        end
      else
        true  # is `nil` or `false`
      end

      if _use_inspect

        x.inspect

      elsif is_probably_string

        _s = String_.ellipsify x, A_REASONABLY_SHORT_LENGTH_FOR_A_STRING

        "\"#{ _s }\""

      elsif x.respond_to? :id2name  # is probably ::Symbol

        s = x.id2name
        if SIMPLE_RX___ =~ s
          "'#{ s }'"
        else
          "'#{ s.inspect[ 1 .. -2 ] }'"  # pretend we are JS, meh
        end
      else

        "< a #{ x.class } >"
      end
    end

    A_REASONABLY_SHORT_LENGTH_FOR_A_STRING = 10

    SIMPLE_RX___ = /\A[[:alnum:] _]+\z/

    Via_x___ = Proc__.curry[ A_REASONABLY_SHORT_LENGTH_FOR_A_STRING ]

  end
  end
end
