module Skylab::Task::TestSupport

  module Magnetics

    module Item_Reference_Via_Token_Stream

      def self.[] tcc
        tcc.send :define_singleton_method, :given_parse, Given_parse_method___
        tcc.include self
      end

      Given_parse_method___ = -> &p do

        yes = true ; x = nil
        define_method :item_parse_tree_state do
          if yes
            yes = false
            instance_exec( & p )
            x = _ITvTS_build_state
          end
          x
        end
      end

      # -

        # -- the DSL

        def input_words * s_a
          input_word_array s_a
        end

        def input_word_array s_a
          @_ITvTS_input_token_stream = Simple_Token_Stream_.new s_a ; nil
        end

        def input_word_drama * s_a
          @_ITvTS_input_token_stream = Dramatic_Token_Stream___.new s_a ; nil
        end

        # -- ways to fail

        def item_parse_fails
          _state = item_parse_tree_state
          _state.ok && fail
        end

        def want_failure_message_lines_ & y_p

          _actual_s_a = _ITvTS_failure_event.express_into_under []

          actual_stream = Common_::Stream.via_nonsparse_array _actual_s_a

          _y = ::Enumerator::Yielder.new do |line_content|

            expected_line = "#{ line_content }#{ Home_::NEWLINE_ }"

            actual_line = actual_stream.gets

            if actual_line
              if actual_line != expected_line
                expect( actual_line ).to eql expected_line
              end
            else
              fail "had no more lines but expected #{ actual_line.inspect }"
            end
          end

          y_p[ _y ]

          s = actual_stream.gets
          if s
            fail "unexpected extra line: #{ s.inspect }"
          end
        end

        def want_unexpected_token_cateogory_ sym

          _ev = _ITvTS_failure_event
          _ev.unexpected_token_category == sym || fail
        end

        def want_expected_token_categories_ * exp_sym_a

          _ev = _ITvTS_failure_event
          act_sym_a = _ev.expected_token_categories

          missing = exp_sym_a - act_sym_a
          if missing.length.nonzero?
            fail "missing: (#{ missing * ', ' })"
          end

          extra = act_sym_a - exp_sym_a
          if extra.length.nonzero?
            fail "extra: (#{ extra * ', ' })"
          end
        end

        def _ITvTS_failure_event
          item_parse_tree_state.failure_event
        end

        # -- ways to succeed

        def item_parse_tree
          state = item_parse_tree_state
          if state.ok
            state.parse_tree
          else
            fail
          end
        end

        # -- support

        def item_parse_tree_state  # NOTE this is the fallback one-off form

          @___ITvTS_did_once ||= ( this_is_the_first_time = true )

          if this_is_the_first_time
            x = _ITvTS_build_state
            @__ITvTS_one_off_state = x
            x
          else
            @__ITvTS_one_off_state
          end
        end

        def _ITvTS_build_state

          _st = remove_instance_variable :@_ITvTS_input_token_stream

          i_a = nil ; ev_p = nil

          x = magnetics_module_::ItemReference_via_TokenStream.call _st do |*a, &p|
            i_a = a ; ev_p = p ; :_unreliable_from_ITvTS_test_
          end

          if x
            i_a && Home_._SANITY
            Success_State___[ x ].freeze

          elsif i_a
            i_a[1] == :expression && Home_._ALTER_ME
            memoized_ev_p = Lazy_.call do
              ev_p[]
            end
            Failure_State___.new i_a do
              memoized_ev_p[]
            end

          else
            PresumablyUpstreamFailure_State___.instance
          end
        end

      # -

      # ==

      class PresumablyUpstreamFailure_State___

        class << self
          def instance
            @___ ||= new
          end
          private :new
        end  # >>

        def initialize
          freeze
        end

        def is_presumably_upstream_failure
          true
        end
      end

      class Failure_State___

        def initialize i_a, & memoized_ev_p
          @_memoized_event_proc = memoized_ev_p
          @channel = i_a
        end

        def failure_event
          @_memoized_event_proc[]
        end

        attr_reader(
          :channel,
        )

        def ok
          false
        end
      end

      Success_State___ = ::Struct.new :parse_tree do
        def ok
          true
        end
      end

      # ==

      class Dramatic_Token_Stream___

        def initialize a
          @ok = true
          @_st = Common_::Stream.via_nonsparse_array a
          _advance
        end

        def gets
          send @_m
        end

        def __word
          s = @_st.gets
          _advance
          s
        end

        def __fail
          @ok = false
          _advance
          Home_::UNABLE_
        end

        def _advance
          @_m = METHOD__.fetch @_st.gets ; nil
        end

        METHOD__ = {
          word: :__word,
          fail: :__fail,
        }

        attr_reader(
          :ok,
        )
      end

      # ==
    end
  end
end
