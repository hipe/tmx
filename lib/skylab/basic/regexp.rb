module Skylab::Basic

  module Regexp

    class << self
      def marshal_load s, & error_proc
        Marshal_load__[ s, error_proc ]
      end

      def options_via_regexp rx
        Options__.new rx.options
      end
    end

    class Marshal_load__

      Callback_::Actor.call self, :properties,

        :string, :on_error

      def execute
        @modifiers_d = 0
        @md = RX_RX__.match @string
        if @md
          via_md
        else
          when_no_md
        end
      end

      RX_RX__ = %r(\A/(?<source>.*)/(?<modifiers>[imx]+)?\z)m

      def when_no_md
        _ev = Basic_::Lib_::Event[].inline_not_OK_with :not_parsable_as_regex,
          :string, @string
        @on_error[ _ev ]
      end

      def via_md
        @source, @modifiers = @md.captures
        @modifiers and parse_modifiers
        via_ivars
      end

      def parse_modifiers  # CANNOT FAIL - look at your regex
        @modifiers.length.times do |d|
          @modifiers_d |= MODIFIERS__.fetch @modifiers.getbyte d
        end ; nil
      end

      MODIFIERS__ = {
        'i'.getbyte( 0 ) => ::Regexp::IGNORECASE,
        'm'.getbyte( 0 ) => ::Regexp::MULTILINE,
        'x'.getbyte( 0 ) => ::Regexp::EXTENDED
      }

      def via_ivars
        ::Regexp.new @source, @modifiers_d
      rescue ::RegexpError => @e
        when_rx_e
      end

      def when_rx_e
        @on_error[ Basic_::Lib_::Event[].wrap.exception @e ]
      end

      def value_is_known
        ! @rx.nil?
      end
    end

    class Options__

      def initialize d
        @is_ignorecase = ( ::Regexp::IGNORECASE & d ).nonzero?
        @is_multiline = ( ::Regexp::MULTILINE & d ).nonzero?
        @is_extended = ( ::Regexp::EXTENDED & d ).nonzero?
        freeze
      end

      attr_reader :is_ignorecase, :is_multiline, :is_extended
    end
  end
end
