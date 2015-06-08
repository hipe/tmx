module Skylab::Snag

  module Models_::Message

    class << self

      def normalize_value__ x, & x_p  # valid values are true-ish

        _trio = Callback_::Knownness.new_known x
        trio = N11n_instance___[].normalize_argument _trio, & x_p
        trio and trio.value_x
      end
    end  # >>

    N11n_instance___ = Callback_.memoize do

        # we build this policy here but it could be anywhere. we memoize
        # a singleton "formal set" here but in the future this might be
        # built more dynamically, for example as a product of arguments
        # or the environment

        Normalization___.new_with(

          :must_be_trueish,
          :no_blanks,
          :no_escaped_newlines,
          :no_newlines
          # character_limit Models::Manifest.line_width - Models::Manifest.header_width
        )
    end

    class Normalization___

      Callback_::Actor.methodic self

      def initialize & edit_p

        @p_a = []
        instance_exec( & edit_p )
        @p_a.freeze
        freeze
      end

    private

      def character_limit=

        d = gets_one_polymorphic_value

        @p_a.push -> arg, & oes_p do
          s = arg.value_x
          if d < s.length
            _express arg, :character_limit_exceeded, oes_p do
              "messages cannot be longer than #{ d } characters #{
                } (your message was #{ s.length } chars"
            end
          else
            arg
          end
        end
        KEEP_PARSING_
      end

      def must_be_trueish=

        @p_a.push -> arg, & oes_p do
          x = arg.value_x
          if x
            arg
          else
            _express arg, :not_a_string, oes_p do
              "need string, had #{ ick x }"
            end
          end
        end
        KEEP_PARSING_
      end

      def no_blanks=

        _black_regex BLANK_RX___ do
          "message was blank."
        end
      end
      BLANK_RX___ = /\A[[:space:]]*\z/


      def no_escaped_newlines=

        _black_regex XNL_RX___ do
          "message cannot contain escaped newlines"
        end
      end
      XNL_RX___ = /\\n/


      def no_newlines=

        _black_regex NL_RX___ do
          "message cannot contain newlines"
        end
      end
      NL_RX___ = /\n/

    public

      def normalize_argument arg, & oes_p

        @p_a.each do | p |

          arg = p[ arg, & oes_p ]
          arg or break
        end
        arg
      end

    private

      def _black_regex rx, & str_p

        @p_a.push -> arg, & oes_p do

          if rx =~ arg.value_x
            _express arg, :string_has_extraordinary_features, oes_p do

              "#{ instance_exec( & str_p ) }: #{ ick arg.value_x }"
            end
          else
            arg
          end
        end
        KEEP_PARSING_
      end

      def _express arg, term_chan_sym, oes_p, & str_p

        oes_p.call :error, :uninterpretable, term_chan_sym do

          Callback_::Event.inline_not_OK_with(

            term_chan_sym,
            :x, arg.value_x,
            :string_proc, str_p,
            :error_category, :argument_error

          ) do | y, o |
            y << instance_exec( & o.string_proc )
          end
        end
        UNABLE_
      end
    end

    module Expression_Adapters
      EN = nil
    end

    Actions = THE_EMPTY_MODULE_
  end
end
