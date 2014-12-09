module Skylab::Brazen

  module Entity

    module Meta_Property__

        def when_enum_box pc, _ENUM_BOX
          pc.include Meta_Prop_IMs__
          _IVAR = @as_ivar ; _NAME_I = @name_i
          pc.send :define_method, @iambic_writer_method_name do
            x = iambic_property
            if _ENUM_BOX[ x ]
              instance_variable_set _IVAR, x
              ACHIEVED_
            else
              when_bad_enum_value x, _NAME_I, _ENUM_BOX
              UNABLE_
            end
          end
        end

        def aply_defaulting_behavior_to_property_class pc
          pc.add_iambic_event_listener :at_end_of_process_iambic, -> prop do
            if ! prop.instance_variable_defined?( @as_ivar ) ||
                prop.instance_variable_get( @as_ivar ).nil?
              prop.instance_variable_set @as_ivar, @default_x
            end
          end
        end

          def default
            @has_default_x = true
            @default_x = iambic_property
          end

          def entity_class_hook
            @entity_class_hook_p = iambic_property
          end

          def entity_class_hook_once
            @entity_class_hook_once_p = iambic_property
          end

          def enum
            x = iambic_property
            bx = Box_.new
            x.each do |i|
              bx.add i, true
            end
            @enum_box = bx ; nil
          end

          def property_hook
            @property_hook_p = iambic_property
          end


      module Meta_Prop_IMs__
      private
        def when_bad_enum_value x, name_i, enum_box
          maybe_send_event :error, :invalid_property_value do
            bld_invalid_property_value_event x, name_i, enum_box
          end
        end

        def bld_invalid_property_value_event x, name_i, enum_box
          build_not_OK_event_with :invalid_property_value,
            :x, x, :name_i, name_i,
            :enum_box, enum_box,
            :error_category, :argument_error do |y, o|
              _a = o.enum_box.get_names
              y << "invalid #{ o.name_i } #{ ick o.x }, #{
               }expecting { #{ _a * ' | ' } }"
          end
        end
      end

      module Muxer
        class << self
          def [] cls, const_i, write_i
            cls.send :define_method, write_i, bld_write_meth( const_i )
            nil
          end
          def bld_write_meth const_i
            p = cury_touch_proc const_i
            -> do
              p[ self ]
            end
          end
          def cury_touch_proc const_i
            -> reader do
              if reader.const_defined? const_i, false
                reader.const_get const_i, false
              else
                _MUXER_ = Muxer__.new
                reader.const_set const_i, _MUXER_
                if reader.respond_to? :method_added_mxr and
                    mxr = reader.method_added_mxr
                  mxr.stop_listening  # kind of ick for now
                end
                reader.send :define_method, :notificate do |i|
                  _MUXER_.mux i, self
                  super i
                end
                mxr and mxr.resume_listening
                _MUXER_
              end
            end
          end
          define_method :for, Muxer.cury_touch_proc( :IAMBIC_EVENT_MUXER__ )
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

        def when_no_def
          maybe_receive_event :error, :expected_method_definition do
            bld_expected_method_definition_event
          end
        end

        def bld_expected_method_definition_event
          build_not_OK_event_with :expected_method_definition,
              :error_category, :argument_error do |y, o|
            y << "expected method definition at end of iambic input"
          end
        end

        def iambic_keyword i
          if i == current_iambic_token
            advance_iambic_stream_by_one
            ACHIEVED_
          else
            when_not_iambic_keyword i
          end
        end

        def when_not_iambic_keyword i
          maybe_receive_event :error, :expecting_keyword do
            bld_maybe_expecting_keyword_event i
          end
        end

        def bld_maybe_expecting_keyword_event i
          build_not_OK_event_with :expecting_keyword,
              :keyword, i,
              :x, current_iambic_token,
              :error_category, :argument_error do |y, o|
            y << "expected #{ code o.keyword } not #{ ick o.x }"
          end
        end

        def build_not_OK_event_with * x_a, & p
          Brazen_.event.inline_not_OK_via_mutable_iambic_and_message_proc x_a, p
        end

        def maybe_receive_event *, & ev_p
          raise ev_p[].to_exception
        end

      # ~ entity class hooks

      class Hook_Shell
        def initialize pclass
          @pclass = pclass
          @eaches_and_onces = @props = nil
        end
        attr_reader :props
        def add_hook hook_variety_i, metaprop_i, p
          send :"add_#{ hook_variety_i }_hook", metaprop_i, p ; nil
        end
      private
        def add_each_hook mp_i, p
          add_hook_o mp_i, Hook__.new( :each, p )
        end
        def add_once_hook mp_i, p
          add_hook_o mp_i, Hook__.new( :once, p )
        end
        def add_hook_o i, o
          ( @eaches_and_onces ||= Box_.new ).set i, o ; nil
        end
        def add_prop_hook mp_i, p
          ( @props ||= Box_.new ).add mp_i, p ; nil
        end
      public
        def process_relevant_later_hooks reader, prop
          if @eaches_and_onces
            hook_a = partition_relevant_hooks reader, prop
            if hook_a
              hook_a.each do |hook|
                hook.p[ prop, reader ]
              end ; nil
            end
          end
        end
      private
        def partition_relevant_hooks reader, prop
          box = @eaches_and_onces ; scn = box.to_key_scan
          i = scn.gets ; a = nil
          begin
            prop.send( i ).nil? and next  # or whatever
            hook = box.fetch i
            case hook.variety_i
            when :each
              ( a ||= [] ).push hook
            when :once
              reader.property_scope_krnl.
                listener_box_for_eventpoint( :at_end_of_scope ).
                  add_if_not_has i do
                    p = hook.p
                    -> { p[ reader ] }
                  end
            end
          end while (( i = scn.gets ))
          a
        end
      end

      Hook__ = ::Struct.new :variety_i, :p


    end
  end
end
