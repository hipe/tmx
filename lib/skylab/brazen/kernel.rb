module Skylab::Brazen

  class Kernel  # [#015]

    def initialize mod

      @models_mod = mod.const_get :Models_, false
      @module = mod
      @nm = nil
      @silo_cache = -> do
        x = Silo_Cache___.new @models_mod, self
        @silo_cache = -> { x }
        x
      end
    end

    def members
      [ :app_name, :bound_call_via_mutable_iambic, :debug_IO, :module, :silo ]
    end

    def models_module
      @models_mod
    end

    attr_reader :module

    # ~ call exposures

    def call * x_a, & x_p  # #note-25

      bc = bound_call_via_mutable_iambic x_a, & x_p

      bc and bc.receiver.send bc.method_name, * bc.args
    end

    def bound_call_via_mutable_iambic x_a, & oes_p

      if oes_p
        x_a.push :on_event_selectively, oes_p
      end

      Home_::API::Produce_bound_call__[ x_a, self, @module ]
    end

    def call_via_mutable_box * i_a, bx, & x_p  # [sg]

      bc = bound_call_via_mutable_box i_a, bx, & x_p

      bc and bc.receiver.send bc.method_name, * bc.args
    end

    def bound_call_via_mutable_box i_a, bx, & x_p  # [bs] only so far

      Home_::API::Produce_bound_call__.start_via_iambic_and_mutable_box(
        i_a,
        bx,
        self,
        & x_p ).produce_bound_call
    end

    # ~ client exposures

    def to_kernel
      self  # the top
    end

    def app_name
      ( if @nm
        @nm
      elsif @module.respond_to? :name_function
        @module.name_function
      else
        @nm = Callback_::Name.via_module @module
      end ).as_human
    end

    def do_debug
      # true
    end

    def debug_IO
      LIB_.system.IO.some_stderr_IO  # etc
    end

    # ~ "unbound" ( e.g model class ) production

    def unbound_via_normal_identifier const_a

      unbound_via_normal_stream Callback_::Polymorphic_Stream.new( 0, const_a )
    end

    def unbound_via_normal_stream st

      const = st.gets_one
      if st.unparsed_exists
        unbound( const ).unbound_via_normal_stream st
      else
        unbound const
      end
    end

    def unbound_via_identifier id, & oes_p

      silo = silo_via_identifier id, & oes_p
      silo and silo.model_class
    end

    def unbound const_sym
      @models_mod.const_get const_sym, false
    end

    def to_unbound_action_stream

      _to_model_stream.expand_by do | item |
        if item.respond_to? :to_upper_unbound_action_stream
          item.to_upper_unbound_action_stream
        else
          __default_upper_unbound_action_stream_via_item item
        end
      end
    end

    def unbound_action_via_normalized_name i_a

      i_a.reduce self do |m, i|
        scn = m.to_unbound_action_stream
        while cls = scn.gets
          _i = cls.name_function.as_lowercase_with_underscores_symbol
          i == _i and break( found = cls )
        end
        found or raise ::KeyError, "not found: #{ i } in #{ m }"
      end
    end

    def __default_upper_unbound_action_stream_via_item item  # experiment #open [#067]

      box_mod = const_i_a = d = p = main = nil

      p = -> do

        box_mod = item::Actions

        if box_mod
          const_i_a = box_mod.constants
          const_i_a.sort!
          d = const_i_a.length
        else
          d = 0
        end
        p = main
        p[]
      end

      has_non_promoted_children = false
      main = -> do
        begin

          if d.zero?

            if has_non_promoted_children

              x = if item.respond_to? :is_branch
                item

              else
                Proxies_::Module_As::Unbound_Model.new item

              end
            end

            p = EMPTY_P_
            break
          end
          d -= 1
          unb = box_mod.const_get const_i_a.fetch d

          if unb.respond_to? :is_promoted
            if unb.is_promoted
              x = unb
              break
            else
              has_non_promoted_children = true
            end
          else

            # assume proc which is [#065] never treated as promoted
            has_non_promoted_children = true

          end

          redo
        end while nil
        x
      end

      Callback_.stream do
        p[]
      end
    end

    def bound_action_via_unbound_action_bound_to cls, & oes_p
      cls.new self, & oes_p
    end

    def to_node_stream
      _to_model_stream
    end

  private

    def _to_model_stream

      @const_i_a ||= prdc_sorted_const_i_a

      d = -1 ; last = @const_i_a.length - 1

      Callback_.stream do
        while d < last
          d += 1
          i = @const_i_a.fetch d
          x = @models_mod.const_get i, false

          if x.respond_to? :name
            modish = x
            break
          end

          modish = __try_convert_to_unbound_node_via_mixed x, i, @models_mod
          modish and break
        end
        modish
      end
    end

    def prdc_sorted_const_i_a
      i_a = @models_mod.constants
      i_a.sort!  # #note-35
      i_a
    end

    def __try_convert_to_unbound_node_via_mixed x, i, mod

      if x.respond_to? :call

        Proxies_::Proc_As::Unbound_Action.new x, i, mod, @module
      end
    end

  public  # ~ silo production

    def silo_via_normal_identifier const_a

      silo_via_normal_stream Callback_::Polymorphic_Stream.new( 0, const_a )
    end

    def silo_via_normal_stream st

      x = @silo_cache[].__fetch_via_normal_identifier_component[ st.gets_one ]
      if st.unparsed_exists
        x = x.silo_via_normal_stream st
      end
      x
    end

    def silo sym, & x_p  # (was `silo_via_symbol`)

      silo_via_identifier(
        Concerns_::Identifier.via_symbol( sym ),
        & x_p )
    end

    def silo_via_identifier id, & oes_p

      if id.is_resolved

        @silo_cache[]._touch_via_silo_daemon_class_and_identifier[
          id.value.const_get( SILO_DAEMON_CONST__, false ),
          id ]
      else
        __silo_via_unresolved_id id, & oes_p
      end
    end

    def __silo_via_unresolved_id id, & oes_p  # #note-40, :+[#pa-002]

      id = id.as_mutable_for_resolving

      full_raw_s_a = id.raw_name_parts

      index = -1
      last = full_raw_s_a.length - 1
      mod_a = nil
      node = self

      while index != last

        index += 1
        target_s = full_raw_s_a.fetch index

        if ! mod_a
          mod_a = __some_modules_array_via_mod node
          local_index = -1
        end

        local_index += 1
        __reduce_search_space mod_a, local_index, target_s

        case 1 <=> mod_a.length

        when  0
          node = mod_a.fetch 0
          _num_parts = _some_name_function_via_mod( node ).as_parts.length
          _start_of_next_part = index - local_index + _num_parts
          id.add_demarcation_index _start_of_next_part

          cls = node.const_get SILO_DAEMON_CONST__, false

          if cls
            id.bake node
            x = @silo_cache[]._touch_via_silo_daemon_class_and_identifier[ cls, id ]
            break
          end
          mod_a = nil

        when  1
          x = __when_not_found id, target_s, & oes_p
          break

        when -1
          # #note-265 - although it is a class of use cases for which this..
          NIL_
        end
      end
      x
    end

    def __when_not_found id, target_s, & oes_p

      if oes_p
        oes_p.call :not_found do
          _build_model_not_found_event id, target_s
        end
      else
        raise _build_model_not_found_event( id, target_s ).to_exception
      end
    end

    def _build_model_not_found_event id, s

      Callback_::Event.inline_with :node_not_found,
        :token, s, :identifier, id,
        :error_category, :name_error
    end

    def __reduce_search_space mod_a, local_index, target_s

      mod_a.each_with_index do |mod, d|
        s = _some_name_function_via_mod( mod ).as_parts[ local_index ]
        if ! ( s and target_s == s )
          mod_a[ d ] = nil
        end
      end
      mod_a.compact! ; nil
    end

    def _some_name_function_via_mod mod

      if mod.respond_to? :name_function
        mod.name_function
      else
        @mod_nf_h ||= {}
        @mod_nf_h.fetch mod do
          @mod_nf_h[ mod ] = Callback_::Name.via_module mod
        end
      end
    end

    def __some_modules_array_via_mod mod

      if mod.respond_to? :to_node_stream
        mod.to_node_stream.to_a
      else
        box_mod = mod.const_get :Nodes, false
        box_mod.constants.map do |i|
          box_mod.const_get i, false
        end
      end
    end

    class Silo_Cache___

      def initialize models_mod, kernel

        cache_h = {}

        @__fetch_via_normal_identifier_component = -> const do

          sym = const.downcase

          cache_h.fetch sym do

            unbound = models_mod.const_get const, false

            x = unbound.const_get( SILO_DAEMON_CONST__, false ).
              new kernel, unbound  # two of #two

            cache_h[ sym ] = x
            x
          end
        end

        @_touch_via_silo_daemon_class_and_identifier = -> cls, id do

          cache_h.fetch id.silo_name_symbol do
            x = cls.new kernel, id.value
            cache_h[ id.silo_name_symbol ] = x
            x
          end
        end
      end

      attr_reader(
        :__fetch_via_normal_identifier_component,
        :_touch_via_silo_daemon_class_and_identifier,
      )
    end
  end

  SILO_DAEMON_CONST__ = :Silo_Daemon
  SILO_DAEMON_FILE___ = "silo-daemon#{ Autoloader_::EXTNAME }"
end
