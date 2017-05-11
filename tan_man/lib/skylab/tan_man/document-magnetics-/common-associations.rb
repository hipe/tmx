module Skylab::TanMan

  module DocumentMagnetics_::CommonAssociations

    # (the IO-related parameters here are explained at [#026])

    # ==

    class << self

      def to_workspace_related_stream_nothing_required_
        __as_optionals_at WORKSPACE_RELATED__
      end

      def to_workspace_related_stream_

        sym_a = WORKSPACE_RELATED__
        # ..
        col = common_IO_parameters

        Stream_.call sym_a do |sym|
          col.dereference sym
        end
      end
    end

    WORKSPACE_RELATED__ = [
      :workspace_path,
      :max_num_dirs_to_look,
      :config_filename,
    ]

    -> do

      cache = -> k1 do
        col = common_IO_parameters
        normal = -> k do
          col.dereference k
        end
        deref = -> k do
          asc = normal[ k ]
          if :workspace_path == k
            asc = asc.redefine do |o|
              o.be_optional
            end
            deref = normal
            asc
          else
            asc
          end
        end
        cache = ::Hash.new do |h, k|
          x = deref[ k ]
          h[ k ] = x
          x
        end
        cache[ k1 ]
      end

      define_singleton_method :__as_optionals_at do |sym_a|
        sym_a.map do |sym|
          cache[ sym ]
        end
      end

      define_singleton_method :all_ do
        common_IO_parameters.to_loadable_reference_stream.map_by do |sym|
          cache[ sym ]
        end
      end
    end.call

    define_singleton_method :common_IO_parameters, ( Lazy_.call do

      Home_.lib_.brazen_NOUVEAU::CommonAssociations.define do |o|

        o.property_grammatical_injection_by do

          This_one_custom_attribute_grammatical_injection__[]
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

          # :throughput_direction, :input,
          # :throughput_direction, :output,
        ] end

        o.add_association_by_definition_array :max_num_dirs_to_look do [

          :non_negative_integer,
          :property, :max_num_dirs_to_look,
          :default, 1,

          :description, -> y do
            y << "whatever max num dirs, like `common_properties` in [br]"
          end,

          # :throughput_direction, :input,
          # :throughput_direction, :output,

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

    This_one_grammar = Lazy_.call do  # 1x

      # the way this is implementated is just a rough sketch. this is the
      # grammar to parse ONLY document-centric properties (defined with the
      # `propery` keyword), and nothing else. (but it could be modified to
      # be more like our main grammar.)

      _param_gi =
        This_one_custom_attribute_grammatical_injection__[]

      Home_.lib_.parse_lib::IambicGrammar.define do |o|

        o.add_grammatical_injection :_DOC_parameter_TM_, _param_gi
      end
    end

    # ==

    This_one_custom_attribute_grammatical_injection__ = Lazy_.call do

      _inj = Home_::Model_.my_custom_grammatical_injection_without_custom_meta_associations_

      _inj.redefine do |oo|

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

    ThroughputCharacteristics___ = ::Struct.new(
      :count,  # keeps track of how many different "throughput directions" this
      :is_essential,  # #todo document this or away it
      :input,    # whether this attribute is associated with input
      :hereput,  # whether this attribute is associated with [#026.C] "hereput"
      :output,   # whether this attribute is associated with output
    )

    Here__ = self

    # ==
    # ==
  end
end
# #history-A: used to be "document entity". extracted "byte stream reference via" to own file
