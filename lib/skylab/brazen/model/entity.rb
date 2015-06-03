module Skylab::Brazen

  class Model

    Entity = Brazen_::Entity.call do  # see [#047]

      # ~ ad-hoc processors

      o :ad_hoc_processor, :after, -> o do  # o = "session"

        o.downstream.after_name_symbol = o.upstream.gets_one
        KEEP_PARSING_
      end

      o :ad_hoc_processor, :desc, -> o do

        o.downstream.description_block = o.upstream.gets_one
        KEEP_PARSING_
      end

      o :ad_hoc_processor, :inflect, -> o do

        o.downstream.process_some_customized_inflection_behavior o.upstream
      end

      o :ad_hoc_processor, :promote_action, -> o do

        o.downstream.is_promoted = true
        KEEP_PARSING_
      end

      o :ad_hoc_processor, :persist_to, -> o do

        o.downstream.persist_to = o.upstream.gets_one
        KEEP_PARSING_
      end

      o :ad_hoc_processor, :preconditions, -> o do

        a = o.downstream.precondition_controller_i_a_
        _a_ = o.upstream.gets_one
        if a
          self._COVER_ME
        else
          o.downstream.precondition_controller_i_a_ = _a_
        end
        KEEP_PARSING_
      end

      o :ad_hoc_processor, :precondition, -> o do

        i_a = ( o.downstream.precondition_controller_i_a_ ||= [] )
        sym = o.upstream.gets_one
        i_a.include?( i ) or i_a.push sym
        KEEP_PARSING_
      end

      # ~ simple metaproperties

      # • "argument moniker" (used in some modalities to label the arg itself)

      o :meta_property, :argument_moniker

    end

    module Entity

      def receive_polymorphic_property prp  # (method MUST be public)

        # (overwrite this #hook-out so we write not to ivars but to our box)

        case prp.argument_arity

        when :one
          _set_property_value gets_one_polymorphic_value, prp

        when :zero
          _set_property_value true, prp

        when :custom
          send prp.conventional_polymorphic_writer_method_name  # :+#by:pe

        when :one_or_more  # :+#by:st
          _set_property_value gets_one_polymorphic_value, prp

        else
          raise ::NameError, __say_arg_arity( prp )
        end

        KEEP_PARSING_
      end

    private  # important

      def __say_arg_arity prp
        "write a dipatcher method or whatever for '#{ prp.argument_arity }'"
      end

      public def _set_property_value x, prp

        actual_property_box_for_write.set prp.name_symbol, x  # (changed from `add`)
        KEEP_PARSING_
      end



      # ~ n11n is here for now

      def normalize
        ok = true
        self.class::MOENT_NORM_P_A___.each do | p |
          ok = p[ self ]
          ok or break
        end
        ok
      end

      def self.__during_entity_normalize & into_ent_p  # e.g
        a = []
        const_set :MOENT_NORM_P_A___, a  # etc
        a.push into_ent_p
        NIL_
      end

      # ~ metaproperties (support)

      const_get :Property, false  # sanity

      # • ad-hoc normalizer

        class self::Property

          def normalize_argument trio, & x_p  # :+[#ba-027] assume some normalizer (for now)

            # an alternative means of running the normalizers,
            # divorced from the action API. compare to #here

            arg = trio
            @norm_p_a.each do | p |
              arg = p[ arg, & x_p ]
              arg or break
            end
            arg
          end

        private

          def ad_hoc_normalizer=

            _append_ad_hoc_normalizer( & gets_one_polymorphic_value )
            KEEP_PARSING_
          end

        public

          attr_reader :_has_ad_hoc_normalizers, :norm_p_a

          def prepend_ad_hoc_normalizer & arg_and_oes_block_p

            @_has_ad_hoc_normalizers = true
            ( @norm_p_a ||= [] ).unshift arg_and_oes_block_p
            self
          end

          def append_ad_hoc_normalizer & x_p

            _append_ad_hoc_normalizer( & x_p )
            self
          end

          def _append_ad_hoc_normalizer & arg_and_oes_block_p

            @_has_ad_hoc_normalizers = true
            ( @norm_p_a ||= [] ).push arg_and_oes_block_p
            NIL_
          end
        end

        public( def _apply_ad_hoc_normalizers prp  # this evolved from [#ba-027]

          # the integrated way of running these. compare to #here

          ok = true
          bx = actual_property_box_for_write
          prp.norm_p_a.each do | arg_and_oes_block_p |

            arg = trio_via_property_ prp
              # at each step, value might have changed.
              # [#053] bound is not truly bound.

            args = [ arg ]
            if 2 == arg_and_oes_block_p.arity
              args.push self
            end

            _oes_p = @on_event_selectively

            ok_arg = arg_and_oes_block_p.call( * args, & _oes_p )  # was [#072]

            if ok_arg
              bx.set arg.name_symbol, ok_arg.value_x
              KEEP_PARSING_
            else
              ok = ok_arg
              break
            end
          end
          ok
        end )

        def trio_via_property_ prp

          had = true

          x = actual_property_box.fetch prp.name_symbol do
            had = false
            nil
          end

          Callback_::Trio.via_value_and_had_and_property x, had, prp
        end



      # • "argument arity"

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

        def actual_property_box_for_write
          actual_property_box  # :+#hook-out
        end

        public def fetch_property_value_via_property prp, & else_p  # #hook-near
          actual_property_box.fetch prp.name_symbol, & else_p
        end



      # • default (that which is not covered by parent - it is a meta-meta-property)

        class self::Property

          # ~ :*#public-API

          def default_value_via_any_entity ent
            if @default_proc.arity.zero?
              @default_proc[]
            else
              @default_proc[ ent ]
            end
          end

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



      # • "description"

        class self::Property

          # ~ :*#public-API

          def description_proc
            @desc_p_a.fetch @desc_p_a.length - 1 << 1
          end

          attr_reader :has_description, :desc_p_a

          # ~

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
              @has_description = true
              ( @desc_p_a ||= [] ).push p
              KEEP_PARSING_
            else
              STOP_PARSING_
            end
          end
        end



      # • "environment", "hidden" (experiment)

        class self::Property

          attr_reader :can_be_from_environment, :is_hidden

        private

          def environment=
            @can_be_from_environment = true
            @is_hidden = true
            KEEP_PARSING_
          end

          def hidden=
            @is_hidden = true
            KEEP_PARSING_
          end
        end



      # • "integer" related

        class self::Property
        private

          def integer_greater_than_or_equal_to=
            add_normalizer_for_greater_than_or_equal_to_integer gets_one_polymorphic_value
          end

          def add_normalizer_for_greater_than_or_equal_to_integer d  # :+#public-API

            _NORMER = Brazen_.lib_.basic.normalizers.number(
              :number_set, :integer,
              :minimum, d )

            _append_ad_hoc_normalizer do | arg, & oes_p |
              if arg.value_x.nil?
                arg
              else
                _NORMER.normalize_argument arg, & oes_p
              end
            end
            KEEP_PARSING_
          end

          def non_negative_integer=

            _NORMER = Brazen_.lib_.basic.normalizers.number(
              :number_set, :integer,
              :minimum, 0 )

            _append_ad_hoc_normalizer do | arg, & oes_p |

              if arg.value_x.nil?
                arg
              else
                _NORMER.normalize_argument arg, & oes_p
              end
            end
            KEEP_PARSING_
          end
        end



      # • "parameter arity" - read synopsis [#fa-024]

        class self::Property

          def set_is_not_required
            @parameter_arity = :zero_or_one
            self
          end
        end

        public def receive_missing_required_properties_array miss_prop_a  # :+#public-API #hook-in #universal

          ev = Brazen_::Property.
            build_missing_required_properties_event miss_prop_a

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



        __during_entity_normalize do | ent |

          # :+[#087] common n11n algo. see [#006]:#specific-code-annotation

          kp = KEEP_PARSING_
          miss_prop_a = nil
          st = ent.formal_properties.to_value_stream
          prp = st.gets

          while prp

            x = ent.fetch_property_value_via_property prp do end

            if x.nil? and prp.has_default
              x = prp.default_value_via_any_entity ent
              kp = ent._set_property_value x, prp
              kp or break
            end

            # ( while #open [#088] ..
            if prp.norm_box_

              oes_p = ent.handle_event_selectively

              prp.norm_box_.each_value do | norm_p |

                kp = norm_p[ ent, prp, & oes_p ]
                kp or break
              end
            end
            # )

            if prp._has_ad_hoc_normalizers
              kp = ent._apply_ad_hoc_normalizers prp
              kp or break
              x = ent.fetch_property_value_via_property prp do end
            end

            if x.nil? && prp.is_required
              ( miss_prop_a ||= [] ).push prp
              kp = false
            end

            prp = st.gets
          end

          if miss_prop_a
            ent.receive_missing_required_properties_array miss_prop_a
          end

          kp
        end


      # • misc for nomenclature, description, etc.

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

          def under_expression_agent_get_N_desc_lines expag, n=nil

            LIB_.N_lines[ [], n, @desc_p_a, expag ]
          end
        end

      # ~ support

      # Callback_::Event.selective_builder_sender_receiver self

      private

        def ____NO__ # produce_handle_event_selectively_via_channel  # :+#public-API (#hook-in)

          # allow us to `maybe_send_event` at any cost

          p = super
          if p
            p
          else
            -> * , & ev_p do  # when we have no handler, we are honeybadger
              raise ev_p[].to_exception
            end
          end
        end



      # ~ courtesy


    def via_properties_init_ivars  # #note-360

      formals = self.formal_properties

      scn = formals.to_value_stream
      stack = Brazen_::Property::Stack.new formals.get_names  # could pass oes

      bx = any_secondary_box
      bx and stack.push_frame_via_box bx
      stack.push_frame_via_box primary_box

      while prop = scn.gets
        i = prop.name_symbol
        pptr = stack.any_proprietor_of i
        if pptr
          had_value = true
          x = pptr.property_value_via_symbol i
        else
          had_value = false
          x = nil
        end
        ivar = prop.as_ivar
        is_defined = instance_variable_defined? ivar
        is_defined and x_ = instance_variable_get( ivar )
        if is_defined && ! x_.nil?
          if had_value
            raise __say_wont_clobber_ivar( x, x_, ivar )
          end
        else
          instance_variable_set ivar, x
        end
      end
      NIL_
    end

    def __say_wont_clobber_ivar x_, x, ivar
      p = Brazen_::Lib_::Strange
      "sanity - won't clobber existing #{ ivar } #{
        }(#{ p[ x ] }) with new value (#{ p[ x_ ] })"
    end




    end  # end building the extension module
  end  # M-odel_
end  # sl [br]
