module Skylab::Basic

  module Regexp

    class << self

      def build_component_model & build
        Require_component_model_support___[]
        Component_Model[ & build ]
      end

      def marshal_load s, & oes_p
        Marshal_load__[ s, & oes_p ]
      end

      def options_via_regexp rx
        Options__.new rx.options
      end

      def string_via_grep_string s, & oes_p

        Regexp_::Actors__::Platform_string_via_grep_string[ s, & oes_p ]
      end

      def stream_of_matches s, rx

        # 'strscn' is great for what it does, but it doesn't do this

        p = -> do
          md = rx.match s
          if md
            _, end_ = md.offset 0
            p = -> do

              md = rx.match s, end_
              if md
                _, end_ = md.offset 0
                md
              else
                p = EMPTY_P_
                NIL_
              end
            end
            md
          else
            p = EMPTY_P_
            NIL_
          end
        end

        Callback_.stream do
          p[]
        end
      end
    end  # >>

    class Marshal_load__

      Callback_::Actor.call self, :properties,

        :string

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

        @on_event_selectively.call :error, :not_parsable_as_regex do

          Callback_::Event.inline_not_OK_with :not_parsable_as_regex,
            :string, @string
        end
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

        ev = Callback_::Event.wrap.exception @e

        @on_event_selectively.call :error, ev.terminal_channel_i do
          ev
        end
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

    Require_component_model_support___ = Callback_.memoize do

      class Component_Model

        # if you are only using this as a "matcher", your matcher need only
        # respond to `=~` (and need not be a regexp). if you see `mapper`,
        # etc.

        class << self
          def [] & build
            o = new
            build[ o ]
            if o.mapper
              o.__init_as_mapper
            else
              o.__init_as_matcher
            end
            o
          end
          private :new
        end  # >>

        def initialize
          @mapper = nil
        end

        attr_writer(
          :mapper,
          :matcher,
          :on_failure_to_match,
        )

        attr_reader(
          :mapper,
        )

        def __init_as_matcher

          @_p = -> arg_st, & x_p do

            x = arg_st.gets_one

            if @matcher =~ x
              ACS_[]::Value_Wrapper[ x ]
            else
              @on_failure_to_match[ :_reserved_, & x_p ]
            end
          end

          NIL_
        end

        def __init_as_mapper

          @_p = -> arg_st, & x_p do

            x = arg_st.gets_one
            md = @matcher.match x

            if md
              _x = @mapper[ * md.captures ]
              ACS_[]::Value_Wrapper[ _x ]
            else
              @on_failure_to_match[ :_reserved_, & x_p ]
            end
          end
          NIL_
        end

        def [] arg_st, & x_p
          @_p[ arg_st, & x_p ]
        end
      end

      NIL_
    end

    Regexp_ = self
  end
end
