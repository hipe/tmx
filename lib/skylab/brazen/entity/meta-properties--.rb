module Skylab::Brazen

  module Entity

    module Meta_Properties__

      def self.build_property
        yield (( shell = Process_DSL__.new ))
        shell.build_prop
      end

      class Process_DSL__
        def initialize
          @prop_class = nil
        end

        attr_accessor :prop_i, :meth_i

        def proprietor= mod
          @mod = mod
        end

        def queue= x
          @x_a_a = x
        end

        def build_prop
          @d_ = 0 ; x_a_a_length = @x_a_a.length
          begin
            prepare_standard_parse
            process_iambic_passively
            if @d < @x_a_length
              use_of_meta_properties_started = true
              break
            end
            @d_ += 1
          end while @d_ < x_a_a_length

          @prop_class ||= prop_class_for_read

          @prop_class.new do |prop|
            @prop = prop
            if use_of_meta_properties_started
              prcss_use_of_meta_properties
            end
            @d_ += 1
            while @d_ < x_a_a_length
              prepare_standard_parse
              process_iambic_passively
              if @d_ < @x_a.length
                prcss_use_of_meta_properties
              end
              @d_ += 1
            end
            add_names_to_property
            prop.clear_all_iambic_ivars
          end
          @x_a_a.clear
          @prop
        end

      private

        def prepare_standard_parse
          @x_a = @x_a_a.fetch @d_
          @d = 0 ; @x_a_length = @x_a.length
        end

        def prcss_use_of_meta_properties
          @prop.process_iambic_fully @d, @x_a
          @d = @x_a = nil
        end

        def prop_class_for_read
          @mod.const_get :PROPERTY_CLASS__
        end

        def prop_class_for_write
          if @mod.const_defined? :PROPERTY_CLASS__, false
            @mod.const_get :PROPERTY_CLASS__, false
          else
            cls = ::Class.new @mod.const_get( :PROPERTY_CLASS__, true )
            @mod.const_set :Property, cls
            @mod.const_set :PROPERTY_CLASS__, cls
          end
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
            @prop_class = prop_class_for_write
            mp.apply_to_property_class @prop_class
          end
        end ]
      end

      class Meta_Property__

        def initialize d, x_a
          @d = d ; @x_a = x_a
          @name_i = iambic_property
          @as_ivar = :"@#{ @name_i }"
          @iambic_writer_method_name = :"#{ @name_i }="
          process_iambic_passively
          @x_a = @x_a_length = nil  # leave @d as-is
        end

        attr_reader :as_ivar, :d, :default_x, :enum_box,
          :iambic_writer_method_name, :name_i, :has_default_x

        def apply_to_property_class pc
          _flsh = pc::Flusher.new.with_two( pc.singleton_class, pc )
          _flsh.add_property self
          ivar = @as_ivar
          enum = enum_box
          pc.send :attr_reader, @name_i
          if enum
            pc.send :define_method, @iambic_writer_method_name do
              x = iambic_property
              enum[ x ] or raise ::ArgumentError, say_bad_enum_value( x )
              instance_variable_set ivar, x
            end
          else
            pc.send :define_method, @iambic_writer_method_name do
              instance_variable_set ivar, iambic_property
            end
          end
          has_default_x and aply_defaulting_behavior_to_property_class pc
          nil
        end

      private

        def aply_defaulting_behavior_to_property_class pc
          pc.add_iambic_event_listener :at_end_of_process_iambic, -> prop do
            if prop.instance_variable_get( @as_ivar ).nil?
              prop.instance_variable_set @as_ivar, @default_x
            end
          end
        end

        Entity[ self, -> do

          def enum
            x = iambic_property
            bx = Box__.new
            x.each do |i|
              bx.add i, true
            end
            @enum_box = bx ; nil
          end

          def default
            @has_default_x = true
            @default_x = iambic_property
          end

        end ]
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

    # ~ experimental additions to entity core (BE CAREFUL!)

    module Proprietor_Methods__
      def add_iambic_event_listener i, p
        ( @iambic_event_muxer ||= Muxer__.new ).add i, p ; nil
      end
      attr_reader :iambic_event_muxer
    end

    module Iambic_Methods__
      def clear_all_iambic_ivars
        @d = @x_a = @x_a_length = nil
        UNDEFINED_
      end

      remove_method :emit_iambic_event
      def emit_iambic_event i
        notificate i
      end

      def notificate i
        muxer = self.class.iambic_event_muxer and muxer.mux i, self
        super
      end
    end

    if ! ::Object.method_defined?( :notificate )
      class ::Object
        def notificate i  # :+[#sl-131] the easiest implementation for this
        end
      end
    end

    UNDEFINED_ = nil
  end
end
