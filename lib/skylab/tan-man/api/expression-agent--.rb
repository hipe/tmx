module Skylab::TanMan

  module API

    EXPRESSION_AGENT__ =
    class Expression_Agent__  # follows [#fa-052]:#the-semantic-markup-guidelines

      def initialize k
      end

      alias_method :calculate, :instance_exec

      def and_ a
        _NLP_actor.and a
      end

      def code s
        "'#{ s }'"
      end

      def hdr s
        s
      end

      def ick x
        val x
      end

      def kbd s
        s
      end

      def lbl x
        par x
      end

      def or_ a
        _NLP_actor.or_ a
      end

      def par x
        if ! ( x.respond_to? :ascii_only? or x.respond_to? :id2name )
          x = x.name.as_lowercase_with_underscores_symbol
        end
        "'#{ x }'"
      end

      def pth s
        pn = ::Pathname.new "#{ s }"
        if '.' == pn.dirname.to_s
          s
        else
          pn.basename.to_path
        end
      end

      def s count_x, lexeme_i=:s
        count_x.respond_to?( :abs ) or count_x = count_x.length
        if :s == lexeme_i
          's' if 1 != count_x
        else
          lexeme_i
        end
      end

      def val x
        x.inspect
      end

      def _NLP_actor
        @NLP_actor ||= NLP_actor__[].new
      end

      NLP_actor__ = -> do
        p = -> do
          class NLP_Actor___
            i_a = [ :and_, :or_, :s ]
            TanMan_::Lib_::EN_fun[][ self, :public, i_a ]
          end
          p = -> { NLP_Actor___ }
          NLP_Actor___
        end
        -> { p[] }
      end.call

      self
    end.new :_no_kernel_
  end
end
