module Skylab::Human

  class NLP::EN::Contextualization  # IS (see) :[#043].

    def initialize
      @selection_stack = nil
      @trilean = nil  # [#043]"A"
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

      if @_solver.is_writable_
        @_solver = @_solver.to_read_only__
        # NOTE - this trick safeguards the dups from writing to the data
        # of the parent, but note that *counterintuitively* any subsequent
        # edits that the parent object make to the solver will be reflected
        # in the child dups.
      end
    end

    NODES__ = {
      initial_phrase_conjunction: :nilable,
      inflected_verb: :nilable,
      selection_stack: nil,
      trilean: :nilable,
      verb_lemma: :nilable,
      verb_subject: :nilable,
      verb_object: :nilable,
    }

    NODES__.each_pair do |k, i|

      attr_reader k  # [#]"B" explains how this can be a knkn or a value

      ivar = :"@#{ k }"

      if :nilable == i
        # then because nil is a valid value, this.
        _p = -> x do
          instance_variable_set ivar, Callback_::Known_Known[ x ]
          x
        end
      else
        _p = -> x do
          instance_variable_set ivar, x
        end
      end

      define_method "#{ k }=", & _p
    end

    # -- different forms expression

    def build_string

      as = Here_::Phrase_Assembly.new

      so = @_solver.bound_to_knowns__ self

      _ic = so.solve_for_ :initial_phrase_conjunction
      _vs = so.solve_for_ :verb_subject
      _iv = so.solve_for_ :inflected_verb
      _vo = so.solve_for_ :verb_object

      as.add_any_string _ic.value_x
      as.add_any_string _vs.value_x
      as.add_any_string _iv.value_x
      as.add_any_string _vo.value_x

      as.build_string__
    end

    # -- for sub-clients

    def when_ when_x, can_produce_x, & by_p

      @_solver ||= Here_::Solver___.new_for__ NODES__.keys
      @_solver.add_entry__ when_x, can_produce_x, & by_p
      NIL_
    end

    Here_ = self
  end
end
