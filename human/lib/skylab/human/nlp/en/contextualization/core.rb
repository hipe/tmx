module Skylab::Human

  class NLP::EN::Contextualization  # IS (see) :[#043].

    class << self
      alias_method :begin, :new
      undef_method :new
    end  # >>

    def initialize & p
      @_function_symbol_stack = nil
      @_rw = nil
      Do_big_index_and_enhance_once___[]
      NIL_
    end

    def dup

      fsc = @_function_symbol_stack
      if fsc && ! fsc.frozen?
        fsc.freeze
      end

      rw = @_rw
      if rw && ! rw.frozen?
        rw.freeze
      end

      super
    end

    def receive_magnetic_manner cls, manner, collection
      cls.modify_contextualization_client_ self, manner, collection
      NIL_
    end

    # -- mini-API for the above callback

    def begin_customization_ col
      @_collection = col
      @_function_symbol_stack = []
      @_rw = {}
      NIL_
    end

    def push_function_ sym
      @_function_symbol_stack.push sym ; nil
    end

    # -- experimental "var" API (first part)

    advanced_attr_accessor = -> * sym_a do  # this is explained #here below

      sym_a.each do |sym|

        define_method "#{ sym }=" do |x|
          write_magnetic_value x, sym
          x
        end

        define_method sym do
          read_magnetic_value sym
        end
      end
    end

    advanced_attr_accessor[
      :expression_agent,
      :selection_stack,
      :to_say_selection_stack_item,
      :three_parts_of_speech,
      :trilean,
    ]

    # -- experimental hard-coded output inteface

    def build_string

      a = @_function_symbol_stack.dup
      a.unshift :String_via_Surface_Parts

      o = __begin_solution
      o.function_symbol_stack = a
      o.execute
    end

    if false

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
      verb_lemma: :nilable,
      verb_subject: :nilable,
      verb_object: :nilable,
    }

    attr_accessor(  # the below are plain old options, not used as nodes
      :emission_downhandler,
      :event,
      :event_proc,
      :line_stream,
      :line_yielder,
      :subject_association,
      :to_say_subject_association,
    )

    # -- different forms of expression

    def to_exception  # #covered-only-by:[my]. mutates receiver.

      # (looks like #[#ca-066] emission-to-exception pattern)

      if :expression == @channel.fetch( 1 )
        ___exception_via_expression
      else
        self._EASY_just_build_the_event_and_call_to_exception_on_it
      end
    end

    def ___exception_via_expression

      @expression_agent ||= Home_.lib_.brazen::API.expression_agent_instance

      _will_express_emission
      s = express_into ""
      s.chop!  # weee

      _3rd = @channel[ 2 ]
      if _3rd
        cls = Common_::Event::To_Exception::Class_via_symbol.call _3rd do
          NOTHING_
        end
      end
      cls ||= ::RuntimeError
      cls.new s
    end

    def to_emission_handler  # as referenced in [#043]

      _so = bound_solver_
      _oes_p = _so.solve_for_ :emission_handler
      _oes_p
    end

    def express_emission i_a, & ev_p

      if @_solver
        self._COVER_ME
      end
      _will_express_emission
      @channel = i_a
      @event_proc = ev_p
      express_into @line_yielder
      UNRELIABLE_
    end

    def _will_express_emission
      Here_::Express_Emission___[ self ] ; nil
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

    def bound_solver_
      @_bound_solver ||= @_solver.bound_to_knowns__ self
    end

    # -- for sub-clients

    def when_ when_x, can_produce_x, & by_p

      @_solver ||= Here_::Solver___.new_for__ NODES__.keys
      @_solver.add_entry__ when_x, can_produce_x, & by_p
      NIL_
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
        Common_::Stream.via_nonsparse_array @_a
      end
    end

    Plus_newline_if_necessary_ = -> s do
      if NL_RX___ =~ s
        s = "#{ s }#{ NEWLINE_ }"
      end
      s
    end

    NL_RX___ = /(?<!\n)\z/  # ..

    end

    def __begin_solution

      o = Here_::Magnetics_::Solution_via_Parameters_and_Function_Path_and_Collection.begin
      o.parameters = self
      o.collection = @_collection
      o
    end

    # -- experimental "var" API (second part)

    # (so that a contextualization *prototype* can be made without needing
    #  to load all involved assets (but only the manners and this file),
    #  we hard-code all possible writable business values here..) :#here

    def can_read sym
      _o = @_rw[ sym ]
      if ! _o
        @_rw[ sym ] = Var__.new sym, false
      end
    end

    def must_read sym
      o = @_rw[ sym ]
      if ! o || ! o.is_required
        @_rw[ sym ] = Var__.new sym, true
      end
    end

    class Var__

      def initialize sym, b
        @is_required = b
        @ivar = :"@#{ sym }"
      end

      attr_reader(
        :is_required,
        :ivar,
      )
    end

    def write_magnetic_value x, sym
      _var = @_rw.fetch sym
      instance_variable_set _var.ivar, Common_::Known_Known[ x ]
      NIL_
    end

    def read_magnetic_value sym

      var = @_rw.fetch sym
      ivar = var.ivar

      if var.is_required or instance_variable_defined? ivar
        instance_variable_get( ivar ).value_x
      end
    end

    # ==

    module Magnetics_
      Autoloader_[ self ]
    end

    module Models_

      Surface_Parts = ::Struct.new(
        :initial_phrase_conjunction,
        :inflected_verb,
        :verb_object,  # carried-over
        :verb_subject,  # carried-over
      ) do
        class << self
          def begin_via_parts_of_speech pos
            new nil, nil, pos.verb_object, pos.verb_subject
          end
          private :new
        end  # >>
      end
    end

    # ==

    Do_big_index_and_enhance_once___ = Lazy_.call do

      _dir = ::Dir.new Magnetics_.dir_pathname.to_path

      _col = Home_.lib_.task::Magnetics.
        collection_via_directory_object_and_module _dir, Magnetics_

      _col.write_manner_methods_onto Here_

      NIL_
    end

    # ==

    Here_ = self
    UNRELIABLE_ = :_UNRELIABLE_from_hu_c15n_
  end
end
