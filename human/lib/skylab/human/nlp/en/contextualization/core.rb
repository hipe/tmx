module Skylab::Human

  class NLP::EN::Contextualization  # [#043]

    class << self

      def collection
        # (part of public API for visualization)
        Init_collection_once__[]
        COLLECTION__
      end

      alias_method :begin, :new
      undef_method :new
    end  # >>

    def initialize
      NOTHING_
    end

    def initialize_copy _
      NOTHING_  # (hi.) #c15n-test-family-1
    end

    # -- parameter writer and reader definitions (from more to less complex)

    # ~ even though in a perfectly magnetic world it shouldn't be necessary,
    #   we want to be sure that when we read `nil` from the below reader,
    #   it's trilean `nil` and not the not-set `nil`. #c15n-spot-2 is nearby.

    def trilean= x
      @trilean = Common_::Known_Known[ x ] ; x
    end

    def trilean
      @trilean.value_x
    end

    # ~ functions are written assuming these terms are user-writable (and
    #   when the below result in nil the function uses an appropriate default)
    #   but since the overhaul we haven't needed as much customization..

    def idiom_for_success
      NOTHING_
    end

    def to_contextualize_first_line_with_selection_stack
      NOTHING_
    end

    def to_say_first_selection_stack_item
      NOTHING_
    end

    def to_say_nonfirst_last_selection_stack_item
      NOTHING_
    end

    # ~ self-documenting city

    # the ordinary startpoints:
    WRITE_ONLY_BY_USER_AND_READ_ONLY_BY_PIPELINE__ = [
      :channel,
      :selection_stack,
      :subject_association,
    ]

    # not part of the pipeline, only for users to customize behavior:
    WRITE_ONLY_BY_USER_AND_READ_ONLY_BY_FUNCTIONS__ = [
      :downstream_selective_listener_proc,
      :emission_proc,
      :expression_agent,
      :idiom_for_failure,  # [dt]
      :idiom_for_neutrality,  # [ba]
      :to_say_selection_stack_item,
      :to_say_subject_association,
    ]

    # the ordinary waypoints and endpoints of the pipeline:
    RDWR_BY_PIPELINE_ONLY__ = [
      :contextualized_line_streamer,
      :evento_trilean_idiom,
      :first_line_map,
      :lemmas,
      :lemmato_trilean_idiom,
      :normal_selection_stack,
      :precontextualized_line_streamer,
      :trilean_idiom,
    ]

    # nodes that are set here manually and read by the pipeline:
    READ_ONLY_BY_PIPELINE_ONLY__ = [
      :custom_idiom_proc__,
      :emission_shape,
      :event,
      :passthru,
    ]

    # set here manually and read by functions whew!
    READ_ONLY_BY_FUNCTIONS_ONLY__ = [
      :line_yielder,
    ]

    CAN_BE_DETECTED_AS_A_GIVEN___ = [
      * WRITE_ONLY_BY_USER_AND_READ_ONLY_BY_PIPELINE__,
      * READ_ONLY_BY_PIPELINE_ONLY__,

      :trilean,  # write only by user and readable/writable by pipeline.
      # has custom reader/writer so it must not be part of the below calls.
    ]

    attr_writer(
      * WRITE_ONLY_BY_USER_AND_READ_ONLY_BY_PIPELINE__,
      * WRITE_ONLY_BY_USER_AND_READ_ONLY_BY_FUNCTIONS__,
      * RDWR_BY_PIPELINE_ONLY__,
      :custom_idiom_proc__,  # written by this lib but from the outside
    )

    attr_reader(
      * WRITE_ONLY_BY_USER_AND_READ_ONLY_BY_PIPELINE__,
      * WRITE_ONLY_BY_USER_AND_READ_ONLY_BY_FUNCTIONS__,
      * RDWR_BY_PIPELINE_ONLY__,
      * READ_ONLY_BY_PIPELINE_ONLY__,
      * READ_ONLY_BY_FUNCTIONS_ONLY__,
    )

    alias_method :possibly_wrapped_event, :event  # use the longer name in
    # hand-written code. the shorter name is used in the pipeline network
    # for ergonomics and name-change insulation but this may change. :#here-1

    # -- hard-coded writer "macros"

    def given_emission sym_a, & ev_p
      @channel = sym_a
      @emission_proc = ev_p
      NIL_
    end

    def to_exception  # assume e.g `given_emission` was called
      # probably the last solution for #[#ca-066] emission-to-exception pattern

      # (we would push this up higher but it hasn't been needed yet)
      if ! _magnetic_value_is_known_ :expression_agent
        @expression_agent = Home_.lib_.brazen::API.expression_agent_instance
      end

      _init_emission_shape

      if :Is_Of_Expression == @emission_shape

        _stack = _assisted_stack_when_emission_for :exception
        _run_this _stack
      else
        self._EASY_just_build_the_event_and_call_to_exception_on_it
      end
    end  # covered by #C15n-test-family-5

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
      _stack = _stack_for :message_that_is_single_string
      _run_this _stack
    end

    def express_into_under line_yielder, expag  # assume self is ad-hoc mutable
      @expression_agent = expag
      express_into line_yielder
    end

    def express_into line_yielder  # assume is ad-hoc mutable
      @line_yielder = line_yielder
      _common_express
    end

    def _common_express

      # what we do here that we [think we] can't do with pipelines is interesting

      _stack = if _magnetic_value_is_known_ :channel

        _init_emission_shape

        if :Is_Of_Event == @emission_shape
          __hand_hacked_stack_for_event
        else
          _assisted_stack_when_emission_for :contextualized_expression
        end
      elsif _magnetic_value_is_known_ :subject_association

        @emission_shape = :Is_Of_Expression

        _stack_for :contextualized_expression
      else
        self._COVER_ME
      end

      _run_this _stack
    end

    def _init_emission_shape
      @emission_shape = Magnetics_::Emission_Shape_via_Channel[ self ]
    end

    def __hand_hacked_stack_for_event  # assume @emission_proc

      @event = @emission_proc.call  # lhs ivar name is per #here-1
      _stack_for :contextualized_expression do |o|
        o.preferred_waypoint_node = :event
      end
    end

    def _assisted_stack_when_emission_for target

      if _magnetic_value_is_known_ :selection_stack

        _stack_for :contextualized_expression
      else
        _assisted_stack_for_passthru target
      end
    end

    def _assisted_stack_for_passthru target
      @passthru = true
      _stack_for target do |o|
        o.manual_adjustment_proc = Workaround_for_bug_hu_60___
      end
    end

    def solve_for sym  # [br] (as covered by [gv])
      if _magnetic_value_is_known_ sym
        _read_magnetic_value_ sym
      else
        _stack = _stack_for sym
        x = _run_this _stack  # because it was as the bottom of the stack:
        _write_magnetic_value_ x, sym
        x
      end
    end

  -> do

    # avoiding calculating the same stack for the same "ingredients" twice
    # saves you palpable milliseconds (depending on the extent to which this
    # happens.  #C15n-test-family-5 (a little) and #c15n-test-family-1 (a lot)

    stack_cache = {}

    define_method :_stack_for do |target_sym, &p|
      query = Pipeline_Query___.new
      query.given_symbol_array = __build_givens
      query.target_symbol = target_sym
      if p
        p[ query ]
      end
      stack_cache.fetch query do
        stack = __stack_via_query query
        stack_cache[ query ] = stack
        stack
      end
    end
  end.call

    def __stack_via_query query

      Init_collection_once__[]

      o = Task_::Magnetics::Magnetics::
        Function_Stack_via_Collection_and_Parameters_and_Target.begin_with(
          COLLECTION__,
          query.given_symbol_array,
          query.target_symbol,
        )

      o.preferred_waypoint_node = query.preferred_waypoint_node  # if any
      o.do_trace = true
      ok, stack = o.execute
      if ok
        stack
      else
        self._COVER_ME_stack_not_found
      end
    end

    def __build_givens
      CAN_BE_DETECTED_AS_A_GIVEN___.reduce [] do |m, x|
        if _magnetic_value_is_known_ x
          m << x
        end
        m
      end
    end

    def _run_this stack
      o = Task_::Magnetics::Magnetics::Result_via_Collection_and_Function_Stack_and_Given_Parameters.begin
      o.collection = COLLECTION__
      o.function_symbol_stack = stack
      o.parameters = self
      o.execute
    end

    # -- an experimental implementation to frontier the experimental (sic)
    #    API that will hold for a "parameter store" to be used when a
    #    magnetic pipeline stack is executed. every method here MUST:
    #
    #      - use `_named_like_this_` to keep the namespace of ordinary-
    #        looking names wide-open for business (see [#bs-028]:#tier-0.5)
    #
    #      - match the regex /(\A|_)magnetic_value(\z|_)/

  -> do
    ivars = ::Hash.new do |h, k|
      h[ k ] = :"@#{ k }"
    end

    writer_method = ::Hash.new do |h, k|
      h[ k ] = :"#{ k }="
    end

    define_method :_write_magnetic_value_ do |x, sym|
      send writer_method[ sym ], x
    end

    define_method :_read_magnetic_value_with_certainty_ do |sym|
      if _magnetic_value_is_known_ sym
        _read_magnetic_value_ sym
      else
        raise ::KeyError, sym  # or whatever. this is just for sanity checks
      end
    end

    define_method :_read_magnetic_value_ do |sym|
      send sym  # assume this for now
    end

    define_method :_magnetic_value_is_known_ do |sym|
      instance_variable_defined? ivars[ sym ]  # asssume this for now
    end
  end.call

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

      Subject_Association_String_via_Subject_Association = -> ps do

        sa = ps.subject_association
        if sa
          _p = ps.to_say_subject_association
          _p ||= express_subject_association
          ps.expression_agent.calculate sa, & _p
        end
      end

      Autoloader_[ self ]
    end

    module Models_
      Autoloader_[ self ]
    end

    # ==

    Pipeline_Query___ = ::Struct.new(
      :given_symbol_array,
      :manual_adjustment_proc,
      :preferred_waypoint_node,
      :target_symbol,
    )

    # ==

    Const_via_idiom_ = -> x, ps do
      # (experimental implementation)
      if x.respond_to? :call
        ps.custom_idiom_proc__ = x  # eek
        :Is_Custom
      else
        :"Is_#{ x }"
      end
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

    Init_collection_once__ = Lazy_.call do

      Task_ = Home_.lib_.task  # weee

      _dir = ::Dir.new Magnetics_.dir_pathname.to_path

      col = Task_::Magnetics.
        collection_via_directory_object_and_module _dir, Magnetics_

      col.add_constants_not_in_filesystem Magnetics_

      COLLECTION__ = col ; nil
    end

    # ==

    Workaround_for_bug_hu_60___ = -> stack do
      # the below is #open [#hu-060]
      # caveat :#here-3: don't convert this to be an inline lambda because
      # it will break the equivalency detection and caching will never hit
      :Emission_Shape_via_Channel == stack[-1] || fail
      :Emission_Shape_via_Channel == stack[-2] || fail
      stack.pop
      NIL
    end

    # ==

    BECAUSE_ = 'because'  # (used multiple times :/ )
    Here_ = self
    UNRELIABLE_ = :_UNRELIABLE_from_hu_c15n_
  end
end
# #tombstone: inline functions, "butter"
