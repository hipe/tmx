module Skylab::Human

  class NLP::EN::Contextualization  # [#043]

    class << self
      alias_method :begin, :new
      undef_method :new
    end  # >>

    def initialize

      block_given? && ::Kernel._WHERE

      @state_crutch_ = true  # will change this (somehow)
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
    end

    # -- mini-API for the above callback

    def begin_customization_ col
      remove_instance_variable :@state_crutch_
      @_collection = col
      @_function_symbol_stack = []
      @_rw = {}
      NIL_
    end

    attr_reader(
      :state_crutch_,
    )

    def push_inline_function_ a, a_, f
      ifu = nil
      @_function_symbol_stack.push -> do
        ifu ||= Here_::Models_::InlineFunction.new a, a_, f  # #here-2
      end
    end

    def push_function_ sym
      sym == @_function_symbol_stack.last && self._WHERE  # #todo
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
      :channel,
      :event,
      :expression_agent,
      :inflected_parts,
      :lemmas,
      :precontextualized_line_stream,
      :selection_stack,
      :trilean,
    )

    # -- (we want the above to be simplified into the below during #open [#043])
    #

    # - the below haven't been needed yet, they default to a default

    def to_contextualize_first_line_with_selection_stack
      NOTHING_  # same
    end

    def to_say_first_selection_stack_item
      NOTHING_  # same
    end

    def to_say_nonfirst_last_selection_stack_item
      NOTHING_  # same
    end

    attr_reader(
      :line_yielder,
    )

    attr_accessor(
      :contextualized_line_stream,
      :downstream_selective_listener_proc,
      :emission_proc,
      :on_failed_proc,
      :subject_association,
      :to_say_selection_stack_item,
      :to_say_subject_association,
    )

    # -- hard-coded output (targets) inteface dreams of [#ta-005]

    def given_emission sym_a, & ev_p  # assume self is ad-hoc mutable

      begin_customization_ COLLECTION_

      must_read :channel
      self.channel = sym_a

      @emission_proc = ev_p

      # (unforgiveable crutch:) expect user can set these
      must_read :expression_agent
      must_read :event
      must_read :precontextualized_line_stream
      must_read :selection_stack
      must_read :trilean

      NIL_
    end

    def express_into_under line_yielder, expag  # assume self is ad-hoc mutable
      self.expression_agent = expag
      express_into line_yielder
    end

    def express_into line_yielder  # assume is ad-hoc mutable

      @line_yielder = line_yielder

      if @_function_symbol_stack.length.zero?

        Magnetics_::Contextualized_Expression_via_Emission[ self ]
      else
        _solve_for_contextualized_expression
      end
    end

    def emission_handler_via_emission_handler & downstream_oes_p

      # (method name is referenced in the document.)

      me = self

      -> * sym_a, & ev_p do

        inst = me.dup

        inst.channel = sym_a

        inst.emission_proc = ev_p

        inst.downstream_selective_listener_proc = downstream_oes_p

        inst._solve_for_contextualized_expression
      end
    end

#==BEGIN
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
      inflected_verb: :nilable,
      verb_lemma: :nilable,
      verb_subject: :nilable,
      verb_object: :nilable,
    }

    attr_accessor(  # the below are plain old options, not used as nodes
      :emission_downhandler,
    )
    end
#==END

    # -- different forms of expression

    def to_exception  # look:
      # assume e.g `given_emission` was called
      # mutate receiver
      # covered by #C15n-test-family-5
      # (looks like #[#ca-066] emission-to-exception pattern)

      if :expression == self.channel.fetch( 1 )
        ___exception_via_expression
      else
        self._EASY_just_build_the_event_and_call_to_exception_on_it
      end
    end

    def ___exception_via_expression

      if ! _magnetic_value_is_known_ :expression_agent
        self.expression_agent = Home_.lib_.brazen::API.expression_agent_instance
      end

      s = express_into ""
      s.chop!  # weee

      sym = self.channel[ 2 ]
      cls = if sym
        Common_::Event::To_Exception::Class_via_symbol.call sym do
          NOTHING_
        end
      end
      cls ||= ::RuntimeError
      cls.new s
    end

#==BEGIN
    if false
    def _will_express_emission
      Here_::Express_Emission___[ self ] ; nil  # (changed to Expression_via_Emission)
    end

    # -- for sub-clients

    def when_ when_x, can_produce_x, & by_p

      @_solver ||= Here_::Solver___.new_for__ NODES__.keys
      @_solver.add_entry__ when_x, can_produce_x, & by_p
      NIL_
    end
    end
#==END

    def build_string  # might just be a #feature-island

      # changes radically at [#043]

      a = @_function_symbol_stack
      o = _begin_solution
      o.function_symbol_stack = a

      _hi  = o.bottom_item_ticket_
      _hi.product_term_symbols == [ :inflected_parts ] || fail
      _ip = o.execute
      _ip.to_string__
    end

    def _solve_for_contextualized_expression

      # very much a crutch for #open [#043]

      mutable_a = @_function_symbol_stack.dup

      o = _begin_solution

      o.function_symbol_stack = mutable_a

      _hi = o.bottom_item_ticket_

      _hi.const == :Inflected_Parts_via_Lemmas_and_Trilean || fail

      mutable_a.unshift :Contextualized_Expression_via_Emission

      o.execute
    end

    def _solve_via_function_symbol_stack a

      o = _begin_solution
      o.function_symbol_stack = a
      o.execute
    end

    def _begin_solution

      o = Here_::Magnetic_Magnetics_::Solution_via_Parameters_and_Function_Path_and_Collection.begin
      o.parameters = self
      o.collection = @_collection
      o
    end

    def emission_is_expression__

      if _magnetic_value_is_known_ :channel
        _yes = :expression == self.channel[1]  # #[#br-023]. [sli] has 1-item channels
      else
        _yes = true
      end
      _yes  # #todo
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

    def read_magnetic_value_with_certainty sym

      instance_variable_get( @_rw.fetch( sym ).ivar ).value_x
    end

    def read_magnetic_value sym

      var = @_rw.fetch sym
      ivar = var.ivar

      if var.is_required or instance_variable_defined? ivar
        instance_variable_get( ivar ).value_x
      end
    end

    def _magnetic_value_is_known_ sym

      var = @_rw[ sym ]
      if var
        instance_variable_defined? var.ivar
      end
    end

    # ==

    module Magnetics_

      _Express_subject_association___ = -> asc do
        nm asc.name
      end

      Subject_Association_String_via_Subject_Association_SMALL = -> ps do
        sa = ps.subject_association
        if sa
          _p = ps.to_say_subject_association
          _p ||= _Express_Subject_Association___
          _ = ps.expression_agent.calculate ps.subject_association, & _p
          _  # #todo
        end
      end

      Autoloader_[ self ]
    end

    module Magnetic_Magnetics_

      Autoloader_[ self ]
    end

    module Models_

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

      Autoloader_[ self ]
    end

    needs_nl_rx = /(?<!\n)\z/  # ..
    Plus_newline_if_necessary_ = -> s do
      if needs_nl_rx =~ s
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

      COLLECTION_ = col

      NIL_
    end

    # ==

    Here_ = self
    UNRELIABLE_ = :_UNRELIABLE_from_hu_c15n_
  end
end
