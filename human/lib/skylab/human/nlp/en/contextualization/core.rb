module Skylab::Human

  class NLP::EN::Contextualization  # IS (see) :[#043].

    def initialize
      @_solver = nil
    end

    # -- (usually) as prototype

    def express_selection_stack
      Here_::Express_Selection_Stack___.new self
    end

    def express_trilean
      Here_::Express_Trilean___.new self
    end

    # -- (usually) for instance

    def initialize_copy _

      # NOTE - this trick safeguards the dups from writing to the data
      # of the parent, but note that *counterintuitively* any subsequent
      # edits that the parent object make to the solver will be reflected
      # in the child dups.

      if @_solver.is_writable_
        @_solver = @_solver.to_read_only__
      end
    end

    NODES__ = {
      channel: nil,
      expression_proc: nil,  # subset of `event_proc`
      initial_phrase_conjunction: :nilable,
      inflected_verb: :nilable,
      line_downstream: nil,
      selection_stack: nil,
      trilean: :nilable,
      verb_lemma: :nilable,
      verb_subject: :nilable,
      verb_object: :nilable,
    }

    attr_accessor(  # the below are plain old options, not used as nodes
      :express_selection_stack_item,
      :express_subject_association,
      :expression_agent,
      :event,
      :event_proc,
      :line_stream,
      :line_yielder,
      :subject_association,
    )

    ivar = ::Hash.new { |h,k| h[k] = :"@#{ k }" }

    NODES__.each_pair do |k, i|

      attr_reader k  # [#]"B" explains how this can be a knkn or a value

      if :nilable == i
        # then because nil is a valid value, this.
        _p = -> x do
          instance_variable_set ivar[ k ], Callback_::Known_Known[ x ]
          x
        end
      else
        _p = -> x do
          instance_variable_set ivar[ k ], x
        end
      end

      define_method "#{ k }=", & _p
    end

    # -- different forms expression

    def express_emission i_a, & ev_p

      if @_solver
        self._COVER_ME
      end
      Here_::Express_Emission___[ self ]
      @channel = i_a
      @event_proc = ev_p
      express_into @line_yielder
      UNRELIABLE_
    end

    def express_into y  # mutates c15n for now

      _so = _bound_solver
      st = _so.solve_for_ :line_downstream
      begin
        s = st.gets
        s or break
        y << s
        redo
      end while nil
      y
    end

    def build_string

      as = Here_::Phrase_Assembly.new
      so = _bound_solver

      _ic = so.solve_for_ :initial_phrase_conjunction
      _vs = so.solve_for_ :verb_subject
      _iv = so.solve_for_ :inflected_verb
      _vo = so.solve_for_ :verb_object

      as.add_any_string _ic.value_x
      as.add_any_string _vs.value_x
      as.add_any_string _iv.value_x
      as.add_any_string _vo.value_x

      as.build_string_
    end

    def _bound_solver
      @_solver.bound_to_knowns__ self
    end

    # -- for sub-clients

    def when_ when_x, can_produce_x, & by_p

      @_solver ||= Here_::Solver___.new_for__ NODES__.keys
      @_solver.add_entry__ when_x, can_produce_x, & by_p
      NIL_
    end

    def selection_stack_as_linked_list__

      ss = @selection_stack
      if ss.respond_to? :each_with_index
        Home_.lib_.basic::List::Linked.via_array ss
      else
        ss
      end
    end

    class Streamer_

      attr_writer(
        :on_first,
        :on_subsequent,
      )

      def to_stream_around st

        p = -> do
          s = st.gets
          if s
            p = -> do
              s_ = st.gets
              if s_
                @on_subsequent[ s_ ]
              end
            end
            @on_first[ s ]
          end
        end

        Callback_.stream do
          p[]
        end
      end
    end

    class Newline_Adder_

      def initialize

        @y = ::Enumerator::Yielder.new do |s|
          if NL_RX___ =~ s
            s = "#{ s }#{ NEWLINE_ }"
          end
          @_a.push s
        end
        @_a = []
      end

      attr_reader :y

      def to_line_stream
        Callback_::Stream.via_nonsparse_array @_a
      end

      NL_RX___ = /(?<!\n)\z/  # ..
    end

    class Transition_ < Callback_::Actor::Monadic

      def initialize kns
        @knowns_ = kns
      end
    end

    Here_ = self
    Lazy_ = Callback_::Lazy
    NOTHING_ = nil
    NEWLINE_ = "\n"
    UNRELIABLE_ = :_UNRELIABLE_from_hu_c15n_
  end
end
