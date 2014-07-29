module Skylab::Brazen

  module Entity

    class Meta_Property__

        def initialize scan
          @scan = scan
          @has_default_x = @has_entity_class_hook = false
          @name_i = iambic_property
          @as_ivar = :"@#{ @name_i }"
          @iambic_writer_method_name = :"#{ @name_i }="
          process_iambic_passively
          @last_iambic_idx = @scan.current_index
          @scan = nil
          freeze
        end

        attr_reader :as_ivar, :iambic_writer_method_name, :name_i,
          :has_default_x, :default_x,
          :enum_box

        def might_have_entity_class_hooks
        end

        def apply_to_property_class pc
          _kernel = Kernel__.new pc, pc.singleton_class
          _kernel.add_property self
          aply_iambic_writers_to_property_class pc
          @has_default_x and aply_defaulting_behavior_to_property_class pc
          @has_entity_class_hook and aply_ent_cls_hook_to_prop_cls pc
          nil
        end

      private

        def aply_iambic_writers_to_property_class pc
          ivar = @as_ivar
          enum = enum_box
          pc.send :attr_reader, @name_i
          if enum
            pc.send :include, Meta_Prop_IMs__
            name_i = @name_i
            pc.send :define_method, @iambic_writer_method_name do
              x = iambic_property
              enum[ x ] or raise ::ArgumentError, say_bad_enum_value( name_i, x )
              instance_variable_set ivar, x
            end
          else
            pc.send :define_method, @iambic_writer_method_name do
              instance_variable_set ivar, iambic_property
            end
          end
          nil
        end

        def aply_defaulting_behavior_to_property_class pc
          pc.add_iambic_event_listener :at_end_of_process_iambic, -> prop do
            if ! prop.instance_variable_defined?( @as_ivar ) ||
                prop.instance_variable_get( @as_ivar ).nil?
              prop.instance_variable_set @as_ivar, @default_x
            end
          end
        end

        def aply_ent_cls_hook_to_prop_cls pc
          pc.add_ent_cls_hk @name_i, @entity_class_hook_p ; nil
        end

        Entity[ self, -> do

          def default
            @has_default_x = true
            @default_x = iambic_property
          end

          def entity_class_hook
            @has_entity_class_hook = true
            @entity_class_hook_p = iambic_property
          end

          def enum
            x = iambic_property
            bx = Box__.new
            x.each do |i|
              bx.add i, true
            end
            @enum_box = bx ; nil
          end

        end ]
        include Iambic_Methods_via_Scanner__


      module Meta_Prop_IMs__
      private
        def say_bad_enum_value name_i, x
          _a = self.class.properties[ :color ].enum_box.get_names
          "invalid #{ name_i } '#{ x }', expecting { #{ _a * " | " } }"
        end
      end

      module Muxer
        class << self
          def [] cls, const_i, write_i
            cls.send :define_method, write_i, bld_write_meth( const_i )
            nil
          end
          def bld_write_meth const_i
            -> do
              if const_defined? const_i, false
                const_get const_i, false
              else
                _MUXER_ = Muxer__.new
                const_set const_i, _MUXER_
                if respond_to? :method_added_mxr and mxr = method_added_mxr
                  mxr.stop_listening  # kind of ick for now
                end
                define_method :notificate do |i|
                  _MUXER_.mux i, self
                  super i
                end
                mxr and mxr.resume_listening
                _MUXER_
              end
            end
          end
        end
      end

      class Muxer__

        def initialize
          @h = ::Hash.new { |h, k| h[k] = [] }
        end

        def add i, p
          @h[ i ].push p ; nil
        end

        def mux i, *a
          p_a = @h.fetch i do end
          if p_a
            ( p_a.length - 1 ).downto( 0 ).each do |d|
              p_a.fetch( d )[ * a ]
            end
          end
          UNDEFINED_
        end
      end
    end

    # ~ experimental additions to entity core (BE CAREFUL!)

    class Kernel__

      include Iambic_Methods_via_Scanner__

      def property_class_for_write
        @reader.property_cls_for_wrt
      end

      def add_property prop
        @prop = prop
        prop_accept
        @prop = nil
      end

    private
      def prcs_any_ent_cls_hks
        p_a = @prop.get_any_relevant_entity_class_hks_p_a
        if p_a
          p_a.each do |p|
            p[ @reader, @prop ]
          end
        end ; nil
      end

      def twds_prop_scan_some_DSL_as_metaproperties_being_used
        @pcls ||= @reader.property_cls_for_rd
        @prop and self._SANITY
        @pcls.new do |prop|
          @prop = prop
          this_child_must_iambicly_scan_something prop
          if unparsed_iambic_exists
            iambic_keyword :property
            prop_i = @scan.gets_one
            flush_because_prop_i prop_i
          else
            @meth_i or raise ::ArgumentError, say_expected_def
            flush_bc_meth
          end
          @prop = nil
        end
      end

      def say_strange
        "unrecognized iambic term: #{ strange @scan.current_token }"
      end

      def say_expected_def
        "expected method definition at end of iambic input"
      end
    end

    module Proprietor_Methods__
    private

      def flsh_with_property_definition_block p  # #experimental
        kernel = bld_property_kernel
        has_nonzero_length_iambic_queue and kernel.flush_iambic_queue
        kernel.apply_p p ; nil
      end

      # ~ property class for write

      remove_method :property_class_for_write
      def property_class_for_write
        if has_nonzero_length_iambic_queue
          _kernel = bld_property_kernel
          _kernel.flush_iambic_queue
        end
        property_cls_for_wrt
      end

    public

      def property_cls_for_wrt
        if const_defined? :PROPERTY_CLASS__, false
          const_get :PROPERTY_CLASS__, false
        else
          cls = ::Class.new const_get( :PROPERTY_CLASS__, true )
          const_set :Property, cls
          const_set :PROPERTY_CLASS__, cls
        end
      end

      def property_cls_for_rd
        const_get :PROPERTY_CLASS__
      end

      # ~ iambic event listener

      def add_iambic_event_listener i, p
        iambic_evnt_muxer_for_write.add i, p ; nil
      end

      Meta_Property__::Muxer[ self,
        :IAMBIC_EVENT_MUXER__, :iambic_evnt_muxer_for_write ]


    private  # ~ support
      def bld_property_kernel
        Kernel__.new self, singleton_class
      end
    end

    module Extension_Module_Methods__
    private
      def bld_property_kernel
        Kernel__.new self, const_get( :Module_Methods, false )
      end
    end

    class Box__

      def get_key_scanner
        d = -1 ; last = @a.length - 1
        Callback_::Scn.new do
          if d < last
            @a.fetch d += 1
          end
        end
      end

      def fetch i, & p
        @h.fetch i, & p
      end

      def add_or_replace i, x
        @h.fetch i do
          @a.push i
        end
        @h[ i ] = x ; nil
      end
    end

    class Property__

      # ~ entity class hooks

      class << self
        def add_ent_cls_hk metaprop_i, p
          ( @entity_class_hks_box ||= begin
            @has_entity_class_hks = true
            Box__.new
          end ).add_or_replace metaprop_i, p ; nil
        end

        attr_reader :has_entity_class_hks, :entity_class_hks_box
      end

      remove_method :might_have_entity_class_hooks
      def might_have_entity_class_hooks
        self.class.has_entity_class_hks
      end

      def get_any_relevant_entity_class_hks_p_a
        box = self.class.entity_class_hks_box
        scn = box.get_key_scanner
        i = scn.gets
        a = nil
        begin
          if instance_variable_defined? :"@#{ i }"  # or whatever
            ( a ||= [] ).push box.fetch i
          end
          i = scn.gets
        end while i
        a
      end

      Entity[ self ]  # ~ property as entity
      include Iambic_Methods_via_Scanner__
      attr_accessor :scan
      public :process_iambic_passively
    end

    module Iambic_Methods__
    private

      remove_method :emit_iambic_event
      def emit_iambic_event i
        notificate i
      end

      def iambic_keyword i
        unparsed_iambic_exists or raise ::ArgumentError, say_kw_not_end( i )
        i == current_iambic_token or raise ::ArgumentError, say_kw_not_x( i )
        advance_iambic_scanner_by_one ; nil
      end

      def say_kw_not_end i
        "expected #{ kw i } at end of iambic input"
      end

      def say_kw_not_x i
        "expected #{ kw i } not #{ strange @scan.current_token }"
      end

      def kw i
        "'#{ i }'"
      end

      def strange i  # placeholder for [#mh-050]
        "'#{ i }'"
      end
    end

    module Iambic_Methods_via_Scanner__
    private
      def this_child_must_iambicly_scan_something o
        o.scan = @scan
        d = @scan.current_index
        o.process_iambic_passively
        d == @scan.current_index and raise ::ArgumentError, say_strange
        o.scan = nil
      end
    end

    if ! ::Object.private_method_defined? :notificate
      class ::Object
      private
        def notificate i  # :+[#sl-131] the easiest implementation for this
        end
      end
    end
  end
end
