module Skylab::Brazen

  class Kernel_  # [#015]

    def initialize mod
      @module = mod
      @models_mod = mod.const_get :Models_, false
      @nm = nil
    end

    def members
      [ :app_name, :debug_IO, :module, :silo ]
    end

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
      @module::API.debug_IO
    end

    attr_reader :module

    def call * x_a, & x_p  # #note-25

      bc = _bound_API_call_via_iambic x_a, & x_p

      bc and bc.receiver.send bc.method_name, * bc.args
    end

    def bound_API_call_with * x_a, & x_p
      _bound_API_call_via_iambic x_a, & x_p
    end

    def _bound_API_call_via_iambic x_a, & x_p

      @module.const_get( :API, false )._API_daemon.
        produce_bound_call_via_mutable_iambic x_a, & x_p
    end

    def to_unbound_action_stream
      _to_model_stream.expand_by do | item |
        if item.respond_to? :to_upper_unbound_action_stream
          item.to_upper_unbound_action_stream
        else
          dflt_upper_unbound_action_stream_via_item item
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

    private def dflt_upper_unbound_action_stream_via_item item  # experiment #open [#067]
      box_mod = const_i_a = d = p = nil
      main = -> do
        begin
          if d.zero?
            p = EMPTY_P_[]
            break
          end
          d -= 1
          unb = box_mod.const_get const_i_a.fetch d

          if unb.respond_to? :is_promoted
            if unb.is_promoted
              x = unb
              break
            end
          else

            # assume proc and for now all procs are treated as promoted (here)

            x = Brazen_::Model_::Node_via_Proc.produce_action_class_like(
              unb,
              const_i_a.fetch( d ),
              box_mod )

            break
          end

          redo
        end while nil
        x
      end
      p = -> do
        box_mod = item::Actions
        const_i_a = box_mod.constants
        const_i_a.sort!
        d = const_i_a.length
        p = main
        p[]
      end
      ( Callback_.stream do
        p[]
      end )
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
          modish = try_convert_to_node_like_via_mixed x, i, @models_mod
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

    def try_convert_to_node_like_via_mixed x, i, mod
      if x.respond_to? :call
        Brazen_::Model_::Node_via_Proc.produce_nodelike x, i, mod
      end
    end

  public  # ~ silo production

    def model_class const_sym
      @models_mod.const_get const_sym, false
    end

    def model_class_via_identifier id, & oes_p
      silo = silo_via_identifier id, & oes_p
      silo and silo.model_class
    end

    def silo sym, & oes_p  # (was `silo_via_symbol`)
      silo_via_identifier Node_Identifier_.via_symbol( sym ), & oes_p
    end

    def silo_via_identifier id, & oes_p
      if id.is_resolved
        prdc_silo id
      else
        cols_via_unresolved_id id, & oes_p
      end
    end

  private

    def cols_via_unresolved_id id, & oes_p
      id = id.as_mutable_for_resolving
      node = self ; mod_a = nil
      full_raw_s_a = id.raw_name_parts
      index = -1 ; last = full_raw_s_a.length - 1
      while index != last
        index += 1
        target_s = full_raw_s_a.fetch index
        if ! mod_a
          mod_a = some_modules_array_via_mod node
          local_index = -1
        end
        local_index += 1
        reduce_search_space mod_a, local_index, target_s
        case 1 <=> mod_a.length
        when  0
          node = mod_a.fetch 0
          _num_parts = some_name_function_via_mod( node ).as_parts.length
          _start_of_next_part = index - local_index + _num_parts
          id.add_demarcation_index _start_of_next_part
          _is_silo =
          if node.respond_to? :is_silo
            node.is_silo
          else
            false
          end
          if _is_silo
            id.bake node
            result = prdc_silo id
            break
          else
            mod_a = nil
          end
        when  1
          result = oes_p.call :not_found do
            bld_model_not_found_event id, target_a
          end
          break
        when -1
          self._NEATO
        end
      end
      result
    end

    def reduce_search_space mod_a, local_index, target_s
      mod_a.each_with_index do |mod, d|
        s = some_name_function_via_mod( mod ).as_parts[ local_index ]
        if ! ( s and target_s == s )
          mod_a[ d ] = nil
        end
      end
      mod_a.compact! ; nil
    end

    def some_name_function_via_mod mod
      if mod.respond_to? :name_function
        mod.name_function
      else
        @mod_nf_h ||= {}
        @mod_nf_h.fetch mod do
          @mod_nf_h[ mod ] = Callback_::Name.via_module mod
        end
      end
    end

    def some_modules_array_via_mod mod
      if mod.respond_to? :to_node_stream
        mod.to_node_stream.to_a
      else
        box_mod = mod.const_get :Nodes, false
        box_mod.constants.map do |i|
          box_mod.const_get i, false
        end
      end
    end

    def prdc_silo id
      ( @touch_silo_p ||= bld_touch_silo_p )[ id ]
    end

    def bld_touch_silo_p
      cache_h = {}
      -> id do
        cache_h.fetch id.silo_name_i do
          id.value.const_get :Actions, false  # :+[#043] a loading hack
          silo = some_silo_via_mod id.value
          cache_h[ id.silo_name_i ] = silo
          silo
        end
      end
    end

    def some_silo_via_mod mod
      mod.silo_class.new self
    end

    def bld_model_not_found_event id, s
      Brazen_.event.inline_with :node_not_found,
        :token, s, :identifier, id
    end
  end

  Kernel_::Node_Identifier__ = class Node_Identifier_

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
