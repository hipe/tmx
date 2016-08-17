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

      # -- experimental

      @_possibly_wrapped_event_value_is_known = false
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

    # -- experimental "var" API (first part)

    Magnetic_routing_attr_accessor_ = -> cls, * sym_a do

      # simply routes the reading and writing thru these methods:
      #
      #     _write_magnetic_value_
      #     _read_magnetic_value_

      cls.class_exec do

        sym_a.each do |sym|

          define_method "#{ sym }=" do |x|
            _write_magnetic_value_ x, sym
            x
          end

          define_method sym do
            _read_magnetic_value_ sym
          end
        end

        NIL_
      end
    end

    Magnetic_routing_attr_accessor_.call( self,
      :channel,
      :expression_agent,
      :lemmas,
      :precontextualized_line_streamer,
      :selection_stack,
      :trilean,
    )

    # -- (we want the above to be simplified into the below during #open [#043])
    #

    def possibly_wrapped_event  # use with caution. experimental..

      # because it's not interesting to put the event-touching into the
      # graph, we just write a lazy reader here "by hand" but note there
      # are at least two assumptions being made, the second one is that..

      unless @_possibly_wrapped_event_value_is_known
        @_possibly_wrapped_event_value_is_known = true
        @possibly_wrapped_event = @emission_proc.call
      end

      @possibly_wrapped_event
    end

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
      :contextualized_line_streamer,
      :downstream_selective_listener_proc,
      :emission_proc,
      :emission_shape,
      :event_shape,
      :evento_trilean_idiom,
      :first_line_map,
      :idiom_for_failure,
      :idiom_for_neutrality,
      :idiom_for_success,
      :lemmato_trilean_idiom,
      :normal_selection_stack,
      :subject_association,
      :trilean_idiom,
      :to_say_selection_stack_item,
      :to_say_subject_association,
    )

    # -- hard-coded output (targets) inteface dreams of [#ta-005]

    def given_emission sym_a, & ev_p  # assume self is ad-hoc mutable

      begin_customization_ COLLECTION_

      can_read :channel
      self.channel = sym_a

      @emission_proc = ev_p

      # (unforgiveable crutch:) expect user can set these
      must_read :expression_agent
      can_read :lemmas
      must_read :precontextualized_line_streamer
      can_read :selection_stack
      must_read :trilean

      NIL_
    end

    def to_exception  # makes several assumptions:
      # assume e.g `given_emission` was called
      # covered by #C15n-test-family-5
      # (looks like #[#ca-066] emission-to-exception pattern)

      if ! _magnetic_value_is_known_ :expression_agent
        self.expression_agent = Home_.lib_.brazen::API.expression_agent_instance
      end

      if :expression == self.channel.fetch( 1 )

        a = _solve_stack_for_contextualized_expression
        a = a.dup
        a[ 0 ] = :Exception_via_Contextualized_Line_Streamer_and_First_Line_Map
        _wow = _execute_stack a
        _wow  # #todo
      else
        self._EASY_just_build_the_event_and_call_to_exception_on_it
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

        inst._common_express
      end
    end

    def build_string  # might just be a #feature-island

      # changes radically at [#043]
      @_function_symbol_stack.length.zero? || Home_._FIXME
      _execute_stack Hardcoded_path_1_classic___[]
    end

    def express_into_under line_yielder, expag  # assume self is ad-hoc mutable
      self.expression_agent = expag
      express_into line_yielder
    end

    def express_into line_yielder  # assume is ad-hoc mutable

      @line_yielder = line_yielder
      @_function_symbol_stack.length.zero? || Home_._FIXME
      _common_express
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
      inflected_verb_string: :nilable,
      verb_lemma_string: :nilable,
      verb_subject_string: :nilable,
      verb_object_string: :nilable,
    }

    attr_accessor(  # the below are plain old options, not used as nodes
      :emission_downhandler,
    )

    # -- different forms of expression

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

    def _common_express
      _a = _solve_stack_for_contextualized_expression
      _execute_stack _a
    end

    def _solve_stack_for_contextualized_expression

      if channel

        self.emission_shape = Magnetics_::Emission_Shape_via_Channel[ self ]

        if :Is_Of_Event == @emission_shape
          Hardcoded_path_2_event___[]
        elsif _magnetic_value_is_known_ :selection_stack
          Hardcoded_path_4_predicative___[]
        else
          Hardcoded_path_5_passthru___[]
        end

      elsif subject_association

        self.emission_shape = :Is_Of_Expression
        Hardcoded_path_3_no_channel_just_SA___[]

      else
        self._COVER_ME
      end
    end

    common_finish = Lazy_.call do
      [
        :Contextualized_Expression_via_Contextualized_Line_Streamer_and_Emission_Shape,
        :Contextualized_Line_Streamer_via_First_Line_Map_and_Precontextualized_Line_Streamer,
        :Precontextualized_Line_Streamer_via_Emission_Shape,
      ]
    end

    classic_start = Lazy_.call do
      [
        :First_Line_Map_via_Lemmas_and_Lemmato_Trilean_Idiom,
        :Lemmato_Trilean_Idiom_via_Trilean,
        :Lemmas_via_Normal_Selection_Stack,
        :Normal_Selection_Stack_via_Selection_Stack,
        :Trilean_via_Channel,
      ]
    end

    Hardcoded_path_5_passthru___ = Lazy_.call do
      [
        :Contextualized_Expression_via_Contextualized_Line_Streamer_and_Emission_Shape,
        :Contextualized_Line_Streamer_via_Passthru_and_Precontextualized_Line_Streamer,
        :Precontextualized_Line_Streamer_via_Emission_Shape,
      ].freeze
    end

    Hardcoded_path_4_predicative___ = Lazy_.call do
      [
        * common_finish[],
        * classic_start[],
      ].freeze
    end

    Hardcoded_path_3_no_channel_just_SA___ = Lazy_.call do
      [
        * common_finish[],
        :First_Line_Map_via_Subject_Association,
      ].freeze
    end

    Hardcoded_path_2_event___ = Lazy_.call do
      [
        * common_finish[],
        :First_Line_Map_via_Evento_Trilean_Idiom,
        :Evento_Trilean_Idiom_via_Event_and_Trilean,
        :Trilean_via_Channel,
      ].freeze
    end

    Hardcoded_path_1_classic___ = Lazy_.call do
      [
        :Message_That_Is_Single_String_via_First_Line_Map,
        * classic_start[],
      ].freeze
    end

    def _execute_stack sym_a

      o = Here_::Magnetic_Magnetics_::Solution_via_Parameters_and_Function_Path_and_Collection.begin
      o.collection = @_collection
      o.function_symbol_stack = sym_a
      o.parameters = self
      _ = o.execute
      _ # #todo
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

    def _write_magnetic_value_ x, sym
      par = @_rw[ sym ]
      if par
        instance_variable_set par.ivar, Common_::Known_Known[ x ]
      else
        instance_variable_set :"@#{ sym }", x
      end
      NIL_
    end

    def _read_any_magnetic_value_ sym
      par = @_rw[ sym ]
      if par
        ivar = par.ivar
        if instance_variable_defined? ivar
          instance_variable_get( ivar ).value_x
        end
      end
    end

    def _read_magnetic_value_with_certainty_ sym

      par = @_rw[ sym ]
      if par
        instance_variable_get( par.ivar ).value_x
      else
        ivar = :"@#{ sym }"
        if instance_variable_defined? ivar
          instance_variable_get ivar
        else
          raise ::NameError.new ivar
        end
      end
    end

    def _read_magnetic_value_ sym

      par = @_rw.fetch sym
      ivar = par.ivar

      if par.is_required or instance_variable_defined? ivar
        instance_variable_get( ivar ).value_x
      end
    end

    def _magnetic_value_is_known_and_trueish_ sym
      par = @_rw[ sym ]
      if par
        ivar = par.ivar
        if instance_variable_defined? ivar
          instance_variable_get( ivar ) ? true : false
        end
      end
    end

    def _magnetic_value_is_known_ sym

      par = @_rw[ sym ]
      if par
        instance_variable_defined? par.ivar
      end
    end

    # ==

    class Magnet_
      # (we prefer our magnetic functions to be small, stateless and module-
      #  based but when they are not, we use this base class to avoid boilerplate)
      class << self
        def via_magnetic_parameter_store ps
          new( ps ).execute
        end
        alias_method :[], :via_magnetic_parameter_store
        private :new
      end  # >>

      def initialize ps
        @ps_ = ps
      end
    end

    module Magnetics_

      # :#vanguards-of-experiment: magnetic switch statement

      module Contextualized_Line_Streamer_via_Passthru_and_Precontextualized_Line_Streamer ; class << self
        def via_magnetic_parameter_store ps
          ps.precontextualized_line_streamer
        end
      end ; end

      module Contextualized_Expression_via_Contextualized_Line_Streamer_and_Emission_Shape
        class << self
          def via_magnetic_parameter_store ps
            _sym = ps.emission_shape
            _const = :"Shape_that_#{ _sym }"
            const_get( _const, false )[ ps ]
          end
          alias_method :[], :via_magnetic_parameter_store
        end  # >>
        Autoloader_[ self ]
      end

      module First_Line_Map_via_Evento_Trilean_Idiom
        class << self
          def via_magnetic_parameter_store ps
            _sym = ps.evento_trilean_idiom
            _const = :"That_#{ _sym }"
            const_get( _const, false )[ ps ]
          end
          alias_method :[], :via_magnetic_parameter_store
        end  # >>
        Autoloader_[ self ]
      end

      module First_Line_Map_via_Lemmas_and_Lemmato_Trilean_Idiom
        class << self
          def via_magnetic_parameter_store ps
            _sym = ps.lemmato_trilean_idiom
            _const = :"Idiom_that_#{ _sym }"
            const_get( _const, false )[ ps ]
          end
          alias_method :[], :via_magnetic_parameter_store
        end  # >>
        Autoloader_[ self ]
      end

      Inflected_Parts_via_Lemmas_and_Idiom_that_Is_Add_Nothing = -> _lemz do
        # to be more touchy we provide an empty instance rather than nothing
        Models_::InflectedParts.the_empty_instance
      end

      module Precontextualized_Line_Streamer_via_Emission_Shape
        class << self
          def via_magnetic_parameter_store ps
            _sym = ps.emission_shape
            _const = :"That_#{ _sym }"
            const_get( _const, false )[ ps ]
          end
          alias_method :[], :via_magnetic_parameter_store
        end  # >>
        Autoloader_[ self ]
      end

      express_subject_association = -> asc do
        nm asc.name
      end

      String_via_Subject_Association = -> ps do

        sa = ps.subject_association
        if sa
          _p = ps.to_say_subject_association
          _p ||= express_subject_association
          ps.expression_agent.calculate sa, & _p
        end
      end

      Autoloader_[ self ]
    end

    module Magnetic_Magnetics_

      Autoloader_[ self ]
    end

    module Models_

      Autoloader_[ self ]
    end

    # ==

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

      col.add_constants_not_in_filesystem Magnetics_

      col.write_manner_methods_onto Here_

      COLLECTION_ = col

      NIL_
    end

    # ==

    BECAUSE_ = 'because'   # (used too many times - maybe #todo)
    Here_ = self
    UNRELIABLE_ = :_UNRELIABLE_from_hu_c15n_
  end
end
# #tombstone: inline functions, "butter"
