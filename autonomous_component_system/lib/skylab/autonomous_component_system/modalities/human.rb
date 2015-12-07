module Skylab::Autonomous_Component_System
  # ->
    module Modalities::Human

      # mostly contextualize expressions of events

      # -- Event via X

      Event_via_context = -> x do  # [my]

        Parse_context___[ x ].event
      end

      Event_via_is_not = -> desc_sym, & y_p do

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

      Event_via_expression = -> asc, desc_sym, & y_p do

        _ev = Callback_::Event.inline_with(
          desc_sym,
          :ok, nil,
        ) do | y, o |
          calculate y, & y_p
        end
        _ev
      end

      # -- Support

      class Parse_context___

        # take a linked list of the form NAME [ NAME [..]] EVENT and result
        # in a dup of the event that expresses the name chain somehow..

        class << self
          def _call x
            new( x ).execute
          end
          alias_method :[], :_call
          alias_method :call, :_call
        end  # >>

        def initialize linked_list
          @linked_list = linked_list
        end

        def execute
          ___init_stack_and_event
          __map_event
        end

        def ___init_stack_and_event

          _LL = remove_instance_variable :@linked_list
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

          @_event = curr
          @stack = stack ; nil
        end

        def __map_event

          # we are exploring the benefits & disadvantanges of these
          # different ways of expressing context ..

          ev = remove_instance_variable :@_event

          _ev_ = if ev.has_member :prefixed_conjunctive_phrase_context_proc
            Map_event_by_prefixing_conjunctive_phrase___[ @stack, ev ]
          else
            Map_event_by_that_one_member___[ @stack, ev ]
          end

          @event = _ev_

          freeze
        end

        attr_reader(
          :event,
          :stack,
        )
      end

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
          :prefixed_conjunctive_phrase_context_proc, _p,
          :prefixed_conjunctive_phrase_context_stack, stack,
        ]

        if false == ev.ok
          _sym_a = stack.map( & :as_lowercase_with_underscores_symbol )
          these.push :invite_to_action, _sym_a
        end

        ev.new_with( * these )
      end

      Map_event_by_that_one_member___ = -> stack, ev do

        _old_LL = ev.context_as_linked_list_of_names  # discard - asssume is tail

        _new_LL = Home_.lib_.basic::List.linked_list_via_array stack

        ev.new_with :context_as_linked_list_of_names, _new_LL
      end

      Write_contextual_prefix_into__ = -> phrases, expag, stack, ok_ness do

        # (redunds with [#002]:GEC)

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
