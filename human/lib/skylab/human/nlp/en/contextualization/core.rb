module Skylab::Human

  class NLP::EN::Contextualization  # [#043]

    class << self
      alias_method :begin, :new
      undef_method :new
    end  # >>

    def initialize
      Do_big_index_and_enhance_once___[]
    end

    def initialize_copy _
      NOTHING_  # (hi.) #c15n-test-family-1
    end

    # -- parameter writer and reader definitions (from more to less complex)

    # ~ because it's not interesting to put the event-touching into the graph
    #   we just write a lazy reader here "by hand" but note the assumptions:

    def possibly_wrapped_event
      unless _magnetic_value_is_known_ :possibly_wrapped_event
        if :Is_Of_Event == @emission_shape
          @possibly_wrapped_event = @emission_proc.call
        else
          @possibly_wrapped_event = NOTHING_
        end
      end
      @possibly_wrapped_event
    end

    # ~ a "trilean" is like a "boolean" but can be one of three meaningful
    #   values: trueish, nil or false; usually interpreted to represent
    #   success/ok, neutral and failure; respectively. we wrap it in
    #   knownness to protect against reading when the value is unknown and
    #   misinterpreting `nil`. see also #c15n-spot-2.

    def trilean= x
      @trilean = Common_::Known_Known[ x ] ; x
    end

    def trilean
      @trilean.value_x
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
      :channel,
      :contextualized_line_streamer,
      :downstream_selective_listener_proc,
      :expression_agent,
      :emission_proc,
      :emission_shape,
      :event_shape,
      :evento_trilean_idiom,
      :first_line_map,
      :idiom_for_failure,
      :idiom_for_neutrality,
      :idiom_for_success,
      :lemmas,
      :lemmato_trilean_idiom,
      :normal_selection_stack,
      :precontextualized_line_streamer,
      :selection_stack,
      :subject_association,
      :trilean_idiom,
      :to_say_selection_stack_item,
      :to_say_subject_association,
    )

    # -- hard-coded output (targets) inteface dreams of [#ta-005]

    def given_emission sym_a, & ev_p  # assume self is ad-hoc mutable
      @channel = sym_a
      @emission_proc = ev_p
      NIL_
    end

    def to_exception  # makes several assumptions:
      # assume e.g `given_emission` was called
      # covered by #C15n-test-family-5
      # (looks like #[#ca-066] emission-to-exception pattern)

      if ! _magnetic_value_is_known_ :expression_agent
        @expression_agent = Home_.lib_.brazen::API.expression_agent_instance
      end

      if :expression == @channel.fetch( 1 )

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
      _execute_stack Hardcoded_path_1_classic___[]
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
      _a = _solve_stack_for_contextualized_expression
      _execute_stack _a
    end

    def _solve_stack_for_contextualized_expression

      if _magnetic_value_is_known_ :channel

        @emission_shape = Magnetics_::Emission_Shape_via_Channel[ self ]

        if :Is_Of_Event == @emission_shape
          Hardcoded_path_2_event___[]
        elsif _magnetic_value_is_known_ :selection_stack
          Hardcoded_path_4_predicative___[]
        else
          Hardcoded_path_5_passthru___[]
        end

      elsif _magnetic_value_is_known_ :subject_association

        @emission_shape = :Is_Of_Expression
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
        :Trilean_via_Channel,  # only b.c clients might ask
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
      o.collection = COLLECTION_
      o.function_symbol_stack = sym_a
      o.parameters = self
      _ = o.execute
      _ # #todo
    end

    # -- experimental magnetic parameter reader/writer API (VERY experimental)
    #
    # these exist so that magnetic pipeline pathfinding and solving concerns
    # can inquire the [#co-004] knownness of, read and write particpating
    # parameter values with an interface that is insulated from implementation
    # details of the particular parameter store. it's VERY experimental and
    # won't settle down until the whole magnetic implementation is out of [hu].
    #
    # every method in this section MUST:
    #
    #   - use `_named_like_this_` to keep the namespace of ordinary-looking
    #     names wide-open for business (see [#bs-028]:#tier-0.5)
    #
    #   - match the regex /(\A|_)magnetic_value(\z|_)/

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

    Const_via_idiom_ = -> sym do
      :"Is_#{ sym }"
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
