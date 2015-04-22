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

      Brazen_::API::Produce_bound_call__[ x_a, self, @module ]
    end

    def call_via_mutable_box * i_a, bx, & x_p  # [sg]

      bc = bound_call_via_mutable_box i_a, bx, & x_p

      bc and bc.receiver.send bc.method_name, * bc.args
    end

    def bound_call_via_mutable_box i_a, bx, & x_p  # [bs] only so far

      Brazen_::API::Produce_bound_call__.start_via_iambic_and_mutable_box(
        i_a,
        bx,
        self,
        & x_p ).produce_bound_call
    end

    # ~ client exposures

    def to_kernel
      self  # the top
    end

    def kernel_
      self
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
        const_i_a = box_mod.constants
        const_i_a.sort!
        d = const_i_a.length
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

    def silo sym, & oes_p  # (was `silo_via_symbol`)
      silo_via_identifier Node_Identifier_.via_symbol( sym ), & oes_p
    end

    def silo_via_identifier id, & oes_p

      if id.is_resolved

        @silo_cache[].__fetch_via_identifier[ id ]
      else
        __silo_via_unresolved_id id, & oes_p
      end
    end

    def __silo_via_unresolved_id id, & oes_p  # #note-40, :+[#mh-002]

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

          cls = node.const_get :Silo_Daemon, false  # one of #two

          if cls
            id.bake node
            x = @silo_cache[].__touch_via_SD_class_and_identifier[ cls, id ]
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

      Brazen_.event.inline_with :node_not_found,
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

        @__fetch_via_identifier = -> id do

          cache_h.fetch id.silo_name_i
        end

        @__fetch_via_normal_identifier_component = -> const do

          sym = const.downcase

          cache_h.fetch sym do

            unbound = models_mod.const_get const, false

            x = unbound.const_get( :Silo_Daemon, false ).
              new kernel, unbound  # two of #two

            cache_h[ sym ] = x
            x
          end
        end

        @__touch_via_SD_class_and_identifier = -> cls, id do

          cache_h.fetch id.silo_name_i do
            x = cls.new kernel, id.value
            cache_h[ id.silo_name_i ] = x
            x
          end
        end
      end

      attr_reader :__fetch_via_identifier,
        :__fetch_via_normal_identifier_component,
        :__touch_via_SD_class_and_identifier
    end
  end

  SILO_DAEMON_FILE___ = "silo-daemon#{ Autoloader_::EXTNAME }"

  Kernel::Node_Identifier__ = class Node_Identifier_  # :[#022].

    class << self

      def via_name_function nf, x
        new do
          @is_resolved = true
          @kernel = Via_Name_Function__.new nf, x
        end
      end

      def via_symbol i
        new do
          @is_resolved = false
          @kernel = Mutable_For_Resolving__.new i
        end
      end

      def via_string_and_frozen_silo_name_parts s, i_a
        new do
          @is_resolved = false
          @kernel = Literal__.new s, i_a
        end
      end
    end

    attr_reader :is_resolved

    def initialize & p
      instance_exec( & p )
    end

    def members
      [ :description, :entity_name_s, :full_name_i,
        :name_parts, :raw_name_parts,
        :silo_description, :silo_name_i, :silo_name_parts,
        :silo_slug, :value ]
    end

    def description
      _s = silo_description
      _s_ = entity_name_s
      [ _s, _s_ ].compact.join SPACE_
    end

    def silo_description
      silo_name_parts.map do |i|
        i.id2name.gsub( UNDERSCORE_, DASH_ )
      end.join SPACE_
    end

    def full_name_i
      @kernel.full_name_i
    end

    def silo_name_i
      @kernel.silo_name_i
    end

    def silo_slug
      @kernel.silo_slug
    end

    def entity_name_s  # where available
      @kernel.entity_name_s
    end

    def raw_name_parts
      @kernel.raw_name_parts
    end

    def name_parts
      @kernel.name_parts
    end

    def silo_name_parts
      @kernel.silo_name_parts
    end

    def value
      @kernel.value
    end

    def with_local_entity_identifier_string s
      i_a = name_parts
      if i_a
        if entity_name_s
          i_a = i_a[ 0 .. -2 ].freeze
        end
        self.class.via_string_and_frozen_silo_name_parts s, i_a
      end
    end

    def as_mutable_for_resolving
      @kernel = @kernel.as_mutable_for_resolving
      self
    end

    def add_demarcation_index d
      @kernel.add_demarcation_index d
    end

    def bake x
      @is_resolved = true
      @kernel = @kernel.bake x ; nil
    end

    class Identifier_Kernel__
      attr_reader :full_name_i, :name_parts, :silo_name_i, :value

      def silo_slug
        @ss ||= ( i = silo_name_i and i.to_s.gsub( UNDERSCORE_, DASH_ ).freeze )
      end
    end

    class Mutable_For_Resolving__ < Identifier_Kernel__

      def initialize i, s=nil
        @silo_name_i = nil
        @entity_name_s = s
        @full_name_i = i
      end

      attr_reader :entity_name_s

      def raw_name_parts
        @rnp ||= @full_name_i.id2name.split UNDERSCORE_
      end

      def as_mutable_for_resolving
        self
      end

      def add_demarcation_index d
        ( @d_a ||= [] ).push d ; nil
      end

      def silo_name_i
        if @silo_name_i
          @silo_name_i
        else
          @full_name_i
        end
      end

      def silo_name_parts
        @name_parts
      end

      def bake x
        begin_d = 0
        @d_a.freeze
        @name_parts = @d_a.map do | begin_next_d |
          i = ( @rnp[ begin_d ... begin_next_d ] * UNDERSCORE_ ).intern
          begin_d = begin_next_d
          i
        end.freeze
        if @rnp.length > begin_d
          @entity_name_s and self._SANITY
          @entity_name_s = ( @rnp[ begin_d .. -1 ] * UNDERSCORE_ )
        end
        @silo_name_i = ( @name_parts * UNDERSCORE_ ).intern
        @value = x
        self
      end
    end

    class Via_Name_Function__ < Identifier_Kernel__

      def initialize nf, value
        np_a = []
        while true
          np_a.push nf.as_variegated_symbol
          par = nf.parent
          par or break
          nf = par.name_function
        end
        np_a.reverse!
        @name_parts = np_a.freeze
        @silo_name_i = ( @name_parts * UNDERSCORE_ ).intern
        @full_name_i = @silo_name_i
        @value = value
      end

      def entity_name_s
      end

      def silo_name_parts
        @name_parts
      end
    end

    class Literal__ < Identifier_Kernel__

      def initialize s, i_a
        @entity_name_s = s.dup.freeze
        @i_a = i_a
      end

      attr_reader :entity_name_s

      def name_parts
        @np ||= @i_a.dup.push( @entity_name_s ).freeze
      end

      def silo_name_i
        @sni ||= @i_a.join( UNDERSCORE_ ).intern
      end

      def silo_name_parts
        @i_a
      end

      def full_name_i
        @fni ||= name_parts.join( UNDERSCORE_ ).intern
      end

      def as_mutable_for_resolving  # #watching [#036]
        Mutable_For_Resolving__.new @i_a.join( UNDERSCORE_ ).intern, @entity_name_s
      end
    end

    self
  end
end
