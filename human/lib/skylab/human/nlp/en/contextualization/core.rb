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
      expression_agent: nil,
      event_proc: nil,
      event: nil,
      initial_phrase_conjunction: :nilable,
      inflected_verb: :nilable,
      line_downstream: nil,
      line_stream: nil,
      line_yielder: nil,
      selection_stack: nil,
      trilean: :nilable,
      verb_lemma: :nilable,
      verb_subject: :nilable,
      verb_object: :nilable,
    }

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

      _so = _bound_solver
      st = _so.solve_for_ :line_downstream
      y = @line_yielder  # ..

      begin
        s = st.gets
        s or break
        y << s
        redo
      end while nil

      UNRELIABLE_
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
