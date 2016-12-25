class Skylab::Task

  module Magnetics

    class Models::TokenStream  # :[#010].

      # (yes, a tokenizer seems like a different kind of performer
      # (a session maybe) rather than a model, but bear with us..)

      class << self

        alias_method :begin, :new
        undef_method :new
      end  # >>

      def add_head_anchored_skip_regex rx
        ( @head_anchored_skip_regexes ||= [] ).push rx ; nil
      end

      attr_writer(
        :end_token,
        :end_expression_is_required,
        :word_regex,
        :separator_regex,
      )

      def initialize
        @end_token = nil
        @end_expression_is_required = true  # if present
        @head_anchored_skip_regexes = nil
      end

      def finish

        if @end_token
          @_end_rx = /#{ ::Regexp.escape @end_token }/
          @_uses_end_expression = true
        else
          @_uses_end_expression = false
        end

        freeze
      end

      Home_.lib_.string_scanner

      def token_stream_via_string big_string, & oes_p
        dup.__become_stream_for big_string, & oes_p  # #[#sl-023] dup-and-mutate
      end

      # == (was)

        def __become_stream_for big_string, & oes_p

          @on_event_selectively = oes_p

          @_scn = ::StringScanner.new big_string
          @ok = true

          once = false
          begin
            s = @_scn.scan @word_regex
            if s
              @__first_token = s
              @_m = :__first_token
              x = self
              break
            end
            once && break
            once = true

            if @head_anchored_skip_regexes
              found = @head_anchored_skip_regexes.index do |rx|
                @_scn.skip rx
              end
            end
            found && break
            x = __when_expecting_separator_or_end
            break
          end while nil
          x
        end

        def __first_token
          @_m = :__subsequent
          remove_instance_variable :@__first_token
        end

        def to_a  # #testing-only
          a = [] ; x = nil
          a.push x while x = gets
          a
        end

        def gets
          send @_m
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

          if @_scn.eos?

            # if you've reached the end of the input then whether or not you
            # have succeeded is dependent upon whether or not you require an
            # end expression.

            if @_uses_end_expression && @end_expression_is_required
              _expected_end_expression
            else
              @_succeeded = true
            end
          elsif @_uses_end_expression

            # if you haven't reached the end of the input and you use an
            # end expression, then (whether or not it's required) the end
            # expression is what is required of the input head here.

            if @_scn.skip @_end_rx
              if @_scn.eos?
                @_succeeded = true
              else
                _expected_end_of_input
              end
            else
              _expected_end_expression
            end
          else

            # if you haven't reached the end of the input and you don't
            # use an end expression, then (since you expect the end):

            _expected_end_of_input
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

        def _expected_end_of_input
          _expecting do
            _end_desc
          end
        end

        def _expected_end_expression  # assume not at end
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

          @_emitted = true
          @_succeeded = false

          remove_instance_variable :@_m
          @ok = UNABLE_

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

        attr_reader(
          :ok,
        )

      # == (was)

      PEEK_LENGTH__ = 10

    end
  end
end
# #pending-rename: publicize (for [cm])
