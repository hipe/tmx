module Skylab::Brazen

  module API

    EXPRESSION_AGENT = class Expression_Agent___

      # specifically we created this expression agent to render expressions
      # in "black & white" when we are rendering their messages
      # to be used in exception messages.

      alias_method :calculate, :instance_exec

      def s x
        x.respond_to?( :length ) and x = x.length
        's' if x.nonzero?
      end

      def code string
        "'#{ string }'"
      end

      def hdr string
        "#{ string }:"
      end

      def highlight string
        "** #{ string } **"
      end

      def ick x
        code x
      end

      def par x
        _string = x.respond_to?( :ascii_only? ) ? x : x.name.as_slug
        "'#{ _string }'"
      end

      self
    end.new

    h = {
      missing_required_props: 6,
    }.freeze

    define_singleton_method :any_error_code_via_terminal_channel_i, &
      h.method( :[] )

    define_singleton_method :some_error_code_via_terminal_channel_i, &
      h.method( :fetch )
  end
end
