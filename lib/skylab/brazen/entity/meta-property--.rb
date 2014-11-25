module Skylab::Brazen

  module Entity

    class Meta_Property__

        def initialize scanner
          @scanner = scanner
          @entity_class_hook_p = @entity_class_hook_once_p =
            @property_hook_p = nil
          @has_default_x = false
          @name_i = iambic_property
          @as_ivar = :"@#{ @name_i }"
          @iambic_writer_method_name = :"#{ @name_i }="
          process_iambic_passively
          @last_iambic_idx = @scanner.current_index
          @scanner = nil
          freeze
        end

        attr_reader :as_ivar, :iambic_writer_method_name, :name_i,
          :has_default_x, :default_x,
          :enum_box

        def apply_to_property_class pc
          Scope_Kernel__.new( pc, pc.singleton_class ).accept_property self
          aply_iambic_writers_to_property_class pc
          @has_default_x and aply_defaulting_behavior_to_property_class pc
          @entity_class_hook_p and pc.hook_shell_for_write.add_hook(
            :each, @name_i, @entity_class_hook_p )
          @entity_class_hook_once_p and pc.hook_shell_for_write.add_hook(
            :once, @name_i, @entity_class_hook_once_p )
          @property_hook_p and pc.hook_shell_for_write.add_hook(
            :prop, @name_i, @property_hook_p )
          nil
        end

        class << self
          def hook_shell
          end
        end

      private

        def aply_iambic_writers_to_property_class pc
          enum = enum_box
          pc.send :attr_reader, @name_i
          if enum
            when_enum_box pc, enum
          else
            _IVAR = @as_ivar
            pc.send :define_method, @iambic_writer_method_name do
              instance_variable_set _IVAR, iambic_property
            end
          end
          nil
        end

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

        Entity[ self, -> do

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

        end ]
        include Via_Scanner_Iambic_Methods_


      module Meta_Prop_IMs__
      private
        def when_bad_enum_value x, name_i, enum_box
          _ev = build_not_OK_event_with :invalid_property_value,
            :x, x, :name_i, name_i,
            :enum_box, enum_box,
            :error_category, :argument_error do |y, o|
              _a = o.enum_box.get_names
              y << "invalid #{ o.name_i } #{ ick o.x }, #{
               }expecting { #{ _a * ' | ' } }"
          end
          receive_event _ev
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

      class Client_Kernel  # long-running, stays with module, stateless
        def initialize mod
          @reader = mod
        end

        def property_class_for_write_impl
          if @reader.property_scope_krnl.has_nonzero_length_iambic_queue
            @reader.property_scope_krnl.flush_iambic_queue
          end
          property_cls_for_wrt
        end

        def set_property_class x
          @reader.const_set :PROPERTY_CLASS__, x ; nil
        end

        def property_cls_for_wrt
          @reader.module_exec do
            if const_defined? :PROPERTY_CLASS__, false
              const_get :PROPERTY_CLASS__, false
            else
              cls = ::Class.new const_get( :PROPERTY_CLASS__, true )
              const_set :Property, cls
              const_set :PROPERTY_CLASS__, cls
            end
          end
        end
      end

      class Mprop_Scanner

        include Via_Scanner_Iambic_Methods_

        def initialize scope_kernel
          @scope_kernel = scope_kernel
        end

        def scan_some_DSL
          pcls = @scope_kernel.reader::PROPERTY_CLASS__
          @scanner = @scope_kernel.scanner
          ok = true
          pcls.new do |prop|
            ok = this_child_must_iambicly_scan_something prop
            ok &&= when_this_child_scanned_something prop
          end
          ok && @scope_kernel.finish_property
        end

      private

        def this_child_must_iambicly_scan_something o
          o.set_stream @scanner
          d = @scanner.current_index
          o.process_iambic_passively
          if d == @scanner.current_index
            when_child_did_not_scan_something
          else
            o.set_stream nil
            ACHIEVED_
          end
        end

        def when_child_did_not_scan_something
          _ev = via_current_token_build_extra_iambic_event
          receive_event _ev
          UNABLE_
        end

        def when_this_child_scanned_something o
          @scope_kernel.prop = o
          if unparsed_iambic_exists
            ok = iambic_keyword :property
            ok and @scope_kernel.flush_because_prop_i @scanner.gets_one
          else
            plan = @scope_kernel.plan
            if plan && plan.meth_i
              @scope_kernel.flush_bc_meth
            else
              when_no_def
            end
          end
        end

        def when_no_def
          _ev = build_not_OK_event_with :expected_method_definition,
              :error_category, :argument_error do |y, o|
            y << "expected method definition at end of iambic input"
          end
          receive_event _ev
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
          _ev = build_not_OK_event_with :expecting_keyword,
              :keyword, i,
              :x, current_iambic_token,
              :error_category, :argument_error do |y, o|
            y << "expected #{ code o.keyword } not #{ ick o.x }"
          end
          receive_event _ev
        end

        def build_not_OK_event_with * x_a, & p
          Brazen_.event.inline_not_OK_via_mutable_iambic_and_message_proc x_a, p
        end

        def receive_event ev
          _e = ev.to_exception
          raise _e
        end
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
