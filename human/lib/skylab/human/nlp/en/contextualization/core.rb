module Skylab::Human

  class NLP::EN::Contextualization  # IS (see) :[#043].

    def initialize & p
      @_solver = nil

      if p
        @emission_downhandler = p
      end
    end

    # -- (usually) as prototype

    def express_selection_stack
      Here_::Express_Selection_Stack___.new self
    end

    def express_subject_association
      Here_::Express_Subject_Association___.new self
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

      @_bound_solver = nil
    end

    NODES__ = {
      channel: nil,
      emission_handler: nil,  # endpoint
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
      :emission_downhandler,
      :expression_agent,
      :event,
      :event_proc,
      :line_stream,
      :line_yielder,
      :subject_association,
      :to_say_selection_stack_item,
      :to_say_subject_association,
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

    def to_emission_handler  # as referenced in [#043]

      _so = bound_solver_
      _oes_p = _so.solve_for_ :emission_handler
      _oes_p
    end

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

    def __emit_expression i_a, & ev_p

      @channel = i_a
      @expression_proc = ev_p
      me = self
      @emission_handler.call( * i_a ) do |y|
        me.express_into y
      end
      UNRELIABLE_
    end

    def express_into y  # mutates c15n for now

      _so = bound_solver_
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
      so = bound_solver_

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

    def bound_solver_
      @_bound_solver ||= @_solver.bound_to_knowns__ self
    end

    # -- for sub-clients

    def when_ when_x, can_produce_x, & by_p

      @_solver ||= Here_::Solver___.new_for__ NODES__.keys
      @_solver.add_entry__ when_x, can_produce_x, & by_p
      NIL_
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
          @_a.push Plus_newline_if_necessary_[ s ]
        end
        @_a = []
      end

      attr_reader :y

      def to_line_stream
        Callback_::Stream.via_nonsparse_array @_a
      end
    end

    Plus_newline_if_necessary_ = -> s do
      if NL_RX___ =~ s
        s = "#{ s }#{ NEWLINE_ }"
      end
      s
    end

    NL_RX___ = /(?<!\n)\z/  # ..

    Here_ = self
    Lazy_ = Callback_::Lazy
    NEWLINE_ = "\n"
    NOTHING_ = nil
    UNRELIABLE_ = :_UNRELIABLE_from_hu_c15n_
  end
end
