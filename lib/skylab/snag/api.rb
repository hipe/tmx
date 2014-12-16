module Skylab::Snag

  module API  # see [#006]

    class << self

      # ~ here is how you make an API call:

      def bound_call_via_legacy_arglist arglist, & wire_p
        Produce_bound_call__.new(
          Callback_::Iambic_Stream.via_array( arglist ), & wire_p ).execute
      end

      # ~ convenience accessors for common property stack values

      def manifest_file
        bottom_properties_stack_frame.property_value_via_symbol :manifest_file
      end

      def max_num_dirs_to_search_for_manifest_file
        bottom_properties_stack_frame.property_value_via_symbol(
          :max_num_dirs_to_search_for_manifest_file )
      end

      # ~ open [#050] semi-hackish way we mutate what is effectively a config singleton

      def edit_bottom_properties_stack_frame & edit_p
        frame = bottom_properties_stack_frame.dup
        x = edit_p[ frame ]
        frame.freeze
        replace_bottom_properties_stack_frame frame
        x
      end
    end

    DEFAULT_MANIFEST_FILE__ = 'doc/issues.md'.freeze

    DEFAULT__MAX_NUM_DIRS_TO_SEARCH_FOR_MANIFEST_FILE__ = 15  # wuh-evuh

    # ~ produce bound call & support

    class Produce_bound_call__

      def initialize st, & wire_p
        @application_module = Snag_
        @upstream = st
        @wire_p = wire_p
      end

      def execute

        st = @upstream

        normal_name = st.gets_one

        if ::Hash.try_convert st.current_token
          @par_h = st.gets_one
          if ! @wire_p
            @wire_p = st.gets_one
          end
          st.unparsed_exists and raise ::ArgumentError
        else
          @par_h = nil
        end

        @action = bld_action_via_normal_name normal_name
        @action and via_action_produce_bound_call
      end

      def bld_action_via_normal_name normal_name, & mode_wiring_p

        cls = lookup_some_action_class_via_normal_name normal_name

        _frame = @application_module::API.bottom_properties_stack_frame

        invo = Invocation__.new _frame, @application_module

        if @wire_p  # legacy-style action wiring

          cls.new @wire_p, invo

        else  # new-style action

          cls.new invo do
            # no special customization
            nil
          end
        end
      end

      def lookup_some_action_class_via_normal_name normal_name
        Autoloader_.const_reduce normal_name, @application_module::API::Actions
      end

      def via_action_produce_bound_call
        if @par_h
          Snag_._lib.bound_call [ @par_h ], @action, :invoke
        else
          Snag_._lib.bound_call [ @upstream ], @action, :invoke_via_argument_stream
        end
      end
    end

    class Invocation__

      # [a] { client | context | services } for one particular invocation

      def initialize properties, application_module
        @application_module = application_module
        @props = properties
      end

      attr_reader :application_module

      def call i_a, par_h, wire_p

        # this is how one action invocation invokes another action.
        # signature is legacy as needed

        bc = @application_module::API.bound_call_via_legacy_arglist( [ i_a, par_h, wire_p ] )
        bc and bc.receiver.send bc.method_name, * bc.args
      end

      def models
        @application_module.models_cls.new self
      end

      # ~ business-specific convenience accessors

      def manifest_file
        @props.property_value_via_symbol :manifest_file
      end

      def max_num_dirs_to_search_for_manifest_file
        @props.property_value_via_symbol :max_num_dirs_to_search_for_manifest_file
      end
    end

    # ~ implement bottom properties stack frame

    class << self

      frozen_frame_singleton = -> do

        _FRAME = Bottom_Properties_Stack_Frame__.new

        frozen_frame_singleton = -> do
          _FRAME
        end

        _FRAME
      end

      define_method :bottom_properties_stack_frame do
        frozen_frame_singleton[]
      end

    private

      define_method :replace_bottom_properties_stack_frame do | _FRAME |
        frozen_frame_singleton = -> do
          _FRAME
        end ; nil
      end
    end

    class Bottom_Properties_Stack_Frame__  # minimal implementation of [#br-057]

      def initialize
        h = {}
        h[ :manifest_file ] = DEFAULT_MANIFEST_FILE__
        h[ :max_num_dirs_to_search_for_manifest_file ] =
          DEFAULT__MAX_NUM_DIRS_TO_SEARCH_FOR_MANIFEST_FILE__
        @h = h
        freeze
      end

      def freeze
        @h.freeze
        super
      end

      def initialize_copy _otr_
        @h = @h.dup
        nil
      end

      def property_value_via_symbol sym
        @h.fetch sym
      end

      # ~ business

      def set_max_num_dirs_to_search_for_manifest_file x
        @h[ :max_num_dirs_to_search_for_manifest_file ] = x ; nil
      end
    end

    # ~ stowaways

    module Actions

      def self.name_function  # #note-25
      end

      Autoloader_[ self, :boxxy ]
    end
  end
end
