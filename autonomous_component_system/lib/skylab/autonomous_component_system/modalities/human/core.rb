module Skylab::Autonomous_Component_System
  # ->
    module Modalities::Human

      # mostly contextualize expressions of events :[#020].

      # -- Event via X

      Event_via_context = -> x do  # [my]

        Parse_context___[ x ].event
      end

      Event_via_is_not = -> desc_sym, & y_p do  # [mt] 1x only

        _ev = Callback_::Event.inline_with(

          desc_sym,
          :prefixed_conjunctive_phrase_context_proc, nil,
          :prefixed_conjunctive_phrase_context_stack, nil,
          :invite_to_action, nil,
          :error_category, :argument_error,
          :ok, false,

        ) do | y, o |

          prefix_p = o.prefixed_conjunctive_phrase_context_proc

          if prefix_p

            p = -> s do

              p = -> s_ do
                self._COVER_ME_subsequent_line_very_easy
              end

              # "cannot frob widget because widget cannot be blank"

              s_a = calculate [], o, & prefix_p

              _nf = o.prefixed_conjunctive_phrase_context_stack.fetch( -2 )
              s_a.push _nf.as_human

              s_a.push s

              y << s_a.join( SPACE_ )
            end

            _use_y = ::Enumerator::Yielder.new do | s |
              p[ s ]
            end
          else
            _use_y = y
          end

          calculate _use_y, & y_p
        end

        _ev
      end

      Event_via_expression = -> desc_sym, event_category, & x_p do  # #[#021]

        _ok = :error == event_category ? false : nil

        _ev = Callback_::Event.inline_with(

          desc_sym,
          :description_proc, x_p,
          :prefixed_conjunctive_phrase_context_proc, nil,
          :prefixed_conjunctive_phrase_context_stack, nil,
          # there is NO `invite_to_action` here - we don't know what action
          :ok, _ok,

        ) do | y, o |

          p = -> line do  # with any first line:

            s_a = calculate [], o, & o.prefixed_conjunctive_phrase_context_proc
            s_a.push line
            y << s_a.join( SPACE_ )

            p = -> line_ do  # with any subsequent line:
              y << line_
            end
            y
          end

          _y = ::Enumerator::Yielder.new do | line |
            p[ line ]
          end

          calculate _y, & o.description_proc
        end

        _ev
      end

      # -- Support

      class Traverse_context < Callback_::Actor::Monadic

        # traverse a linked list of the form NAME [ NAME [..]] VALUE
        # to build a tuple of the form (( array of NAME ), ( VALUE )).
        # let this be the one place where we upgrade symbols to names.

        def initialize linked_list
          @_linked_list = linked_list
        end

        def execute

          _LL = remove_instance_variable :@_linked_list
          st = _LL.to_element_stream_assuming_nonsparse

          stack = []
          prev = st.gets
          curr = st.gets

          begin

            _nf = if prev.respond_to? :id2name
              Callback_::Name.via_variegated_symbol prev
            else
              prev.name  # sanity/clarity
            end
            stack.push _nf

            nxt = st.gets
            nxt or break
            prev = curr
            curr = nxt
            redo
          end while nil

          @end_value = curr
          @stack = stack
          freeze
        end

        attr_reader( :end_value, :stack )
      end

      module Map_event_against_stack ; class << self  # [mt]1x

        # we are exploring the benefits & disadvantanges of these
        # different ways of expressing context ..

        def _call ev, stack

          if ev.has_member A__
            Map_event_by_prefixing_conjunctive_phrase___[ stack, ev ]

          elsif ev.has_member B__
            Map_event_by_that_one_member___[ stack, ev ]

          else
            raise ___say_etc( ev )
          end
        end

        def ___say_etc ev
          "must have member `#{ A__ }` or `#{ B__ }` - #{ ev.class }"
        end

        alias_method :[], :_call ; alias_method :call, :_call

      end ; end

      A__ = :prefixed_conjunctive_phrase_context_proc
      B__ = :context_as_linked_list_of_names

      Map_event_by_prefixing_conjunctive_phrase___ = -> stack, ev do

        orig_p = ev.prefixed_conjunctive_phrase_context_proc

        _p = -> s_y, ev_ do

          Write_contextual_prefix_into__[ s_y, self, stack, ev_.ok ]

          if orig_p
            calculate s_y, ev_, & orig_p
          end

          s_y
        end

        these = [
          A__, _p,
          :prefixed_conjunctive_phrase_context_stack, stack,
        ]

        if false == ev.ok and ev.has_member :invite_to_action
          _sym_a = stack.map( & :as_lowercase_with_underscores_symbol )
          these.push :invite_to_action, _sym_a
        end

        ev.new_with( * these )
      end

      Map_event_by_that_one_member___ = -> stack, ev do

        _old_LL = ev.context_as_linked_list_of_names  # discard - asssume is tail

        _new_LL = Home_.lib_.basic::List.linked_list_via_array stack

        ev.new_with B__, _new_LL
      end

      Write_contextual_prefix_into__ = -> phrases, expag, stack, ok_ness do

        # (:[#007]. redunds with [#br-002]:GEC (see).)

        s_a = stack.map do | nf |
          nf.as_human
        end

        verb_s = s_a.pop  # hope

        if ok_ness

          self._WRITE_ME_easy_fun

        else

          if s_a.length.nonzero?
            obj_s = s_a.join SPACE_  # inflection ..
          end

          if ok_ness.nil?
            obj_s and _ = " #{ obj_s }"
            expag.calculate do
              phrases.push "while #{ progressive_verb verb_s }#{ _ },"
            end
          else
            phrases.push "couldn't #{ verb_s }"
            obj_s and phrases.push obj_s
            phrases.push "because"
          end
        end

        phrases
      end
    end
  # -
end
# #pending-rename: branch down
