module Skylab::MetaHell

  module Strange__  # :[#050] #:+[#it-002] summarization (trivial)

    class << self
      def via_argument_list a
        case a.length
        when 0
          self
        when 1
          Proc_[ a.first ]
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
      if case x
      when ::NilClass, ::FalseClass, ::TrueClass, ::Numeric, ::Module
        true
      else
        x.respond_to? :ascii_only? and x.length < length_d
      end then
        x.inspect
      elsif x.respond_to? :id2name
        "'#{ x }'"
      else
        "< a #{ x.class } >"
      end
    end

    A_REASONABLY_SHORT_LENGTH_FOR_A_STRING = 10

    Proc_ = Proc__.curry[ A_REASONABLY_SHORT_LENGTH_FOR_A_STRING ]

  end
end
