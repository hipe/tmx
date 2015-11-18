module Skylab::Autonomous_Component_System

  # ->

    module Modalities::Human

      # mostly contextualize expressions of events

      class Event_via_context

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
          @_stack = stack ; nil
        end

        def __map_event

          # we are exploring the benefits & disadvantanges of these
          # different ways of expressing context ..

          if @_event.has_member :prefixed_conjunctive_phrase_context_proc
            Map_event_by_prefixing_conjunctive_phrase___[ @_stack, @_event ]
          else
            Map_event_by_that_one_member___[ @_stack, @_event ]
          end
        end
      end

      Map_event_by_prefixing_conjunctive_phrase___ = -> stack, ev do

        orig_p = ev.prefixed_conjunctive_phrase_context_proc

        _p = -> ev_ do

          phrases = []

          if orig_p
            orig_s = calculate ev_, & orig_p
          end

          Write_contextual_prefix_into__[ phrases, self, stack, ev_.ok ]

          if orig_s
            phrases.push orig_s
          end

          phrases * SPACE_
        end

        ev.new_with :prefixed_conjunctive_phrase_context_proc, _p
      end

      Map_event_by_that_one_member___ = -> stack, ev do

        _old_LL = ev.context_as_linked_list_of_names  # discard - asssume is tail

        _new_LL = Home_.lib_.basic::List.linked_list_via_array stack

        ev.new_with :context_as_linked_list_of_names, _new_LL
      end

      Contextualize_lines = -> y, expag, asc, ok_ness, & lines_p do

        p = -> line do

          _phrases = Write_contextual_prefix_into__[ [], expag, stack, ok_ness ]

          p = -> line_ do
            self._COVER_ME_more_lines
          end
        end

        _yielder = ::Enumerator::Yielder.new do | line |
          p[ line ]
        end

        expag.calculate _yielder, & lines_p
        y
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
