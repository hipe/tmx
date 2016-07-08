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

    def push_inline_function_ a, a_, f
      ifu = nil
      @_function_symbol_stack.push -> do
        ifu ||= Here_::Models_::InlineFunction.new a, a_, f  # #here-2
      end
    end

    def push_function_ sym
      @_function_symbol_stack.push sym ; nil
    end

    # -- experimental "var" API (first part)

    Magnetic_routing_attr_accessor_ = -> cls, * sym_a do

      # simply routes the reading and writing thru these methods:
      #
      #     write_magnetic_value
      #     read_magnetic_value

      cls.class_exec do

        sym_a.each do |sym|

          define_method "#{ sym }=" do |x|
            write_magnetic_value x, sym
            x
          end

          define_method sym do
            read_magnetic_value sym
          end
        end

        NIL_
      end
    end

    Magnetic_routing_attr_accessor_.call( self,
      :contextualized_line_stream,
      :expression_agent,
      :selection_stack,
      :to_say_selection_stack_item,
      :three_parts_of_speech,
      :trilean,
    )

    # -- (for now for some of these that are internal or never put into
    #     a prototype, we'll just keep them simple)

    attr_reader(
      :channel,
      :line_yielder,
    )

    attr_accessor(
      :emission_proc,
      :subject_association,
      :to_say_subject_association,
    )

    # -- experimental hard-coded output inteface

    def given_emission i_a, & ev_p  # assume self is ad-hoc mutable

      @_rw && Home_._COVER_ME
      @_rw = {}
      must_read :expression_agent
      must_read :trilean
      @channel = i_a
      @emission_proc = ev_p
      NIL_
    end

    def express_into_under line_yielder, expag  # assume self is ad-hoc mutable
      self.expression_agent = expag
      _express_into line_yielder
    end

    def express_into y  # assume self is ad-hoc mutable
      _express_into y  # (hi.)
    end

    def _express_into line_yielder  # assume is ad-hoc mutable

      @line_yielder = line_yielder
      if @_function_symbol_stack
        __express_via_function_stack
      else
        __express_brazenly
      end
    end

    def __express_brazenly

      o = Here_::Magnetics_::Expression_via_Emission.begin
      o.channel = @channel
      o.collection = COLLECTION__  # (not @_collection for now (but would be same))
      o.expression_agent = self.expression_agent
      o.emission_proc = @emission_proc
      o.line_yielder = @line_yielder
      o.execute
    end

    def build_string  # might just be a #feature-island

      a = @_function_symbol_stack.dup
      a.unshift :String_via_Surface_Parts

      o = _begin_solution
      o.function_symbol_stack = a
      o.execute
    end

    def __express_via_function_stack

      o = _begin_solution
      o.function_symbol_stack = @_function_symbol_stack

      # -- (close to [#ta-005], experimental)

      o.mutate_if_necessary_to_land_on :expression

      # --
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
      emission_handler: nil,  # endpoint
      initial_phrase_conjunction: :nilable,
      inflected_verb: :nilable,
      verb_lemma: :nilable,
      verb_subject: :nilable,
      verb_object: :nilable,
    }

    attr_accessor(  # the below are plain old options, not used as nodes
      :emission_downhandler,
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

    def _will_express_emission
      Here_::Express_Emission___[ self ] ; nil  # (changed to Expression_via_Emission)
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
    end

    def _begin_solution

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
        @_rw[ sym ] = Magnetic_Parameter_.new sym, false
      end
    end

    def must_read sym
      o = @_rw[ sym ]
      if ! o || ! o.is_required
        @_rw[ sym ] = Magnetic_Parameter_.new sym, true
      end
    end

    class Magnetic_Parameter_

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

      class InlineFunction  # 1x #here-2

        def initialize produce_sym_a, prerequisite_sym_a, func_x
          @function = func_x
          @prerequisite_term_symbols = prerequisite_sym_a
          @product_term_symbols = produce_sym_a
        end

        attr_reader(
          :function,
          :prerequisite_term_symbols,
          :product_term_symbols,
        )
      end
    end

    nl_rx = /(?<!\n)\z/  # ..
    Plus_newline_if_necessary_ = -> s do
      if nl_rx =~ s
        "#{ s }#{ NEWLINE_ }"
      else
        s
      end
    end

    # ==

    Do_big_index_and_enhance_once___ = Lazy_.call do

      _dir = ::Dir.new Magnetics_.dir_pathname.to_path

      col = Home_.lib_.task::Magnetics.
        collection_via_directory_object_and_module _dir, Magnetics_

      col.write_manner_methods_onto Here_

      COLLECTION__ = col

      NIL_
    end

    # ==

    Here_ = self
    UNRELIABLE_ = :_UNRELIABLE_from_hu_c15n_
  end
end
