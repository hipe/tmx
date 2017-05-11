module Skylab::TanMan

  module Models_::Hear

    # :[#030] "hear" is the very beginnings of a rough prototype for an idea..
    # it's much like the beginnings of a [#br-002] frontier "modality".

    Actions = ::Module.new

    class Actions::Hear

      def definition
        false and [
        :branch_description, -> y do
          y << 'experimental natural language-ISH interface'
        end,

        :inflect, :noun, nil, :verb, 'understand',
        ]
        _these = Home_::DocumentMagnetics_::CommonAssociations.all_
        [
        :properties, _these,

        :flag, :property, :dry_run,

        :required, :property, :words,  # ..
        ]
      end

      # every top-level model node has zero or more parse functions. these are
      # instantiated lazily, only as many as are needed to find one that
      # parses the input. but each that is created is cached, so that we only
      # ever create one parse function for the lifetime of the process.

      def initialize
        extend Home_::Model_::CommonActionMethods
        init_action_ yield
        @_associations_ = {}  # #[#031]
      end

      def execute

        up_st = Parse_lib_[].input_stream.via_array @words
        st = _to_exposure_stream
        begin
          exp = st.gets
          exp || break
          on = exp._parse_function.output_node_via_input_stream up_st
          on && break
          up_st.current_index = 0
          redo
        end while above

        if on
          _me_as_box = to_box_
          _hrd = Heard___.new on.value_x, _me_as_box, @_microservice_invocation_
          exp._native_definition.execute_via_heard _hrd, & _listener_  # result is association entity (on success)
        else
          _listener_.call :error, :unrecognized_utterance do
            __build_event
          end
          NIL_AS_FAILURE_
        end
      end

      def __build_event

        _f_a = _to_exposure_stream.map_by do |exp|
          exp._parse_function
        end.to_a

        Common_::Event.inline_not_OK_with(
          :unrecognized_utterance,
          :words, @words,
          :parse_functions, _f_a,
        ) do |y, o|

          y << "unrecognized input #{ ick_mixed o.words }. known definitions:"

          o.parse_functions.each do |f|
            y << f.express_all_segments_into_under( "" )
          end
          y
        end
      end

      def _to_exposure_stream
        Memoized_exposure_operator_branch___[].to_dereferenced_item_stream
      end
    end

    Heard___ = ::Struct.new(
      :parse_tree,
      :qualified_knownness_box,
      :microservice_invocation,
    )

    # ==

    Memoized_exposure_operator_branch___ = Lazy_.call do  # :#here1

      _unordered_st = To_stream_of_unordered_exposures___[]

      _ordered_exposure_st = Home_.lib_.brazen_NOUVEAU::
        Ordered_stream_via_participating_stream[ _unordered_st ]

      Common_::Stream::Magnetics::RandomAccessImmutable_via_Stream.define do |o|
        o.upstream = _ordered_exposure_st
        o.key_method_name = :name_value_for_order
      end
    end

    # ==

    To_stream_of_unordered_exposures___ = -> do

      To_stream_of_participating_silos___[].expand_by do |silo|

        ExposureStream_via_ParticipatingSilo___[ silo ]
      end
    end

    # ==

    ExposureStream_via_ParticipatingSilo___ = -> o do

      normal_sym = o.normal_symbol

      mod = o.silo_module.const_get( :HearMap, false )::Definitions

      _consts = mod.constants

      Stream_.call _consts do |const|

        _cls = mod.const_get const, false

        Exposure___.new _cls, const, normal_sym
      end
    end

    # ==

    class Exposure___

      def initialize cls, const, normal_sym

        defn = cls.new

        @_parse_function = Parse_lib_[].function_via_definition_array(
          defn.definition )

        _sym = Common_::Name.via_const_symbol( const ).as_lowercase_with_underscores_symbol

        @name_value_for_order = [ normal_sym, _sym ].freeze

        @_native_definition = defn

        freeze
      end

      def after_name_value_for_order
        @_native_definition.after
      end

      attr_reader(
        :name_value_for_order,  # participate with [co] ordering
        :_native_definition,
        :_parse_function,
      )
    end

    # ==

    To_stream_of_participating_silos___ = -> do

      # (weirdly, for once we don't memoize this operator branch because
      #  we're already memoizing its leaf nodes of interest #here1)

      Home_.lib_.system_lib::Filesystem::Directory::OperatorBranch_via_Directory.define do |o|

        mod = Models_

        o.startingpoint_module = mod

        o.glob_entry = ::File.join '*', "hear-map#{ Autoloader_::EXTNAME }"

        o.directory_is_assumed_to_exist = true

        o.loadable_reference_via_path_by = Participating_silo_builder_via___[ mod ]

      end.to_loadable_reference_stream
    end

    # ==

    Participating_silo_builder_via___ = -> mod do

      -> path do

        _slug = ::File.basename ::File.dirname path
        name = Common_::Name.via_slug _slug

        const = name.as_camelcase_const_string.intern
        _mod = mod.const_get const, false

        _sym = name.as_lowercase_with_underscores_symbol

        ParticipatingSilo___.new _mod, _sym
      end
    end

    ParticipatingSilo___ = ::Struct.new(
      :silo_module,
      :normal_symbol,  # for o.b caching (not used but meh)
    )

    # ==

    DEFINITION_FOR_THE_METHOD_CALLED_WITH_MUTABLE_DIGRAPH = -> & p do

      Models_::DotFile::DigraphSession_via_THESE.call_by do |o|

        o.session_by do |sess|
          @_mutable_digraph_ = sess
          x = p[]
          remove_instance_variable :@_mutable_digraph_
          x
        end

        o.be_read_write_not_read_only_
        o.qualified_knownness_box = @_qualified_knownness_box_

        o.is_dry_run = false  # let's just say this isn't available under "hear"
        o.microservice_invocation = @_microservice_invocation_
        o.listener = _listener_
      end
    end

    # ==

    Parse_lib_ = Lazy_.call do
      Home_.lib_.parse_lib
    end

    # ==
    # ==
  end
end
# #history-A.1: full rewrite during ween off [br]. tombstone of resulting in "bound call"
# (historical note of #posterity: this used to be *THE* PEG grammar file.)
