module Skylab::Brazen

  module Entity

    module Meta_Properties__

      def self.given_propery_names_flush_queue
        yield (( shell = Process_DSL__.new ))
        shell.given_names_flush_queue
      end

      def self.flush_iambic_queue_in_to_two_mods mod, closure_mod
        dsl = Process_DSL__.new
        dsl.closure_definee_mod = closure_mod
        dsl.proprietor = mod
        dsl.queue = mod.iambic_queue
        dsl.flush_queue
      end

      class Process_DSL__

        def initialize
          @prop_class = @prop = nil
        end

        attr_accessor :prop_i, :meth_i

        attr_writer :closure_definee_mod

        def proprietor= mod
          @mod = mod
        end

        def queue= x
          @x_a_a = x
        end

        # ~ the two kinds of propery builders

        def given_names_flush_queue  # called when a method defined, for e.g
          prep_big_scan
          begin
            @d_ += 1
            prep_standard_parse
            prcs_any_known_symbols
            @stopped_at_unknown_symbol and break
          end while @d_ < @x_a_a_last
          prop = via_names_prs_prop
          @x_a_a.clear
          prop
        end

        def flush_queue
          prep_big_scan
          begin
            @d_ += 1
            prep_standard_parse
            prcs_any_known_symbols
            @stopped_at_unknown_symbol and consume_complete_property
          end while @d_ < @x_a_a_last
          @x_a_a.clear ; nil
        end

      private

        # ~ support methods in tandem for the two kinds of property builders

        def via_names_prs_prop
          @prop_class ||= prop_class_for_read
          @prop_class.new do |prop|
            @prop = prop
            @stopped_at_unknown_symbol and towards_prop_cnsm_some_remainder
            add_names_to_property
            @prop.clear_all_iambic_ivars
          end
          prop = @prop ; @prop = nil ; prop
        end

        def consume_complete_property
          @prop_class ||= prop_class_for_read
          @prop_class.new do |prop|
            @prop = prop
            towards_prop_consume_any_metaproperties
            finish_complete_prop_with_name
            @prop.clear_all_iambic_ivars
          end
          @prop = nil
        end

        def towards_prop_cnsm_some_remainder  # allow no non-prop symbols
          @stopped_at_unknown_symbol = false
          begin
            @prop.process_iambic_fully @d, @x_a
            @x_a_a_last == @d_ and break
            @d_ += 1
            prep_standard_parse
          end while true
          nil
        end

        def towards_prop_consume_any_metaproperties
          @stopped_at_unknown_symbol = false
          begin
            @prop.process_iambic_passively @d, @x_a
            @d = @prop.d
            if @d < @x_a_length
              @stopped_at_unknown_symbol = true
              break
            end
            @x_a_a_last == @d and break
            @d += 1
            prep_standard_parse
          end while true
          @stopped_at_unknown_symbol or raise ::ArgumentError, say_prop
          nil
        end

        def finish_complete_prop_with_name
          :property == current_iambic_token or raise ::ArgumentError, say_prop
          advance_iambic_scanner
          @prop_i = iambic_property
          @meth_i = :"__PROCESS_IAMBIC_PARAMETER__#{ @prop_i }"
          add_names_to_property
          @prop.class::Flusher.new.
            with_two_mods( @mod, @closure_definee_mod ).add_property @prop
          ivar = @prop.as_ivar
          @mod.method_added_mxr.stop_listening
          @mod.send :define_method, @prop.iambic_writer_method_name do
            instance_variable_set ivar, iambic_property ; nil
          end
          @mod.method_added_mxr.resume_listening
          nil
        end

        # ~ shared support for the two kinds of property builders

        def prep_big_scan
          @d_ = -1 ; @x_a_a_last = @x_a_a.length - 1
        end

        def prep_standard_parse
          @x_a = @x_a_a.fetch @d_
          @d = 0 ; @x_a_length = @x_a.length
        end

        def prcs_any_known_symbols
          process_iambic_passively
          @stopped_at_unknown_symbol = @d < @x_a_length ; nil
        end

        def say_prop
          if @d < @x_a_length
            x = current_iambic_token
            "expected 'property' had \"#{ x }\""  # :+#needs-strange
          else
            "expected 'property' before end of iambic queue"
          end
        end

        def prop_class_for_read
          @mod.const_get :PROPERTY_CLASS__
        end

        def add_names_to_property
          @prop_i && @meth_i or raise ::ArgumentError, "required name(s) missing"
          @prop.set_iambic_writer_method_name @meth_i
          @prop.set_name_i @prop_i ; nil
        end

        Entity[ self, -> do

          def meta_property
            mp = Meta_Property__.new @d, @x_a
            @d = mp.d
            @prop_class = @mod.property_cls_for_wrt
            mp.apply_to_property_class @prop_class ; nil
          end

          def property
            @d -= 1  # wicked - imagine that there were metaprops being used
            consume_complete_property
          end
        end ]
      end

      class Meta_Property__

        def initialize d, x_a
          @d = d ; @x_a = x_a
          @has_default_x = @has_entity_class_hook = false
          @name_i = iambic_property
          @as_ivar = :"@#{ @name_i }"
          @iambic_writer_method_name = :"#{ @name_i }="
          process_iambic_passively
          @x_a = @x_a_length = nil  # leave @d as-is
          freeze
        end

        def might_have_entity_class_hooks
        end

        attr_reader :as_ivar, :d, :iambic_writer_method_name, :name_i,
          :has_default_x, :default_x,
          :enum_box

        def apply_to_property_class pc
          pc::Flusher.new.with_two_mods(
            pc, pc.singleton_class ).add_property self
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
      end

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
                _MUXER = Muxer__.new
                const_set const_i, _MUXER
                if respond_to? :method_added_mxr and mxr = method_added_mxr
                  mxr.stop_listening  # kind of ick for now
                end
                define_method :notificate do |i|
                  _MUXER.mux i, self
                  super i
                end
                mxr and mxr.resume_listening
                _MUXER
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

    module Proprietor_Methods__

      attr_reader :method_added_mxr

      def iambic_property_writers * x_a, & p
        shell = Shell__.new
        shell.client = self
        shell.p = p
        shell.process_option_iambic x_a
        shell.to_client_via_p_apply ; nil
      end

      remove_method :property_class_for_write
      def property_class_for_write
        has_nonzero_length_iambic_queue and flsh_iambic_queue
        property_cls_for_wrt
      end

      def property_cls_for_wrt
        if const_defined? :PROPERTY_CLASS__, false
          const_get :PROPERTY_CLASS__, false
        else
          cls = ::Class.new const_get( :PROPERTY_CLASS__, true )
          const_set :Property, cls
          const_set :PROPERTY_CLASS__, cls
        end
      end

      def add_iambic_event_listener i, p
        iambic_evnt_muxer_for_write.add i, p ; nil
      end

      Meta_Properties__::Muxer[ self, :IAMBIC_EVENT_MUXER__,
        :iambic_evnt_muxer_for_write ]

    private
      def flsh_iambic_queue
        _closure_mod = if const_defined? :Module_Methods, false
          const_get :Module_Methods, false
        else
          singleton_class
        end
        Meta_Properties__.flush_iambic_queue_in_to_two_mods self, _closure_mod
        nil
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
      class << self
        def add_ent_cls_hk metaprop_i, p
          ( @entity_class_hks_box ||= begin
            @has_entity_class_hks = true
            Box__.new
          end ).add_or_replace metaprop_i, p ; nil
        end

        attr_reader :has_entity_class_hks, :entity_class_hks_box
      end

      attr_reader :d

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

      class Flusher
        def prcs_any_ent_cls_hks prop
          p_a = prop.get_any_relevant_entity_class_hks_p_a
          if p_a
            p_a.each do |p|
              p[ @proprietor, prop ]
            end
          end ; nil
        end
      end
    end

    module Iambic_Methods__

      def with * a
        @d = 0 ; process_iambic_fully a
        clear_all_iambic_ivars
        self
      end

      def current_iambic_token
        @x_a.fetch @d
      end

      def advance_iambic_scanner
        @d += 1 ; nil
      end

      def clear_all_iambic_ivars
        @d = @x_a = @x_a_length = nil
        UNDEFINED_
      end

      remove_method :emit_iambic_event
      def emit_iambic_event i
        notificate i
      end
    end

    if ! ::Object.private_method_defined? :notificate
      class ::Object
      private
        def notificate i  # :+[#sl-131] the easiest implementation for this
        end
      end
    end

    UNDEFINED_ = nil
  end
end
