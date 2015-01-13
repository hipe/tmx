module Skylab::Callback

  module Actor

    module Methodic__  # see [#058]

      class << self

        def cache_iambic_writer_methods * a, & p
          Cache_iambic_writer_methods__.call( * a, & p )
        end

        def iambic_processing_instance_methods
          Iambic_Processing_Instance_Methods__
        end

        def simple_property_class
          Simple_Property__
        end

        def via_client_and_iambic cls, i_a
          cls.extend Module_Methods__
          cls.include Iambic_Processing_Instance_Methods__
          if i_a.length.zero?
            cls
          else
            i = i_a.first
            case i
            when :simple
              Apply_simple_enhancement__.new(
                cls,
                Iambic_Stream_via_Array_.new( 1, i_a )
              ).execute
            when :properties
              aply_seed_treatment cls, i_a
            else
              snd_expecting_error i_a.first, [ :properties, :simple ]
            end
          end
        end

      private

        def aply_seed_treatment mod, i_a
          mod.module_exec do
            private
            1.upto( i_a.length - 1 ) do |d|
              i = i_a.fetch d
              _IVAR = :"@#{ i }"
              define_method :"#{ i }=" do
                instance_variable_set _IVAR, iambic_property
                KEEP_PARSING_
              end
            end
          end
          nil
        end

        def snd_expecting_error actual_i, exp_i_a
          _ev = Stranger_[ actual_i, exp_i_a ]
          raise _ev.to_exception
        end
      end  # >>

      module Module_Methods__

        # (experimental variations on the theme, but we should DRY these)

        def with * x_a, & oes_p
          call_via_iambic x_a, & oes_p
        end

        def call_via_arglist a, & oes_p
          curried = build_via_arglist a, & oes_p  # :+#hook-out
          curried && curried.execute
        end

        def call_via_iambic x_a, & oes_p
          curried = new_via_iambic x_a, & oes_p
          curried && curried.execute
        end

        def new_via_iambic x_a, & oes_p
          ok = nil
          x = new do
            oes_p and accept_selective_listener_proc oes_p  # :+#public-API :+#hook-out #hook-near
            ok = process_iambic_stream_fully Iambic_Stream_via_Array_.new( 0, x_a )
          end
          ok && x
        end

        # (experimental features near here exist in: [#br-081])
      end

      module Iambic_Processing_Instance_Methods__

      private

        def iambic_stream_via_iambic_array x_a
          Iambic_Stream_via_Array_.new 0, x_a
        end

        def process_iambic_stream_fully stream  # :+#public-API :+#hook-in
          keep_parsing = process_iambic_stream_passively stream
          keep_parsing and begin
            if stream.no_unparsed_exists
              ACHIEVED_
            else
              when_after_process_iambic_fully_stream_has_content stream
            end
          end
        end

        def process_iambic_stream_passively stream, & oes_p
          keep_parsing = true
          if stream.unparsed_exists
            method_name_p = iambic_writer_method_name_passive_lookup_proc
            m_i = method_name_p[ stream.current_token ]
            if m_i
              @__methodic_actor_iambic_stream__ = stream
              @__methodic_actor_handle_event_selectively__ = oes_p
              begin
                stream.advance_one
                keep_parsing = send m_i
                if keep_parsing
                  if stream.unparsed_exists
                    m_i = method_name_p[ stream.current_token ]
                    m_i and redo
                  end
                end
                break
              end while nil
              @__methodic_actor_iambic_stream__ = nil
              @__methodic_actor_handle_event_selectively__ = nil
            end
          end
          keep_parsing
        end

        def against_iambic_property no_p=nil  # experimental, :+#public-API
          if @__methodic_actor_iambic_stream__.unparsed_exists
            yield iambic_property
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
              :previous_token, @__methodic_actor_iambic_stream__.previous_token,
              :error_category, :argument_error do |y, o|

            y << "expecting a value for #{ code o.previous_token }"
          end
        end

        def iambic_property  # :+#public-API #hook-in
          @__methodic_actor_iambic_stream__.gets_one
        end

        def iambic_writer_method_name_passive_lookup_proc  # :+#public-API #hook-in
          cls = self.class
          -> name_i do
            m_i = :"#{ name_i }="
            if cls.private_method_defined? m_i
              m_i
            end
          end
        end

        def when_after_process_iambic_fully_stream_has_content stream  # :+#public-API
          _ev = build_extra_iambic_event_via [ stream.current_token ]
          receive_extra_iambic _ev
        end

        def build_extra_iambic_event_via name_i_a, did_you_mean_i_a=nil
          if 1 == name_i_a.length
            Stranger_[ name_i_a.first, did_you_mean_i_a ]
          else
            Callback_.lib_.entity.properties_stack.
              build_extra_properties_event name_i_a, did_you_mean_i_a
          end
        end

        def build_not_OK_event_with * i_a, & msg_p
          Callback_::Event.inline_not_OK_via_mutable_iambic_and_message_proc i_a, msg_p
        end

        def receive_extra_iambic ev  # :+#public-API (name) :+#hook-in
          raise ev.to_exception
        end
      end

      class Simple_Property__  # :+[#mh-053] (was [#hl-030])

        Actor.methodic self, :properties,
          :argument_arity,
          :ivar,
          :parameter_arity

        class << self

          def via_iambic_stream stream, & oes_p  # :+public-API  #hook-in
            name_was_reached = false
            keep_parsing = nil
            ok = nil
            x = new do
              @name = nil
              keep_parsing = process_iambic_stream_passively stream, & oes_p
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
          @iambic_writer_method_proc_is_generated = true  # :+#public-API (name)
          @parameter_arity = :zero_or_one
          instance_exec( & edit_p )
          @argument_arity ||= :one
          freeze
        end

        attr_reader :argument_arity, :ivar, :name, :parameter_arity

        def members
          [ :argument_arity, :ivar, :name, :name_i, :parameter_arity ]
        end

      private

        def ignore=
          @parameter_arity = nil
          ACHIEVED_
        end

        def property=
          @name = Callback_::Name.via_variegated_symbol iambic_property
          STOP_PARSING_
        end

      public

        def name_i
          @name.as_variegated_symbol
        end

        alias_method :name_symbol, :name_i  # #open [#004]

        def as_ivar
          ivar || @name.as_ivar
        end

        def is_required
          :one == @parameter_arity
        end

        def iambic_writer_method_proc
          if @iambic_writer_method_proc_is_generated
            if @parameter_arity
              send :"iambic_writer_method_proc_when_arity_is_#{ @argument_arity }"
            else
              IAMBIC_WRITER_METHOD_BODY_WHEN_IGNORE_H__.fetch @argument_arity
            end
          elsif @iambic_writer_method_proc_proc
            @iambic_writer_method_proc_proc[ self ]
          end
        end

      private

        def iambic_writer_method_proc_when_arity_is_one
          _IVAR = as_ivar
          -> do
            instance_variable_set _IVAR, iambic_property
            KEEP_PARSING_
          end
        end

        def iambic_writer_method_proc_when_arity_is_zero
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
          iambic_property
          ACHIEVED_
        end
      }.freeze

      class Apply_simple_enhancement__

        def initialize cls, iambic_stream
          @cls = cls
          @cls.extend Proprietor_Module_Methods__
          @cls.include Proprietor_Instance_Methods__
          @iambic_stream = iambic_stream
        end

        def execute
          stream = @iambic_stream
          if :properties == stream.current_token
            stream.advance_one
            resolve_property_class
            resolve_writable_box
            ok = prcs_iambic_stream_fully_for_properties stream
            ok && @cls
          else
            receive_extra_iambic Stranger_[ stream.current_token, [ :properties ] ]  # #hook-in (local)
          end
        end

      private

        def prcs_iambic_stream_fully_for_properties stream
          ok = true
          while stream.unparsed_exists
            if :properties == stream.current_token
              stream.advance_one
              do_flush_rest = true
              break
            end
            prop = @property_class.via_iambic_stream stream
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
              @name = Callback_::Name.via_variegated_symbol stream.gets_one
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
            Simple_Property__
          end ; nil
        end

        def resolve_writable_box
          if @cls.const_defined? BX_, false
            @box = @cls.const_get BX_
          else
            @box = if @cls.const_defined? BX_
              @cls.const_get( BX_ ).dup
            else
              Callback_::Box.new
            end
            @cls.const_set BX_, @box
          end ; nil
        end

        def accept_prop prop
          name_i = prop.name_i
          m_i = :"produce_#{ name_i }_property"
          @box.add name_i, m_i
          @cls.send :define_singleton_method, m_i do
            prop
          end
          @ivar = prop.as_ivar
          method_p = prop.iambic_writer_method_proc
          if method_p
            m_i = :"#{ name_i }="
            @cls.send :define_method, m_i, method_p
            @cls.send :private, m_i
          end
          ACHIEVED_
        end

        module Proprietor_Module_Methods__

          def properties
            @properties ||= bld_properties
          end

        private

          def bld_properties
            _BX = const_get BX_
            Callback_::Stream__.via_nonsparse_array _BX.send( :a ) do |i|
              send _BX.fetch i
            end.immutable_with_random_access_keyed_to_method :name_i
          end
        end
      end

      class Stranger_

        Callback_::Actor.call self, :properties,
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
            @strange_x_ = Callback_.lib_.strange @strange_x
            @exp_x_a = exp_i_a[ 0, @length_limit ]
          end
        end

        def flush
          Callback_.lib_.entity.properties_stack.
            build_extra_properties_event [ @strange_x_ ], @exp_x_a
        end
      end

      Levenshtein_reduce_ = -> closest_d, good_x_a, strange_x do  # :+#curry-friendly
        Callback_.lib_.levenshtein.with(
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
            Methodic__.via_client_and_iambic self, x_a
          end

        private

          def property_class_for_write
            if const_defined? PC_, false
              const_get PC_
            else
              const_set PC_,( if const_defined? PC_
                ::Class.new const_get PC_
              else
                ::Class.new Simple_Property__
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
            Methodic__.via_client_and_iambic @client, @x_a
          end
        end
      end  # Apply_simple_enhancement__

      class Simple_Property__

      private

        def iambic_writer_method_to_be_provided=
          @iambic_writer_method_proc_is_generated = false
          @iambic_writer_method_proc_proc = nil
          ACHIEVED_
        end

        def iambic_writer_method_proc_proc=
          @iambic_writer_method_proc_is_generated = false
          @iambic_writer_method_proc_proc = iambic_property
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

        private

          def via_default_proc_and_is_required_normalize  # #note-515, :+#courtesy
            scn = self.class.properties.to_stream
            miss_a = nil
            while prop = scn.gets
              ivar = prop.as_ivar
              x = if instance_variable_defined? ivar
                instance_variable_get ivar
              else
                instance_variable_set ivar, nil
              end
              if x.nil? && prop.default_proc
                x = prop.default_proc[]
                instance_variable_set ivar, x
              end
              if prop.is_required && x.nil?
                ( miss_a ||= [] ).push prop
              end
            end
            if miss_a
              _ev = build_missing_required_properties_event miss_a
              receive_missing_required_properties _ev
              UNABLE_
            else
              ACHIEVED_
            end
          end

          def build_missing_required_properties_event miss_a
            Callback_.lib_.entity.properties_stack.
              build_missing_required_properties_event( miss_a )
          end

          def receive_missing_required_properties ev
            raise ev.to_exception
          end

          def nilify_uninitialized_ivars  # :+#courtesy
            scn = self.class.properties.to_stream
            while prop = scn.gets
              instance_variable_defined? prop.as_ivar and next
              instance_variable_set prop.as_ivar, nil
            end
          end
        end
      end

      # ~ totally independent experimental enhancement (#note-650)

      module Cache_iambic_writer_methods__

        class << self

          def call top_class, upstream_class=top_class, & edit_hash_p

            top_class.class_exec do

              extend Cache_iambic_writer_methods__

              def iambic_writer_method_name_passive_lookup_proc  # #hook-in
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

              @iambic_writer_method_name_dictionary = h.freeze  # top class only
            end
            nil
          end

          alias_method :[], :call

        end  # >>

        # ~ courtesies

        def is_keyword i
          iambic_writer_method_name_dictionary.key? i
        end

        def clear_iambic_writer_method_name_passive_proc
          @iambic_writer_method_name_dictionary = nil
          @iambic_writer_method_name_passive_proc = nil
        end

        # ~ implementation

        def iamb_writer_method_name_passive_proc
          @iambic_writer_method_name_passive_proc ||= bld_iambic_writer_method_name_passive_proc
        end

        private def bld_iambic_writer_method_name_passive_proc
          h = iambic_writer_method_name_dictionary
          -> prop_i do
            h[ prop_i ]
          end
        end

        def iambic_writer_method_name_dictionary
          @iambic_writer_method_name_dictionary ||= bld_iambic_writer_method_name_dictionary
        end

        private def bld_iambic_writer_method_name_dictionary
          h = superclass.iambic_writer_method_name_dictionary.dup
          ( private_instance_methods( false ).each do | meth_i |
            md = IAMBIC_WRITER_METHOD_NAME_RX__.match meth_i
            md or next
            h[ md[ 0 ].intern ] = meth_i
          end )
          h.freeze
        end

        IAMBIC_WRITER_METHOD_NAME_RX__ = /\A.+(?==\z)/
      end

      BX_ = :PROPERTIES_FOR_WRITE__
      MM_ = :ModuleMethods  # is Module_Methods in [bz] ent
      PC_ = :Property  # is PROPERTY_CLASS__ in [bz] ent
      STOP_PARSING_ = false
    end
  end
end
