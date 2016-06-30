class Skylab::Task

  module Magnetics

    class Models_::TokenStream

      # (yes, a tokenizer seems like a different kind of performer
      # (a session maybe) rather than a model, but bear with us..)

      class << self

        alias_method :begin, :new
        undef_method :new
      end  # >>

      attr_writer(
        :end_token,
        :word_regex,
        :separator_regex,
      )

      def initialize
        @end_token = nil
      end

      def finish

        @_stream_prototype = Stream_Builder___.__prototype_for(
          remove_instance_variable( :@word_regex ),
          remove_instance_variable( :@end_token ),
          remove_instance_variable( :@separator_regex ),
        )

        freeze
      end

      def token_stream_via_string big_string, & oes_p
        @_stream_prototype.__build_stream_for big_string, & oes_p
      end

      # ==

      Home_.lib_.string_scanner

      class Stream_Builder___

        class << self

          def __prototype_for w_rx, e_tok, s_rx
            new( w_rx, e_tok, s_rx ).freeze
          end
          private :new
        end  # >>

        def initialize w_rx, e_tok, s_rx

          if e_tok
            @_end_rx = /#{ ::Regexp.escape e_tok }/
            @end_token = e_tok
            @_uses_end_expression = true
          else
            @_uses_end_expression = false
          end

          @word_regex = w_rx
          @separator_regex = s_rx
        end

        def __build_stream_for big_string, & oes_p
          dup.__become_stream_for big_string, & oes_p  # #[#sl-023] dup-and-mutate
        end

        def __become_stream_for big_string, & oes_p

          @on_event_selectively = oes_p

          @_scn = ::StringScanner.new big_string
          @_m = :__first
          Common_.stream do
            send @_m
          end
        end

        def __first
          s = @_scn.scan @word_regex
          if s
            @_m = :__subsequent
            s
          else
            __when_expecting_word_or_end
          end
        end

        def __subsequent

          _d = @_scn.skip @separator_regex
          if _d
            s = @_scn.scan @word_regex
            if s
              s
            else
              __expected_word
            end
          else
            __when_expecting_separator_or_end
          end
        end

        # --

        def __when_expecting_word_or_end  # assume did not just parse word

          _parse_end
          if @_succeeded
            NOTHING_
          elsif @_emitted
            UNABLE_
          else
            __expected_word_or_end
          end
        end

        def __when_expecting_separator_or_end  # assume did not just parse sep

          _parse_end
          if @_succeeded
            NOTHING_
          elsif @_emitted
            UNABLE_
          else
            __expected_separator_or_end
          end
        end

        def _parse_end  # set @_succeed (and if not succeeded set @_emitted)

          if @_uses_end_expression
            if @_scn.skip @_end_rx
              if @_scn.eos?
                @_succeeded = true
              else
                __expected_end_expression
                @_succeeded = false
                @_emitted = true
              end
            else
              @_succeeded = false
              @_emitted = false
            end
          elsif @_scn.eos?
            @_succeeded = true
          else
            @_succeeded = false
            @_emitted = false
          end
          NIL_
        end

        # --

        def __expected_word_or_end
          _expecting do
            "#{ _word_desc } or #{ _end_desc }"
          end
        end

        def __expected_separator_or_end
          _expecting do
            "#{ _sep_desc } or #{ _end_desc }"
          end
        end

        def __expected_word  # assume did not just parse word
          _expecting do
            _word_desc
          end
        end

        def __expected_end_expression  # assume not at end
          _expecting do
            _end_desc
          end
        end

        def _sep_desc
          "separator (/#{ @separator_regex.source }/)"
        end

        def _word_desc
          "word (/#{ @word_regex.source }/)"
        end

        def _end_desc
          if @_uses_end_expression
            "end expression (#{ @end_token.inspect })"
          else
            "end of input"
          end
        end

        # --

        def _expecting & exp_desc_p

          remove_instance_variable :@_m

          express_into_under = -> y, _expag=nil do

            _prepositional_phrase = if @_scn.eos?
              "at end of input"
            else

              # (will probably bork on certain multibyte strings)

              _excerpt = if @_scn.rest_size > PEEK_LENGTH__
                "#{ @_scn.peek( PEEK_LENGTH__ ) }[..]"
              else
                @_scn.rest
              end

              "at #{ _excerpt.inspect }"
            end

            _message = "expecting #{ exp_desc_p[] } #{ _prepositional_phrase }"

            y << _message
          end

          oes_p = @on_event_selectively
          if oes_p
            oes_p.call :error, :expression, :unexpected_input do |y|
              express_into_under[ y, self ]
            end
            UNABLE_
          else
            raise express_into_under[ "" ]
          end
        end
      end

      PEEK_LENGTH__ = 10
    end
  end
end
