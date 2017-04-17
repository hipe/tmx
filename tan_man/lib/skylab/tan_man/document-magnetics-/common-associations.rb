module Skylab::TanMan

  module DocumentMagnetics_::CommonAssociations

      if false
      class << self

        def downstream_reference_via_qualified_knownnesss qkn_a, & oes_p
          Byte_downstream_reference_[].via_qualified_knownnesses qkn_a, & oes_p
        end

        def entity_property_class
          IO_PROPERTIES__.entity_property_class
        end

        def IO_properties
          IO_PROPERTIES__.array
        end

        def input_properties  # an array
          INPUT_PROPERTIES___.array
        end

        def output_stream_property
          IO_PROPERTIES__.output_stream
        end

        def upstream_reference_via_qualified_knownnesss qkn_a, & oes_p
          Byte_upstream_reference_[].via_qualified_knownnesses qkn_a, & oes_p
        end
      end  # >>

      class Action < Action_

        # we've got to get in front of `normalize` so ..

        include Brazen_::Modelesque::Entity

        def document_entity_byte_upstream_reference
          @_DEBUID
        end

        def document_entity_byte_downstream_reference
          @_DEBDID
        end

      private

        def normalize

          # first call ordinary normalize to let any user-provided defaulting
          # logic play out. then with the result arguments, resolve from them
          # one input and (when applicable) one output means.

          _ok = super
          _ok && document_entity_normalize_
        end

        def document_entity_normalize_

          o = Byte_Stream_Identifier_Resolver.new( @kernel, & handle_event_selectively )

          o.formals formal_properties

          o.for_model silo_module

          o.against_argument_box @argument_box

          st = o.to_resolution_pair_stream

          st and begin
            ok = true
            begin
              pair = st.gets
              pair or break
              ok = send :"receive_byte__#{ pair.name_symbol }__identifier_", pair.value_x
              ok or break
              redo
            end while nil
            ok
          end
        end

        def receive_byte__input__identifier_ id
          if id
            @_DEBUID = maybe_convert_to_stdin_stream_ id
            @_DEBUID && ACHIEVED_
          else
            @_DEBUID = id
            ACHIEVED_
          end
        end

        def maybe_convert_to_stdin_stream_ id

          if id && :path == id.shape_symbol && DASH_ == id.path
            sin = stdin_
            if sin.tty?
              maybe_send_event :error, :stdin_should_probably_not_be_interactive
              UNABLE_
            else
              Byte_upstream_reference_[].via_open_IO sin
            end
          else
            id
          end
        end

        def receive_byte__output__identifier_ id

          @_DEBDID = __maybe_convert_to_stdout_stream id
          ACHIEVED_
        end

        def __maybe_convert_to_stdout_stream id

          if id && :path == id.shape_symbol && DASH_ == id.path
            Brazen_::Collection::ByteDownstreamReference.via_open_IO stdout_
          else
            id
          end
        end
      end
      end  # if false

    # :#spot1.1:
    #
    # please buckle up because we're going to be justifying two separate but
    # related "essential" features of advanced modeling at once:
    #
    # as it works out, many (most?) of the actions in this application are
    # involved with reading from or manipulating The Document in some way.
    #
    # in order to read from the document, every such action must resolve a
    # means of input (a "byte upstream reference") (add, ls, rm).
    #
    # those actions that mutate the document must also resolve a means of
    # output (a "byte downstream reference") (add, rm).
    #
    # as a bit of an aside, there are actions that may (for certain modality
    # adaptations) want to customize such parameters to effect a defaulting
    # of, say, the `pwd` (current working directory); but such a retrieval
    # of this system "service" must *not* happen from the microservice layer
    # itself, because it is not appropriate for a true microservice to be
    # dependent on such a volatile property such as the `pwd`. the relevant
    # uptake here is that like all other formal associations, these ones
    # might be customized per modality (near #masking).
    #
    # more broadly the thing to note about all this is two key points:
    #
    #   1. that the associations like these (there are several) all have
    #      characteristics that are part of a common "semantic sub-system"
    #      (sub-domain) that while pertinent to these actions, is not
    #      pertinent to what we consider "common associations".
    #
    #   1. that it would feel folly to re-model these same associations
    #      (parameters/properties) over and over again for the perhaps dozens
    #      of actions that all use some subset of these common associations.
    #
    # for an example of the first point, from the discussion above we might
    # say there's this idea of a "throughput direction" for an association
    # to have: some associations might be related to resolving an input (an
    # "upstream reference"). others might be related to resolving an output
    # (a "downstream reference"). some associations (as we will see) will
    # be concerned with both. however it is not the case that all
    # associations in all applications should necessarily even have to "know"
    # what a "throughput direction" is, much less represent values for this
    # "custom meta association".
    #
    # for better or worse, all of the above has been heralded as the
    # quintessential use-case for application-specific meta-associations:
    #
    # here, then, is the frontier use-case for the "nouveau" rewrites of
    # both shared common associations (here "parameters") and custom meta-
    # associations.
    #

    # ==

    class << self

      def to_workspace_related_stream_
        __to_stream WORKSPACE_RELATED__
      end

      def to_workspace_related_mutable_hash__
        __to_hash WORKSPACE_RELATED__
      end

      def __to_hash sym_a
        h = {}
        col = common_IO_parameters
        sym_a.each do |sym|
          h[ sym ] = col.dereference sym
        end
        h
      end

      def __to_stream sym_a

        col = common_IO_parameters

        Stream_.call sym_a do |sym|
          col.dereference sym
        end
      end
    end  # >>

    WORKSPACE_RELATED__ = [
      :workspace_path,
      :max_num_dirs_to_look,
      :config_filename,
    ]

    define_singleton_method :common_IO_parameters, ( Lazy_.call do

      Home_.lib_.brazen_NOUVEAU::CommonAssociations.define do |o|

        o.property_grammatical_injection_by do

          inj = Home_::Model_.my_custom_grammatical_injection_without_custom_meta_associations_

          inj.redefine do |oo|

            # (keep the same, application-specific association base class)

            # (eek allow ourselves to define these mods out in the open)

            mod = MyCustomPrefixedModifiers___
            mod.include oo.prefixed_modifiers
            oo.prefixed_modifiers = mod

            mod = MyCustomPostfixedModifiers___
            mod.include oo.postfixed_modifiers
            oo.postfixed_modifiers = mod
          end
        end

        o.add_association_by_definition_array :input_string do
          [ :property, :input_string, :throughput_direction, :input ]
        end

        o.add_association_by_definition_array :input_path do
          [ :property, :input_path, :throughput_direction, :input ]
        end

        o.add_association_by_definition_array :output_string do
          [ :property, :output_string, :throughput_direction, :output ]
        end

        o.add_association_by_definition_array :output_path do
          [ :property, :output_path, :throughput_direction, :output ]
        end

        o.add_association_by_definition_array :config_filename do [

          :property, :config_filename,

          :default_by, -> _action do
            # #cov2.1 (random silo)
            Config_filename_knownness_[]
          end,

          :throughput_direction, :input,
          :throughput_direction, :output,
        ] end

        o.add_association_by_definition_array :max_num_dirs_to_look do [

          :non_negative_integer,
          :property, :max_num_dirs_to_look,
          :default, 1,

          :description, -> y do
            y << "whatever max num dirs, like `common_properties` in [br]"
          end,

          :throughput_direction, :input,
          :throughput_direction, :output,

        ] end

        o.add_association_by_definition_array :workspace_path do [

          :required,  # #cov1.3 but..
          :direction_essential,
          :property, :workspace_path,

          :throughput_direction, :input,
          :throughput_direction, :output,

          # (it's important that this property is at the end of the list)
        ] end
      end
    end )

    # ==

    module MyCustomPrefixedModifiers___

      def direction_essential

        Touch_throughput_characteristics__[ @parse_tree ].is_essential = true
        KEEP_PARSING_
      end
    end

    module MyCustomPostfixedModifiers___

      def throughput_direction

        sym = @scanner.gets_one

        tc = Touch_throughput_characteristics__[ @parse_tree ]

        _x = tc[ sym ]
        _x.nil? or raise ::ArgumentError  # otherwise count will be corrupted
        tc[ sym ] = true
        tc.count += 1

        KEEP_PARSING_
      end
    end

    Touch_throughput_characteristics__ = -> parse_tree do
      parse_tree._throughput_characteristics_ ||= ThroughputCharacteristics___.new 0
    end

    ThroughputCharacteristics___ = ::Struct.new :count, :is_essential, :input, :output

      if false
      class Collection_Controller

        # frontier. this *is* a controller because it is coupled to the action.

        include Common_::Event::ReceiveAndSendMethods

        def initialize act, bx, mc, k, & oes_p

          oes_p or self._EVENT_HANDLER_MANDATORY

          @action = act
          @df = bx.fetch :dot_file
          @kernel = k
          @model_class = mc
          @precons_box_ = bx
          @on_event_selectively = oes_p

        end

        # c r u d

        def unparse_into y
          @df.unparse_into y
        end

        def flush_maybe_changed_document_to_output_adapter__ did_mutate
          if did_mutate
            flush_changed_document_to_ouptut_adapter
          else
            __when_document_did_not_change
          end
        end

        def __when_document_did_not_change

          maybe_send_event :info, :document_did_not_change do

            Common_::Event.inline_neutral_with(

              :document_did_not_change

            ) do | y, o |

              y << "document did not change."
            end
          end ; nil
        end

        def flush_changed_document_to_ouptut_adapter
          flush_changed_document_to_output_adapter_per_action @action
        end

        def flush_changed_document_to_output_adapter_per_action action

          @df.persist_into_byte_downstream_reference(

            action.document_entity_byte_downstream_reference,

            :is_dry, action.argument_box[ :dry_run ],

            & action.handle_event_selectively )

        end

        def document_

          # we wanted this to be referred to as "digraph" and not "dot file"
          # but the clients need to manipulate the document at the sexp level
          # so it is pointless to try to abstract our implementation away..

          @df
        end
      end
      end

    # ==
    # ==
  end
end
# #history-A: used to be "document entity". extracted "byte stream reference via" to own file
