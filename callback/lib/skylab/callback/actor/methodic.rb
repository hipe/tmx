module Skylab::Callback

  module Actor

    module Methodic  # see [#058]

      class << self

        def cache_polymorphic_writer_methods * a, & p
          Cache_polymorphic_writer_methods__.call( * a, & p )
        end

        def polymorphic_processing_instance_methods
          Polymorphic_Processing_Instance_Methods__
        end

        def call cls, * i_a
          edit_module_via_iambic cls, i_a
        end

        def edit_module_via_iambic cls, i_a
          cls.extend Module_Methods__
          cls.include Polymorphic_Processing_Instance_Methods__
          if i_a.length.zero?
            cls
          else
            Edit_via_nonzero_length_iambic_on_prepared_class__[ i_a, cls ]
          end
        end
      end  # >>

      module Edit_via_nonzero_length_iambic_on_prepared_class__

        class << self

          def [] i_a, cls
            sym = i_a.first
            start_index = 1
            begin
              case sym
              when :simple
                Apply_simple_enhancement__.new(
                  cls,
                  Polymorphic_Stream.via_start_index_and_array( 1, i_a )
                ).execute
              when :properties
                __apply_seed_treatment start_index, cls, i_a
              when :property_list
                __apply_seed_treatment 0, cls, i_a.fetch( start_index )
                if ( start_index += 1 ) < i_a.length
                  sym = i_a.fetch( start_index + 1 )
                  start_index += 2
                  redo
                end
              else
                raise Stranger_[ i_a.first, [ :properties, :simple ] ].to_exception
              end
            end while nil
          end

          def __apply_seed_treatment start_index, mod, i_a

            mod.module_exec do

              if const_defined? BX_
                bx = const_get BX_
                if const_defined? BX_, false
                  sym_a = bx.a_
                else
                  bx = bx.dup
                  const_set BX_, bx
                  sym_a = bx.a_
                end
              else
                sym_a = []
                const_set BX_, Box_Lite___.new( sym_a )  # :+#experiment
              end

            private

              start_index.upto( i_a.length - 1 ) do |d|

                sym = i_a.fetch d
                sym_a.push sym
                _IVAR = :"@#{ sym }"

                define_method :"#{ sym }=" do
                  instance_variable_set _IVAR, gets_one_polymorphic_value
                  KEEP_PARSING_
                end
              end
            end
            NIL_
          end
        end  # >>
      end

      Box_Lite___ = ::Struct.new :a_ do

        def initialize_copy otr
          self.a_ = otr.a_.dup
        end
      end

      module Module_Methods__

        # ~ ways to call your actor (pursuant to [#bs-028.A] name conventions)

        def with * x_a, & oes_p
          call_via_polymorphic_stream polymorphic_stream_via_iambic( x_a ), & oes_p
        end

        def call_via_arglist a, & oes_p
          curried = new_via_arglist a, & oes_p
          curried && curried.execute
        end

        def call_via_iambic x_a, & oes_p
          call_via_polymorphic_stream polymorphic_stream_via_iambic( x_a ), & oes_p
        end

        def call_via_polymorphic_stream st, & oes_p
          curried = new_via_polymorphic_stream st, & oes_p
          curried && curried.execute
        end

        # ~ ways to build a "curried" actor
        #
        #   ( near [#sl-023] the "dup and mutate" patttern, to use these
        #     crosses the abstraction boundary of "simple actor" and you
        #     become a collaborator with subject. )

        def new_via_arglist a, & oes_p
          ok = nil
          o = new do
            if oes_p
              @on_event_selectively ||= oes_p
            end
            ok = process_arglist_fully a
          end
          ok && o
        end

        def new_with * x_a, & oes_p
          new_via_polymorphic_stream polymorphic_stream_via_iambic( x_a ), & oes_p
        end

        def new_via_iambic x_a, & oes_p
          new_via_polymorphic_stream polymorphic_stream_via_iambic( x_a ), & oes_p
        end

        def new_via_polymorphic_stream st, & oes_p
          ok = nil
          x = new do
            oes_p and accept_selective_listener_proc oes_p  # :+#public-API :+#hook-out #hook-near
            ok = process_polymorphic_stream_fully st
          end
          ok && x
        end

        def new_via_polymorphic_stream_passively st, & oes_p
          ok = nil
          x = new do
            oes_p and accept_selective_listener_proc oes_p  # same as above
            ok = process_polymorphic_stream_passively st
          end
          ok && x
        end

        def polymorphic_stream_via_iambic x_a
          Polymorphic_Stream.via_array x_a
        end

        # ~ experiment (looks like [br] `edit_entity_class`)

        def edit_actor_class * x_a
          Edit_via_nonzero_length_iambic_on_prepared_class__[ x_a, self ]
        end

        # (experimental features near here exist in: [#br-081])
      end

      module Polymorphic_Processing_Instance_Methods__

      private

        def process_arglist_fully a  # :+#experiment, seed properties only

          process_polymorphic_stream_fully Polymorphic_Stream_via_Arglist___.new(
            a, self.class.const_get( BX_ ).a_ )
        end

        def process_iambic_fully x_a
          process_polymorphic_stream_fully polymorphic_stream_via_iambic x_a
        end

        def polymorphic_stream_via_iambic x_a
          Polymorphic_Stream.via_array x_a
        end

        def process_polymorphic_stream_fully stream  # :+#public-API :+#hook-in

          kp = process_polymorphic_stream_passively stream
          if kp
            if stream.no_unparsed_exists
              ACHIEVED_
            else
              when_after_process_iambic_fully_stream_has_content stream
            end
          else
            kp
          end
        end

        def polymorphic_upstream
          @polymorphic_upstream_
        end

        def process_polymorphic_stream_passively st, & oes_p

          Process_polymorphic_stream_passively[
            st,
            self,
            polymorphic_writer_method_name_passive_lookup_proc,
            & oes_p ]
        end

        def against_iambic_property no_p=nil  # experimental, :+#public-API
          if @polymorphic_upstream_.unparsed_exists
            yield gets_one_polymorphic_value
          elsif no_p
            no_p[]
          else
            maybe_send_event :error, :missing_required_properties do
              bld_missing_required_properties_event
            end
          end
        end

        def bld_missing_required_properties_event
          build_not_OK_event_with :missing_required_properties,
              :previous_token, @polymorphic_upstream_.previous_token,
              :error_category, :argument_error do |y, o|

            y << "expecting a value for #{ code o.previous_token }"
          end
        end

        def gets_one_polymorphic_value  # :+#public-API #hook-in
          @polymorphic_upstream_.gets_one
        end

        def polymorphic_writer_method_name_passive_lookup_proc  # :+#public-API #hook-in
          Method_name_proc_via_class__[ self.class ]
        end

        def when_after_process_iambic_fully_stream_has_content stream  # :+#public-API

          _ev = build_extra_values_event [ stream.current_token ]
          receive_extra_values_event _ev
        end

        def build_extra_values_event name_i_a, did_you_mean_i_a=nil

          Build_extra_values_event[ name_i_a, did_you_mean_i_a ]
        end

        def build_not_OK_event_with * i_a, & msg_p
          Home_::Event.inline_not_OK_via_mutable_iambic_and_message_proc i_a, msg_p
        end

        def receive_extra_values_event ev  # :+#public-API (name) :+#hook-in
          raise ev.to_exception
        end
      end

      Process_polymorphic_stream_fully = -> st, o, & oes_p do

        _meth_p = Method_name_proc_via_class__[ o.singleton_class ]

        kp = Process_polymorphic_stream_passively[ st, o, _meth_p, & oes_p ]
        if kp
          if st.unparsed_exists
            raise Stranger_[ st.current_token ].to_exception
          else
            ACHIEVED_
          end
        else
          kp
        end
      end

      Process_polymorphic_stream_passively = -> st, o, meth_p=nil, & oes_p do

        keep_parsing = true

        if st.unparsed_exists

          meth_p ||= Method_name_proc_via_class__[ o.class ]
          meth = meth_p[ st.current_token ]
          if meth

            o.instance_variable_set :@polymorphic_upstream_, st

            o.instance_variable_set(
              :@__methodic_actor_handle_event_selectively__,
              oes_p )  # for [br] in one place

            begin
              st.advance_one
              keep_parsing = o.send meth
              keep_parsing or break
              st.unparsed_exists or break
              meth = meth_p[ st.current_token ]
              meth or break
              redo
            end while nil

            o.remove_instance_variable :@polymorphic_upstream_
            o.remove_instance_variable :@__methodic_actor_handle_event_selectively__
          end
        end

        keep_parsing
      end

      Method_name_proc_via_class__ = -> cls do

        -> name_symbol do

          meth = :"#{ name_symbol }="

          if cls.private_method_defined? meth
            meth
          end
        end
      end

      class Polymorphic_Stream_via_Arglist___  # :+[#046]

        def initialize a, sym_a

          @d = 0
          @len = sym_a.length

          p = key_p = -> do
            sym_a.fetch @d
          end

          val_p = -> do
            a.fetch @d
          end

          advance_whey_val = nil
          advance = advance_when_key = -> do
            p = val_p
            advance = advance_whey_val
            NIL_
          end

          advance_whey_val = -> do
            p = key_p
            advance = advance_when_key
            @d += 1
            NIL_
          end

          @advance = -> do
            advance[]
          end

          @current = -> do
            p[]
          end
        end

        def no_unparsed_exists
          @d >= @len
        end

        def unparsed_exists
          @d < @len
        end

        def gets_one
          x = @current[]
          @advance[]
          x
        end

        def current_token
          @current[]
        end

        def advance_one
          @advance[]
        end
      end

      class Property  # :+[#fi-001]

        Actor.methodic self, :properties,
          :ivar,
          :parameter_arity

        class << self

          def via_polymorphic_stream stream, & oes_p  # :+public-API  #hook-in
            name_was_reached = false
            keep_parsing = nil
            ok = nil
            x = new do
              @name = nil
              keep_parsing = process_polymorphic_stream_passively stream, & oes_p
              @name and name_was_reached = true
              if name_was_reached || keep_parsing
                ok = normalize_property
              end
            end
            if name_was_reached
              ok && x
            elsif keep_parsing
              if ok
                if oes_p
                  oes_p.call :no_name do
                    x
                  end
                else
                  raise bld_parse_fail_event( stream ).to_exception
                end
              else
                ok
              end
            else
              keep_parsing
            end
          end

        private

          def bld_parse_fail_event stream
            Stranger_[
              ( stream.unparsed_exists && stream.current_token ),
              [ :property ] ]
          end
        end  # >>

        def initialize & edit_p
          @argument_arity = nil
          @parameter_arity = :zero_or_one
          instance_exec( & edit_p )
          @argument_arity ||= :one
          freeze
        end

        attr_reader :argument_arity, :ivar, :name, :parameter_arity

        def members
          [ :argument_arity, :ivar, :name, :name_symbol, :parameter_arity ]
        end

        def new_with * x_a
          otr = _new_or_dup_with_iambic x_a
          otr && otr.freeze
        end

        def dup_with * x_a
          _new_or_dup_with_iambic x_a
        end

        def _new_or_dup_with_iambic x_a
          otr = dup
          ok = nil
          otr.instance_exec do
            ok = process_iambic_fully x_a
          end
          ok && otr
        end

      private

        def argument_arity=
          x = gets_one_polymorphic_value
          @argument_arity = x
          if :custom == x
            @has_custom_polymorphic_writer_method = true
            @polymorphic_writer_method_proc_proc = nil
          end
          KEEP_PARSING_
        end

        def ignore=
          @parameter_arity = nil
          KEEP_PARSING_
        end

        def property=
          @name = Home_::Name.via_variegated_symbol gets_one_polymorphic_value
          STOP_PARSING_
        end

        def required=
          @parameter_arity = :one
          KEEP_PARSING_
        end

      public

        def description  # play nice with :+[#cb-110]
          "«property#{ ":#{ @name.as_slug }" if @name }»"  # :+#guillemets
        end

        def name_symbol
          @name.as_variegated_symbol
        end

        def as_ivar
          ivar || @name.as_ivar
        end

        attr_reader :default_proc  # :+#hook-in-esque. the ivar is not set here

        def polymorphic_writer_method_proc

          if ! has_custom_polymorphic_writer_method
            if @parameter_arity
              send :"polymorphic_writer_method_proc_when_arity_is__#{ @argument_arity }__"
            else
              IAMBIC_WRITER_METHOD_BODY_WHEN_IGNORE_H__.fetch @argument_arity
            end
          elsif @polymorphic_writer_method_proc_proc
            @polymorphic_writer_method_proc_proc[ self ]
          end
        end

        attr_reader :has_custom_polymorphic_writer_method

      private

        def polymorphic_writer_method_proc_when_arity_is__one__
          _IVAR = as_ivar
          -> do
            instance_variable_set _IVAR, gets_one_polymorphic_value
            KEEP_PARSING_
          end
        end

        def polymorphic_writer_method_proc_when_arity_is__zero__
          _IVAR = as_ivar
          -> do
            instance_variable_set _IVAR, true
            KEEP_PARSING_
          end
        end

        def normalize_property
          ACHIEVED_
        end
      end

      IAMBIC_WRITER_METHOD_BODY_WHEN_IGNORE_H__ = {
        zero: -> do
          ACHIEVED_
        end,
        one: -> do
          gets_one_polymorphic_value
          ACHIEVED_
        end
      }.freeze

      class Apply_simple_enhancement__

        def initialize cls, polymorphic_stream
          @cls = cls
          @cls.extend Proprietor_Module_Methods__
          @cls.include Proprietor_Instance_Methods__
          @polymorphic_stream = polymorphic_stream
        end

        def execute
          stream = @polymorphic_stream
          if :properties == stream.current_token
            stream.advance_one
            resolve_property_class
            resolve_writable_box
            ok = prcs_polymorphic_stream_fully_for_properties stream
            ok && @cls
          else
            receive_extra_values_event Stranger_[ stream.current_token, [ :properties ] ]  # #hook-in (local)
          end
        end

      private

        def prcs_polymorphic_stream_fully_for_properties stream
          ok = true
          while stream.unparsed_exists
            if :properties == stream.current_token
              stream.advance_one
              do_flush_rest = true
              break
            end
            prop = @property_class.via_polymorphic_stream stream
            if prop
              ok = accept_prop prop
              ok or break
            else
              ok = prop
              break
            end
          end
          if do_flush_rest
            ok = flush_rest_as_flat_list stream
          end
          ok
        end

        def flush_rest_as_flat_list stream
          ok = true
          begin
            prop = @property_class.new do
              @name = Home_::Name.via_variegated_symbol stream.gets_one
              ACHIEVED_
            end
            ok = accept_prop prop
          end while ok && stream.unparsed_exists
          ok
        end

        def resolve_property_class
          @property_class = if @cls.const_defined? PC_
            @cls.const_get PC_
          else
            Property
          end ; nil
        end

        def resolve_writable_box
          if @cls.const_defined? BX_, false
            @box = @cls.const_get BX_
          else
            @box = if @cls.const_defined? BX_
              @cls.const_get( BX_ ).dup
            else
              Home_::Box.new
            end
            @cls.const_set BX_, @box
          end ; nil
        end

        def accept_prop prop
          name_i = prop.name_symbol
          m_i = :"produce_#{ name_i }_property"
          @box.add name_i, m_i
          @cls.send :define_singleton_method, m_i do
            prop
          end
          method_p = prop.polymorphic_writer_method_proc
          if method_p
            m_i = :"#{ name_i }="
            @cls.send :define_method, m_i, method_p
            @cls.send :private, m_i
          end
          ACHIEVED_
        end

        module Proprietor_Module_Methods__

          def properties
            @properties ||= __build_properties
          end

          def __build_properties

            bx = const_get BX_

            _st = Home_::Stream.via_nonsparse_array bx.a_ do | sym |
              send bx.fetch sym
            end

            _st.flush_to_immutable_with_random_access_keyed_to_method :name_symbol
          end
        end
      end

      Build_extra_values_event = -> name_i_a, did_you_mean_i_a=nil do

        if 1 == name_i_a.length
          Stranger_[ name_i_a.first, did_you_mean_i_a ]
        else
          Home_.lib_.brazen::Property.
            build_extra_values_event name_i_a, did_you_mean_i_a
        end
      end

      class Stranger_

        Home_::Actor.call self, :properties,
          :strange_x, :exp_i_a

        def initialize
          @exp_i_a = nil
          @length_limit = A_FEW_
          super
        end

        def execute
          if @exp_i_a
            if @exp_i_a.length > @length_limit
              reduce_exp_i_a
            else
              @strange_x_ = @strange_x
              @exp_x_a = @exp_i_a
            end
          else
            @strange_x_ = @strange_x
            @exp_x_a = nil
          end
          flush
        end

      private

        def reduce_exp_i_a
          if @strange_x.respond_to? :id2name
            @strange_x_ = @strange_x.id2name
            _exp_s_a = @exp_i_a.map( & :id2name )
            @exp_x_a = Levenshtein_reduce_[ @length_limit, _exp_s_a, @strange_x_ ]
          else
            @strange_x_ = Home_.lib_.strange @strange_x
            @exp_x_a = exp_i_a[ 0, @length_limit ]
          end
        end

        def flush
          Home_.lib_.brazen::Property.
            build_extra_values_event [ @strange_x_ ], @exp_x_a
        end
      end

      Levenshtein_reduce_ = -> closest_d, good_x_a, strange_x do  # :+#curry-friendly

        Home_.lib_.human::Levenshtein.with(
          :item, strange_x,
          :closest_N_items, closest_d,
          :items, good_x_a,
          :aggregation_proc, -> x_a do
            x_a  # just saying hello
          end,
          :item_proc, -> x do
            x  # ibid
          end )
      end

      A_FEW_ = 3

      # ~ below is only necessary for "simple" (with meta-properties)

      class Apply_simple_enhancement__

        module Proprietor_Module_Methods__

          def [] client, * x_a
            aply_extension_module client, x_a
          end

          def call client, * x_a
            aply_extension_module client, x_a
          end

          def o * x_a
            Methodic.edit_module_via_iambic self, x_a
          end

        private

          def property_class_for_write
            if const_defined? PC_, false
              const_get PC_
            else
              const_set PC_,( if const_defined? PC_
                ::Class.new const_get PC_
              else
                ::Class.new Property
              end )
            end
          end

          def module_methods_module_for_write
            if const_defined? MM_, false
              const_get MM_
            else
              const_set MM_, ( if const_defined? MM_
                mod = ::Module.new
                mod.include const_get MM_
                mod
              else
                ::Module.new
              end )
            end
          end

          def aply_extension_module client, x_a
            Extension_Application__.new( client, x_a, self ).execute
          end
        end

        class Extension_Application__

          def initialize client, x_a, mod
            @client = client ; @x_a = x_a ; @mod = mod
          end

          def execute
            @client.extend Proprietor_Module_Methods__  # in case we need it early at `_DO_ME` below
            if @mod.const_defined? MM_
              @client.extend @mod.const_get MM_
            end
            @client.include @mod  # this adds 4 modules to the chain!
            @mod.properties.length.nonzero? and self._DO_ME
            Methodic.edit_module_via_iambic @client, @x_a
          end
        end
      end  # Apply_simple_enhancement__

      class Property

        attr_reader :polymorphic_writer_method_proc_proc

      private

        def polymorphic_writer_method_to_be_provided=
          @has_custom_polymorphic_writer_method = true
          @polymorphic_writer_method_proc_proc = nil
          ACHIEVED_
        end

        def polymorphic_writer_method_proc_proc=
          @has_custom_polymorphic_writer_method = true
          @polymorphic_writer_method_proc_proc = gets_one_polymorphic_value
          ACHIEVED_
        end
      end

      # ~ courtesies (not part of central operation, here b.c they are common)

      class Apply_simple_enhancement__

        module Proprietor_Instance_Methods__

          def initialize & p  # :+#courtesy
            super( & nil )
            p and instance_exec( & p )
          end

          def members
            self.class.properties.to_stream.map_by do | x |
              x.name_symbol
            end.to_a
          end

        private

          def via_default_proc_and_is_required_normalize  # #note-515, :+#courtesy

            Require_fields_lib_[]

            miss_prp_a = nil
            st = self.class.properties.to_value_stream
            begin
              prp = st.gets
              prp or break

              ivar = prp.as_ivar

              x = if instance_variable_defined? ivar
                instance_variable_get ivar
              else
                instance_variable_set ivar, nil
              end

              if x.nil? && prp.default_proc
                x = prp.default_proc[]
                instance_variable_set ivar, x
              end

              if Field_::Is_required[ prp ] && x.nil?
                ( miss_prp_a ||= [] ).push prp
              end

              redo
            end while nil

            if miss_prp_a
              _ev = build_missing_required_properties_event miss_prp_a
              receive_missing_required_properties_event _ev
              UNABLE_

            else
              ACHIEVED_
            end
          end

          def build_missing_required_properties_event miss_prp_a
            Home_.lib_.brazen::Property.
              build_missing_required_properties_event( miss_prp_a )
          end

          def receive_missing_required_properties_event ev
            raise ev.to_exception
          end

          def nilify_uninitialized_ivars  # :+#courtesy
            scn = self.class.properties.to_value_stream
            while prop = scn.gets
              instance_variable_defined? prop.as_ivar and next
              instance_variable_set prop.as_ivar, nil
            end
          end
        end
      end

      # ~ totally independent experimental enhancement (#note-650)

      module Cache_polymorphic_writer_methods__

        class << self

          def call top_class, upstream_class=top_class, & edit_hash_p

            top_class.class_exec do

              extend Cache_polymorphic_writer_methods__

              def polymorphic_writer_method_name_passive_lookup_proc  # #hook-in
                self.class.iamb_writer_method_name_passive_proc
              end

              h = {}
              upstream_class.private_instance_methods( false ).each do | meth_i |
                md = IAMBIC_WRITER_METHOD_NAME_RX__.match meth_i
                md or next
                h[ md[ 0 ].intern ] = meth_i
              end

              if edit_hash_p
                h = edit_hash_p[ h ]
              end

              @polymorphic_writer_method_name_dictionary = h.freeze  # top class only
            end
            nil
          end

          alias_method :[], :call

        end  # >>

        # ~ courtesies

        def is_keyword i
          polymorphic_writer_method_name_dictionary.key? i
        end

        def clear_polymorphic_writer_method_name_passive_proc
          @polymorphic_writer_method_name_dictionary = nil
          @polymorphic_writer_method_name_passive_proc = nil
        end

        # ~ implementation

        def iamb_writer_method_name_passive_proc
          @polymorphic_writer_method_name_passive_proc ||= bld_polymorphic_writer_method_name_passive_proc
        end

        private def bld_polymorphic_writer_method_name_passive_proc
          h = polymorphic_writer_method_name_dictionary
          -> prop_i do
            h[ prop_i ]
          end
        end

        def polymorphic_writer_method_name_dictionary
          @polymorphic_writer_method_name_dictionary ||= bld_polymorphic_writer_method_name_dictionary
        end

        private def bld_polymorphic_writer_method_name_dictionary
          h = superclass.polymorphic_writer_method_name_dictionary.dup
          ( private_instance_methods( false ).each do | meth_i |
            md = IAMBIC_WRITER_METHOD_NAME_RX__.match meth_i
            md or next
            h[ md[ 0 ].intern ] = meth_i
          end )
          h.freeze
        end

        IAMBIC_WRITER_METHOD_NAME_RX__ = /\A.+(?==\z)/
      end

      Require_fields_lib_ = Lazy.call do  # NOTE - push this up, do not rewrite it
        _x = Home_.lib_.fields
        Home_.const_set :Field_, _x
        NIL_
      end

      BX_ = :PROPERTIES_FOR_WRITE__
      MM_ = :ModuleMethods  # is Module_Methods in [bz] ent
      PC_ = :Property  # is PROPERTY_CLASS__ in [bz] ent
      STOP_PARSING_ = false
    end
  end
end
