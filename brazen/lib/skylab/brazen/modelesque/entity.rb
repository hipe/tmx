module Skylab::Brazen

  Modelesque::Entity = ::Module.new

  Entity_lib_[].call( Modelesque::Entity,  # see [#047]

    # ->

      # ~ ad-hoc processors

      :ad_hoc_processor, :after, -> o do  # o = "session"

        o.downstream.after_name_symbol = o.upstream.gets_one
        KEEP_PARSING_
      end,

      :ad_hoc_processor, :branch_description, -> o do

        o.downstream.instance_description_proc = o.upstream.gets_one
        KEEP_PARSING_
      end,

      :ad_hoc_processor, :inflect, -> o do

        o.downstream.process_some_customized_inflection_behavior o.upstream
      end,

      :ad_hoc_processor, :promote_action, -> o do

        o.downstream.is_promoted = true
        KEEP_PARSING_
      end,

      :ad_hoc_processor, :persist_to, -> o do

        o.downstream.persist_to = o.upstream.gets_one
        KEEP_PARSING_
      end,

      :ad_hoc_processor, :preconditions, -> o do

        a = o.downstream.precondition_controller_i_a_
        _a_ = o.upstream.gets_one
        if a
          self._COVER_ME
        else
          o.downstream.precondition_controller_i_a_ = _a_
        end
        KEEP_PARSING_
      end,

      :ad_hoc_processor, :precondition, -> o do

        i_a = ( o.downstream.precondition_controller_i_a_ ||= [] )
        sym = o.upstream.gets_one
        i_a.include?( i ) or i_a.push sym
        KEEP_PARSING_
      end,

      # ~ simple metaproperties

      :meta_property, :option_argument_moniker  # [sg]
        # (used in some modalities to label the argument term itself)

  )

  module Modelesque::Entity
    # -
      def _parse_association_ prp  # (method MUST be public)  :[#here.1]

        # (overwrite this #hook-out so we write not to ivars but to our box)

        case prp.argument_arity

        when :one
          _write_via_association_ gets_one, prp

        when :zero
          _write_via_association_ true, prp

        when :custom
          send prp.conventional_argument_scanning_writer_method_name  # :+#by:pe

        when :one_or_more  # :+#by:st
          _write_via_association_ gets_one, prp

        when :zero_or_more  # :+#by:fm
          _write_via_association_ gets_one, prp

        else
          raise ::NameError, __say_arg_arity( prp )
        end

        KEEP_PARSING_
      end

    private  # important

      def __say_arg_arity prp
        "write a dipatcher method or whatever for '#{ prp.argument_arity }'"
      end

      # ~ normalization (a thin layer on top of entity concerns)

      def normalize  # :[#here.2]

        # since we have reached ths method at all it is safe to
        # assume that the entity has some formal properties.

        Home_.lib_.fields::Attributes::Normalization::OCTOBER_08_2014::Stream.call(

          self,
          formal_properties.to_value_stream,
          & handle_event_selectively )
      end

      public def _write_via_association_ x, prp

        as_entity_actual_property_box_.set prp.name_symbol, x  # (changed from `add`)
        KEEP_PARSING_
      end

      if const_defined? :Property
        # ok. it means we defined meta-properties above
      else
        const_set :Property, ::Class.new( Entity_lib_[]::Property )
      end

      # ---- ( Property must be set as an *owned* constant by this point ) ---

      const_get :Property, false  # sanity - do *not* create this class below

      # ~ metaproperties

      ## ~~ ad-hoc normalizer

        class self::Property

        private

          def ad_hoc_normalizer=

            append_ad_hoc_normalizer_( & gets_one )
            KEEP_PARSING_
          end

        public

          def prepend_ad_hoc_normalizer & arg_and_oes_block_p

            prepend_ad_hoc_normalizer_( & arg_and_oes_block_p )
            self
          end

          def append_ad_hoc_normalizer( & arg_and_oes_block_p )

            append_ad_hoc_normalizer_( & arg_and_oes_block_p )
            self
          end
        end

      ## ~~ argument arity

        class self::Property
        private

          def flag=
            @argument_arity = :zero
            KEEP_PARSING_
          end
        end

      ## ~~ default (that which is not covered by parent - it is a meta-meta-property)

        class self::Property

          # ~ :*#public-API

          def default=

            # when the default is expressed as a simple primitive-ish
            # value, we want to be able to just have it back

            x = gets_one
            @default_proc = -> do
              x
            end
            KEEP_PARSING_
          end
          private :default=

          def has_primitive_default
            if @default_proc
              @default_proc.arity.zero?
            end
          end

          def primitive_default_value  # assume
            @default_proc.call
          end
        end

      ## ~~ description

        class self::Property

          # ~ :*#public-API

          def describe_by & p
            accept_description_proc p
            self
          end

        private

          def description=

            p = gets_one

            if p.respond_to? :ascii_only?
              _STRING = x
              p = -> y do
                y << _STRING
              end
            end

            if p
              accept_description_proc p
              KEEP_PARSING_
            else
              FALSE  # STOP_PARSING_
            end
          end

          def accept_description_proc p  # [ts]
            @description_proc = p ; nil
          end

        public

          alias_method :description_proc=, :accept_description_proc  # [sg]
          public :description_proc=

          attr_reader :description_proc

          def argument_argument_moniker  # [gv], [cme]. for "didactics"..
            NOTHING_
          end
        end

      ## ~~ integer related

        class self::Property
        private

          def integer_greater_than_or_equal_to=
            add_normalizer_for_greater_than_or_equal_to_integer gets_one
          end

          def add_normalizer_for_greater_than_or_equal_to_integer d  # :+#public-API
            _add_number_normalization :number_set, :integer, :minimum, d
          end

          def integer=
            _add_number_normalization :number_set, :integer
          end

          def _add_number_normalization * x_a

            _n11n = Home_.lib_.basic.normalizers.number.via_iambic x_a

            __add_ad_hoc_normalization _n11n
          end

          def __add_ad_hoc_normalization n11n

            append_ad_hoc_normalizer_ do | qkn, & oes_p |

              if qkn.is_effectively_known
                n11n.normalize_qualified_knownness qkn, & oes_p
              else
                qkn.to_knownness
              end
            end

            KEEP_PARSING_
          end

          def non_negative_integer=

            _NORMER = Home_.lib_.basic.normalizers.number(
              :number_set, :integer,
              :minimum, 0 )

            append_ad_hoc_normalizer_ do | qkn, & oes_p |

              if qkn.is_effectively_known
                _NORMER.normalize_qualified_knownness qkn, & oes_p
              else
                qkn.to_knownness
              end
            end

            KEEP_PARSING_
          end
        end

      ## ~~ parameter arity - read synopsis [#fi-014]

        class self::Property

          def set_is_not_required
            @parameter_arity = :zero_or_one
            self
          end
        end

        public def _receive_missing_required_associations_ miss_prp_a  # :+#public-API #hook-in #universal

          ev = Home_.lib_.fields::Events::Missing.for_attributes miss_prp_a

          if respond_to? :receive_missing_required_properties_event

            receive_missing_required_properties_event ev
          else
            raise ev.to_exception
          end
        end

        def receive_missing_required_properties_softly ev  # popular :+#hook-with
          # (was :+[#054] #tracking error count)
          maybe_send_event :error, ev.terminal_channel_i do
            ev
          end
          UNABLE_
        end

      ## ~~ name & related

        class self::Property
        private

          def name_symbol=
            @name = Common_::Name.via_variegated_symbol gets_one
            KEEP_PARSING_
          end
        end

      # ~ courtesy

      # <-

    def via_properties_init_ivars  # #note-360

      formals = self.formal_properties

      st = formals.to_value_stream
      stack = Home_.lib_.fields::Attributes::Stack.new formals.get_keys  # could pass oes

      bx = any_secondary_box__
      bx and stack.push_frame_via_box bx
      stack.push_frame_via_box primary_box__

      begin
        prp = st.gets
        prp or break
        sym = prp.name_symbol
        pptr = stack.any_proprietor_of sym

        if pptr
          had_value = true
          x_ = pptr.property_value_via_symbol sym
        else
          had_value = false
          x_ = nil
        end

        ivar = prp.name.as_ivar

        _is_defined_and_not_nil = if instance_variable_defined? ivar
          x = instance_variable_get ivar
          ! x.nil?
        end

        if _is_defined_and_not_nil

          if had_value
            raise __say_wont_clobber_ivar( x_, x, ivar )
          end

          redo
        end
        instance_variable_set ivar, x_
        redo
      end while nil
      NIL_
    end

    def __say_wont_clobber_ivar x_, x, ivar
      p = Home_::Lib_::Strange
      "sanity - won't clobber existing #{ ivar } #{
        }(#{ p[ x ] }) with new value (#{ p[ x_ ] })"
    end
  end
end
# #history-A: (here by association) "entity" moved to [fi]
