module Skylab::Basic

  module Regexp

    class << self

      def build_component_model & build
        Require_component_model_support___[]
        Component_Model[ & build ]
      end

      def marshal_load s, & p
        Marshal_load___[ s, & p ]
      end

      def options_via_regexp rx
        Options__.new rx.options
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

        Common_.stream do
          p[]
        end
      end
    end  # >>

    class Marshal_load___ < Common_::Monadic

      def initialize s, & p
        @listener = p
        @string = s
      end

      def execute
        @_rx_options_d = 0
        @md = RX_RX___.match @string
        if @md
          __via_md
        else
          ___when_no_md
        end
      end

      RX_RX___ = %r(\A/(?<source>.*)/(?<rx_options>[imx]+)?\z)m

      def __when_no_md

        @listener.call :error, :not_parsable_as_regex do

          Common_::Event.inline_not_OK_with :not_parsable_as_regex,
            :string, @string
        end
        UNABLE_
      end

      def __via_md

        @source, @_rx_options = @md.captures

        if @_rx_options
          ___parse_rx_options
        end

        __via_ivars
      end

      def ___parse_rx_options  # CANNOT FAIL - look at your regex

        @_rx_options.length.times do |d|
          @_rx_options_d |= RX_OPTIONS___.fetch @_rx_options.getbyte d
        end
        NIL_
      end

      RX_OPTIONS___ = {
        'i'.getbyte( 0 ) => ::Regexp::IGNORECASE,
        'm'.getbyte( 0 ) => ::Regexp::MULTILINE,
        'x'.getbyte( 0 ) => ::Regexp::EXTENDED
      }

      def __via_ivars
        ::Regexp.new @source, @_rx_options_d
      rescue ::RegexpError => @e
        ___when_rx_e
      end

      def ___when_rx_e

        ev = Common_::Event::Via_exception.via :exception, @e

        @listener.call :error, ev.terminal_channel_symbol do
          ev
        end

        UNABLE_
      end
    end

    class Options__

      def initialize d
        @is_ignorecase = ( ::Regexp::IGNORECASE & d ).nonzero?
        @is_multiline = ( ::Regexp::MULTILINE & d ).nonzero?
        @is_extended = ( ::Regexp::EXTENDED & d ).nonzero?
        freeze
      end

      def to_string
        buffer = ""
        buffer << "i" if @is_ignorecase
        buffer << "m" if @is_multiline
        buffer << "x" if @is_extended
        buffer if buffer.length.nonzero?
      end

      attr_reader :is_ignorecase, :is_multiline, :is_extended
    end

    Require_component_model_support___ = Common_.memoize do

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
              Common_::KnownKnown[ x ]
            else
              _failed( & x_p )
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
              Common_::KnownKnown[ _x ]
            else
              _failed( & x_p )
            end
          end
          NIL_
        end

        def _failed & p_p
          _p = p_p[ nil ]
          @on_failure_to_match[ :_reserved_, & _p ]
          UNABLE_
        end

        def [] arg_st, & x_p
          @_p[ arg_st, & x_p ]
        end
      end

      NIL_
    end

    Here_ = self
  end
end
