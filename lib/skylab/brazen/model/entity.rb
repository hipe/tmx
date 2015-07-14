module Skylab::Brazen

  class Model

    Entity = ::Module.new

    Home_::Entity.call( Entity,  # see [#047]

      # ~ ad-hoc processors

      :ad_hoc_processor, :after, -> o do  # o = "session"

        o.downstream.after_name_symbol = o.upstream.gets_one
        KEEP_PARSING_
      end,

      :ad_hoc_processor, :desc, -> o do

        o.downstream.description_block = o.upstream.gets_one
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

      :meta_property, :argument_moniker
        # (used in some modalities to label the argument term itself)

    )

    module Entity

      def receive_polymorphic_property prp  # (method MUST be public)  :.A

        # (overwrite this #hook-out so we write not to ivars but to our box)

        case prp.argument_arity

        when :one
          set_value_of_formal_property_ gets_one_polymorphic_value, prp

        when :zero
          set_value_of_formal_property_ true, prp

        when :custom
          send prp.conventional_polymorphic_writer_method_name  # :+#by:pe

        when :one_or_more  # :+#by:st
          set_value_of_formal_property_ gets_one_polymorphic_value, prp

        when :zero_or_more  # :+#by:fm
          set_value_of_formal_property_ gets_one_polymorphic_value, prp

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

      def normalize  # :.B

        # since we have reached ths method at all it is safe to
        # assume that the entity has some formal properties.


        Concerns_::Normalization::Against_model_stream.call(

          self,
          formal_properties.to_value_stream,
          & handle_event_selectively )
      end

      public def set_value_of_formal_property_ x, prp

        as_entity_actual_property_box_.set prp.name_symbol, x  # (changed from `add`)
        KEEP_PARSING_
      end

      if const_defined? :Property
        # ok. it means we defined meta-properties above
      else
        const_set :Property, ::Class.new( Home_::Entity::Property )
      end

      # ---- ( Property must be set as an *owned* constant by this point ) ---

      const_get :Property, false  # sanity - do *not* create this class below

      # ~ metaproperties

      ## ~~ ad-hoc normalizer

        class self::Property

        private

          def ad_hoc_normalizer=

            append_ad_hoc_normalizer_( & gets_one_polymorphic_value )
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

          def argument_is_required  # *not the same as* parameter is required
            :one == @argument_arity || :one_or_more == @argument_arity
          end

          def takes_argument
            :zero != @argument_arity
          end

          def takes_many_arguments
            :zero_or_more == @argument_arity || :one_or_more == @argument_arity
          end

        private

          def flag=
            @argument_arity = :zero
            KEEP_PARSING_
          end
        end

      ## ~~ default (that which is not covered by parent - it is a meta-meta-property)

        class self::Property

          # ~ :*#public-API

          attr_reader :has_primitive_default, :primitive_default_value

          def set_primitive_default x
            @has_default = true
            @has_primitive_default = true
            @primitive_default_value = x
            @default_proc = -> do
              @primitive_default_value
            end
            self
          end
        end

      ## ~~ description

        class self::Property

          # ~ :*#public-API

          def description_proc
            @desc_p_a.fetch @desc_p_a.length - 1 << 1
          end

          def has_description
            desc_p_a
          end

          attr_accessor :desc_p_a

          def under_expression_agent_get_N_desc_lines expag, n=nil

            LIB_.N_lines[ [], n, @desc_p_a, expag ]
          end

        private

          def description=
            x = gets_one_polymorphic_value
            if x.respond_to? :ascii_only?
              _STRING = x
              x = -> y do
                y << _STRING
              end
            end
            accept_description_proc x
          end

          def accept_description_proc p
            if p
              ( @desc_p_a ||= [] ).push p
              KEEP_PARSING_
            else
              STOP_PARSING_
            end
          end
        end

      ## ~~ integer related

        class self::Property
        private

          def integer_greater_than_or_equal_to=
            add_normalizer_for_greater_than_or_equal_to_integer gets_one_polymorphic_value
          end

          def add_normalizer_for_greater_than_or_equal_to_integer d  # :+#public-API
            _add_number_normalization :number_set, :integer, :minimum, d
          end

          def integer=
            _add_number_normalization :number_set, :integer
          end

          def _add_number_normalization * x_a

            _n11n = Home_.lib_.basic.normalizers.number.new_via_iambic x_a

            __add_ad_hoc_normalization _n11n
          end

          def __add_ad_hoc_normalization n11n

            append_ad_hoc_normalizer_ do | arg, & oes_p |
              if ( arg.value_x if arg.is_known ).nil?
                arg
              else
                n11n.normalize_argument arg, & oes_p
              end
            end
            KEEP_PARSING_
          end

          def non_negative_integer=

            _NORMER = Home_.lib_.basic.normalizers.number(
              :number_set, :integer,
              :minimum, 0 )

            append_ad_hoc_normalizer_ do | arg, & oes_p |

              if ! arg.is_known || arg.value_x.nil?
                arg
              else
                _NORMER.normalize_argument arg, & oes_p
              end
            end
            KEEP_PARSING_
          end
        end

      ## ~~ parameter arity - read synopsis [#090]

        class self::Property

          def set_is_not_required
            @parameter_arity = :zero_or_one
            self
          end
        end

        public def receive_missing_required_properties_array miss_prp_a  # :+#public-API #hook-in #universal

          ev = Home_::Property.
            build_missing_required_properties_event miss_prp_a

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
        end

      ## ~~ name & related

        class self::Property
        private

          def name_symbol=
            @name = Callback_::Name.via_variegated_symbol gets_one_polymorphic_value
            KEEP_PARSING_
          end

        public

          def has_custom_moniker  # [#014] maybe a smell, maybe not
            false
          end
        end

      # ~ courtesy


    def via_properties_init_ivars  # #note-360

      formals = self.formal_properties

      st = formals.to_value_stream
      stack = Home_::Property::Stack.new formals.get_names  # could pass oes

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

        ivar = prp.as_ivar

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




    end  # end building the extension module
  end  # M-odel_
end  # sl [br]
