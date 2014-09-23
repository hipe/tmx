module Skylab::Brazen

  module API

    EXPRESSION_AGENT = class Expression_Agent___

      # specifically we created this expression agent to render expressions
      # in "black & white" when we are rendering their messages
      # to be used in exception messages.

      alias_method :calculate, :instance_exec

      def and_ x
        context.and_ x
      end

      def code s
        ick s
      end

      def hdr string
        "#{ string }:"
      end

      def highlight string
        "** #{ string } **"
      end

      def ick x
        "'#{ x }'"
      end

      def par x
        _string = x.respond_to?( :ascii_only? ) ? x : x.name.as_slug
        "'#{ _string }'"
      end

      def pth x
        x
      end

      def s count_x, lexeme_i=:s
        context.s count_x, lexeme_i
      end

      def val s
        s.inspect
      end

      def context
        @context ||= Lang_Ctx__[].new
      end

      Lang_Ctx__ = -> do
        p = -> do
          x = class Lang_Ctx___
            i_a = [ :and_, :s ]
            Brazen_::Lib_::EN_fun[][ self, :private, i_a ]
            public( * i_a )
            self
          end
          p = -> { x } ; x
        end
        -> { p[] }
      end.call

      self
    end.new

    _ES_ = class Exit_Statii__
      h = {
        generic_error: ( d = 5 ),
        error_as_specificed: ( d += 1 ),
        missing_required_properties: ( d += 1 ),
        invalid_property_value: ( d += 1 ),
        extra_properties:  ( d += 1 ),
        resource_not_found: ( d += 1 ),
        resource_exists: ( d += 1 )
      }.freeze
      define_method :[], & h.method( :[] )
      define_method :fetch, & h.method( :fetch )
      self
    end.new

    define_singleton_method :exit_statii do _ES_ end


    class << self
      def debug_IO
        @debug_IO ||= Lib_::Headless__[]::System::IO.some_stderr_IO
      end
    end
  end
end
