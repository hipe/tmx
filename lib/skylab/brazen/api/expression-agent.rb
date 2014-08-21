module Skylab::Brazen

  module API

    EXPRESSION_AGENT = class Expression_Agent___

      # specifically we created this expression agent to render expressions
      # in "black & white" when we are rendering their messages
      # to be used in exception messages.

      alias_method :calculate, :instance_exec

      def s x
        x.respond_to?( :length ) and x = x.length
        's' if 1 != x
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

      def pth x
        x
      end

      self
    end.new

    _ES_ = class Exit_Statii__
      h = {
        is_negative: 7,
        missing_required_props: 8,
        file_not_found: 9
      }.freeze
      define_method :[], & h.method( :[] )
      define_method :fetch, & h.method( :fetch )
      self
    end.new

    define_singleton_method :exit_statii do _ES_ end
  end
end
