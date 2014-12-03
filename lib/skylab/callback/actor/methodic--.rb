module Skylab::Callback

  module Actor

    module Methodic__  # see [#058]

      class << self

        def via_client_and_iambic mod, i_a
          mod.extend Module_Methods__
          mod.include Instance_Methods__
          if i_a.length.nonzero?
            i = i_a.first
            if :simple == i
              Simple__.new( mod, Iambic_Scanner_.new( 1, i_a ) ).execute
            elsif :properties == i
              aply_seed_treatment mod, i_a
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
              mod.send :define_method, :"#{ i }=" do
                instance_variable_set _IVAR, iambic_property
              end
            end
          end
        end

        def snd_expecting_error actual_i, exp_i_a
          _ev = Stranger_[ actual_i, exp_i_a ]
          raise _ev.to_exception
        end
      end  # >>

      module Module_Methods__

        # (experimental variations on the theme, but we should DRY these)

        def via_arglist a, & oes_p
          curried = build_via_arglist a, & oes_p  # :+#hook-out
          curried && curried.execute
        end

        def via_iambic x_a, & oes_p
          curried = build_via_iambic x_a, & oes_p
          curried && curried.execute
        end

        def build_via_iambic x_a, & oes_p
          seen = false
          ok = true
          x = new do
            seen = true
            oes_p and receive_selective_listener_proc oes_p
            ok = process_iambic_fully 0, x_a
          end
          seen && ok && x
        end
      end

      module Algorithmic_Methods__

      private

        def via_algorithm_process_iambic_passively
          pass_p = self.class.method :private_method_defined?
          while unparsed_iambic_exists
            m_i = :"#{ current_iambic_token }="
            if pass_p[ m_i ]
              advance_iambic_stream_by_one
              send m_i
            else
              x = current_iambic_index
              break
            end
          end
          x
        end

        def when_extra_iambic
          _ev = via_current_iambic_token_build_extra_iambic_event
          receive_extra_iambic _ev  # :+#public-API (name) :+#hook-in
        end

        def via_current_iambic_token_build_extra_iambic_event
          build_extra_iambic_event_via [ current_iambic_token ]
        end

        def build_extra_iambic_event_via name_i_a, did_you_mean_i_a=nil
          if 1 == name_i_a.length
            Stranger_[ name_i_a.first, did_you_mean_i_a ]
          else
            Callback_::Lib_::Entity[].properties_stack.
              build_extra_properties_event name_i_a, did_you_mean_i_a
          end
        end

        def receive_extra_iambic ev
          raise ev.to_exception
        end
      end

      module Instance_Methods__

        include Algorithmic_Methods__

      private

        def process_iambic_fully d=0, x_a
          process_iambic_passively d, x_a
          if unparsed_iambic_exists
            when_extra_iambic
          else
            ACHIEVED_
          end
        end

        def process_iambic_passively d=0, x_a
          @d = d ; @x_a_length = x_a.length ; @x_a = x_a
          via_algorithm_process_iambic_passively
        end

        # ~ duplication

        def unparsed_iambic_exists
          @d < @x_a_length
        end

        def iambic_property
          x = current_iambic_token
          advance_iambic_stream_by_one
          x
        end

        def current_iambic_index
          @d
        end

        def current_iambic_token
          @x_a.fetch @d
        end

        def advance_iambic_stream_by_one
          @d += 1
        end
      end

      module Via_Scanner_Iambic_Methods__

        include Algorithmic_Methods__

      private

        def unparsed_iambic_exists
          @keep_scanning && @scanner.unparsed_exists
        end

        def iambic_property
          x = current_iambic_token
          advance_iambic_stream_by_one
          x
        end

        def current_iambic_index
          @scanner.current_index
        end

        def current_iambic_token
          @scanner.current_token
        end

        def advance_iambic_stream_by_one
          @scanner.advance_one
        end
      end

      class Simple_Property__  # :+[#mh-053] (was [#hl-030])

        Actor.methodic self, :properties,
          :argument_arity,
          :ivar,
          :parameter_arity

        include Via_Scanner_Iambic_Methods__

      private

        def ignore=
          @parameter_arity = nil
        end

        def property=
          @keep_scanning = false
        end

      public

        def initialize scn=nil, & p
          @iambic_writer_method_proc_is_generated = true
          @parameter_arity = :zero_or_one
          if scn
            @scanner = scn
            @keep_scanning = true
            via_algorithm_process_iambic_passively
            i = iambic_property
            @name = Callback_::Name.via_variegated_symbol i
            @scanner = nil
          end
          if p
            instance_exec( & p )
          end
          @argument_arity ||= :one
          freeze
        end

        attr_reader :argument_arity, :ivar, :name, :parameter_arity

        def name_i
          @name.as_variegated_symbol
        end

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
          end
        end

        def iambic_writer_method_proc_when_arity_is_zero
          _IVAR = as_ivar
          -> do
            instance_variable_set _IVAR, true
          end
        end
      end

      IAMBIC_WRITER_METHOD_BODY_WHEN_IGNORE_H__ = {
        zero: -> do
          # nothing.
        end,
        one: -> do
          iambic_property ; nil
        end
      }.freeze

      class Simple__

        include Via_Scanner_Iambic_Methods__

        def initialize cls, scanner
          @cls = cls
          @cls.extend Proprietor_Module_Methods__
          @cls.include Proprietor_Instance_Methods__
          @keep_scanning = true
          @scanner = scanner
        end

        def execute
          if :properties == current_iambic_token
            advance_iambic_stream_by_one
            resolve_property_class_and_writable_box
            loop_for_properties
          else
            receive_extra_iambic Stranger_[ current_iambic_token, [ :properties ] ]  # #hook-in (local)
          end
        end

      private

        def loop_for_properties
          while unparsed_iambic_exists
            i = current_iambic_token
            if :properties == i
              advance_iambic_stream_by_one
              flush_rest_as_flat_list
              break
            end
            accept_property @property_class.new @scanner
          end ; nil
        end

      private

        def flush_rest_as_flat_list
          begin
            name_i = iambic_property
            _prop = @property_class.new do
              @name = Callback_::Name.via_variegated_symbol name_i
            end
            accept_property _prop
          end while unparsed_iambic_exists
        end

        def resolve_property_class_and_writable_box
          resolve_property_class
          resolve_writable_box ; nil
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

        def accept_property prop
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
          nil
        end

        # ~ override some parent behavior

        def via_current_iambic_token_build_extra_iambic_event
          self._DO_ME
          Stranger_[ current_iambic_token ]
        end

        module Proprietor_Module_Methods__

          def properties
            @properties ||= bld_properties
          end

        private

          def bld_properties
            _BX = const_get BX_
            Callback_::Scan.via_nonsparse_array _BX.send( :a ) do |i|
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
            when_expecting
          else
            @strange_x_ = @strange_x
            @exp_x_a = nil
            flush
          end
        end
      private

        def when_expecting
          if @exp_i_a.length > @length_limit
            reduce_exp_i_a
          else
            @strange_x_ = @strange_x
            @exp_x_a = @exp_i_a
          end

        end

        def reduce_exp_i_a
          if @strange_x.respond_to? :id2name
            @strange_x_ = @strange_x.id2name
            _exp_s_a = @exp_i_a.map( & :id2name )
            @exp_x_a = Levenshtein_reduce_[ @length_limit, _exp_s_a, @strange_x_ ]
          else
            @strange_x_ = Callback_::Lib_::Strange[ @strange_x ]
            @exp_x_a = exp_i_a[ 0, @length_limit ]
          end
        end

        def flush
          Callback_::Lib_::Entity[].properties_stack.
            build_extra_properties_event [ @strange_x_ ], @exp_x_a
        end
      end

      Levenshtein_reduce_ = -> closest_d, good_x_a, strange_x do  # :+#curry-friendly
        Callback_::Lib_::Levenshtein[].with(
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

      class Simple__

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
      end  # Simple__

      class Simple_Property__
      private
        def iambic_writer_method_to_be_provided=
          @iambic_writer_method_proc_is_generated = false
          @iambic_writer_method_proc_proc = nil
        end

        def iambic_writer_method_proc_proc=
          @iambic_writer_method_proc_is_generated = false
          @iambic_writer_method_proc_proc = iambic_property
        end
      end

      # ~ courtesies (not part of central operation, here b.c they are common)

      class Simple__

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
            Callback_::Lib_::Entity[].properties_stack.
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

      ACHIEVED_ = true
      BX_ = :PROPERTIES_FOR_WRITE__
      MM_ = :ModuleMethods  # is Module_Methods in [bz] ent
      PC_ = :Property  # is PROPERTY_CLASS__ in [bz] ent
      UNABLE_ = false
    end
  end
end
