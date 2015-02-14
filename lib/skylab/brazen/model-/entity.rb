module Skylab::Brazen

  class Model_

    Entity = Brazen_::Entity.call do  # see [#047]

      class << self

        def normalizers
          LIB_.basic.normalizers
        end

        def trio
          LIB_.trio
        end
      end

      # ~ ad-hoc processors

      o :ad_hoc_processor, :after, -> pc do  # pc = "parse context"
        pc.upstream.advance_one
        pc.downstream.after_name_symbol = pc.upstream.gets_one
        KEEP_PARSING_
      end

      o :ad_hoc_processor, :desc, -> pc do
        pc.upstream.advance_one  # `desc`
        pc.downstream.description_block = pc.upstream.gets_one
        KEEP_PARSING_
      end

      o :ad_hoc_processor, :inflect, -> pc do
        pc.upstream.advance_one  # `inflect`
        pc.downstream.process_some_customized_inflection_behavior pc.upstream
      end

      o :ad_hoc_processor, :promote_action, -> pc do
        pc.upstream.advance_one
        pc.downstream.is_promoted = true
        KEEP_PARSING_
      end

      o :ad_hoc_processor, :persist_to, -> pc do
        pc.upstream.advance_one
        pc.downstream.persist_to = pc.upstream.gets_one
        KEEP_PARSING_
      end

      o :ad_hoc_processor, :preconditions, -> pc do
        pc.upstream.advance_one
        a = pc.downstream.precondition_controller_i_a
        a_ = pc.upstream.gets_one
        if a
          self._COVER_ME
        else
          pc.downstream.precondition_controller_i_a = a_
        end
        KEEP_PARSING_
      end

      o :ad_hoc_processor, :precondition, -> pc do
        pc.upstream.advance_one
        i_a = ( pc.downstream.precondition_controller_i_a ||= [] )
        i = pc.upstream.gets_one
        i_a.include?( i ) or i_a.push i
        KEEP_PARSING_
      end

      # ~ metaproperties (support)

      @active_entity_edit_session.ignore_methods_added

        # hack turn this off. we won't be adding any fields via
        # method deinitions in this edit session


      entity_property_class_for_write  # touch our own `Entity_Property` cls

      # • ad-hoc normalizer

        class self::Entity_Property

        private

          def ad_hoc_normalizer=
            _add_ad_hoc_normalizer( & iambic_property )
            KEEP_PARSING_
          end

        public

          def add_ad_hoc_normalizer & arg_and_oes_block_p
            _add_ad_hoc_normalizer( & arg_and_oes_block_p )
            self
          end

          def _add_ad_hoc_normalizer & arg_and_oes_block_p
            @has_ad_hoc_normalizers = true
            ( @norm_p_a ||= [] ).push arg_and_oes_block_p
            nil
          end

          attr_reader :has_ad_hoc_normalizers, :norm_p_a
        end

        def _apply_ad_hoc_normalizers pr  # this evolved from [#ba-027]
          ok = true
          bx = actual_property_box_for_write
          pr.norm_p_a.each do | arg_and_oes_block_p |

            arg = trio_via_property pr
              # at each step, value might have changed.
              # [#053] bound is not truly bound.

            args = [ arg ]
            if 2 == arg_and_oes_block_p.arity
              args.push self
            end
            ok_arg = arg_and_oes_block_p.call( * args, & handle_event_selectively )  # was [#072]

            if ok_arg
              bx.set arg.name_symbol, ok_arg.value_x
              KEEP_PARSING_
            else
              ok = ok_arg
              break
            end
          end
          ok
        end



      # • "argument arity"

        class self::Entity_Property

          def argument_is_required  # *not the same as* parameter is required
            :one == @argument_arity or :one_or_more == @argument_arity
          end

          def takes_argument
            :one == @argument_arity
          end

          def takes_many_arguments
            :zero_or_more == @argument_arity or :one_or_more == @argument_arity
          end

        private

          def flag=
            @argument_arity = :zero
            KEEP_PARSING_
          end
        end

        def receive_list_of_entity_property a, prp  # #hook-out to [cb]
          receive_value_of_entity_property a, prp
        end

        def receive_value_of_entity_property x, prp  # #hook-in

          # overwrite this hook-in called by our produced iambic writer methods
          # (determiend by topic) so that we write not to ivars but to this box.

          actual_property_box_for_write.set prp.name_symbol, x  # (changed from `add`)
          KEEP_PARSING_
        end

        def actual_property_box_for_write
          actual_property_box  # :+#hook-out
        end

        def any_property_value_via_property prop
          actual_property_box[ prop.name_i ]  # :++#hook-out
        end



      # • "argument moniker" (used in some modalities to label the arg iteslf)

      o :meta_property, :argument_moniker



      # • default (used to be a declared metaproperty, now is hand-written)

        class self::Entity_Property

          # ~ :*#public-API

          def default_value_via_any_entity ent
            if @default_p.arity.zero?
              @default_p[]
            else
              @default_p[ ent ]
            end
          end

          def default_proc
            @default_p
          end

          attr_reader :has_default, :has_primitive_default, :primitive_default_value

          # ~

        private

          def default=
            set_primitive_default iambic_property
            KEEP_PARSING_
          end

          def default_proc=
            set_default_proc( & iambic_property )
            KEEP_PARSING_
          end

        protected

          def init_without_default_
            super
            @has_primitive_default = false
            @primitive_default_value = nil
            nil
          end

        public

          def new_with_default & p
            dup.set_default_proc( & p ).freeze
          end

          def new_with_primitive_default x
            dup.set_primitive_default( x ).freeze
          end

          def set_default_proc & p
            @has_default = true
            @has_primitive_default = false
            @primitive_default_value = nil
            @default_p = p
            self
          end

          def set_primitive_default x
            @has_default = true
            @has_primitive_default = true
            @primitive_default_value = x
            @default_p = -> do
              @primitive_default_value
            end
            self
          end
        end



      # • "description"

        class self::Entity_Property

          # ~ :*#public-API

          def description_proc
            @desc_p_a.fetch @desc_p_a.length - 1 << 1
          end

          attr_reader :has_description, :desc_p_a

          # ~

        private

          def description=
            x = iambic_property
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

        class self::Entity_Property

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

        class self::Entity_Property
        private
          def integer_greater_than_or_equal_to=

            _NORMER = Model_::Entity.normalizers.number(
              :number_set, :integer,
              :minimum, iambic_property )

            _add_ad_hoc_normalizer do | arg, & oes_p |
              if arg.value_x.nil?
                arg
              else
                _NORMER.normalize_argument arg, & oes_p
              end
            end
            KEEP_PARSING_
          end

          def non_negative_integer=

            _NORMER = Model_::Entity.normalizers.number(
              :number_set, :integer,
              :minimum, 0 )

            _add_ad_hoc_normalizer do | arg, & oes_p |

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

        class self::Entity_Property

          def set_is_not_required
            @parameter_arity = :zero_or_one
            self
          end
        private
          def required=
            @parameter_arity = :one
            KEEP_PARSING_
          end
        end

        def receive_missing_required_props miss_prop_a
          _ev = Brazen_::Entity.properties_stack.
            build_missing_required_properties_event miss_prop_a
          receive_missing_required_properties _ev
        end

        def receive_missing_required_properties ev  # :+#public-API #hook-in #universal
          raise ev.to_exception
        end

        def receive_missing_required_properties_softly ev  # popular :+#hook-with
          # (was :+[#054] #tracking error count)
          maybe_send_event :error, ev.terminal_channel_i do
            ev
          end
        end



        during_entity_normalize do | ent |  # see [#006]:#specific-code-annotation

          ok = true
          miss_prop_a = nil
          st = ent.formal_properties.to_stream
          prp = st.gets

          while prp

            x = ent.any_property_value_via_property prp

            if x.nil? and prp.has_default
              x = prp.default_value_via_any_entity ent
              ok = ent.receive_value_of_entity_property x, prp
              ok or break
            end

            if prp.has_ad_hoc_normalizers
              ok = ent._apply_ad_hoc_normalizers prp
              ok or break
              x = ent.any_property_value_via_property prp
            end

            if x.nil? && prp.is_required
              ( miss_prop_a ||= [] ).push prp
              ok = false
            end

            prp = st.gets
          end

          if miss_prop_a
            ent.receive_missing_required_props miss_prop_a
          end

          ok
        end


      # • misc for nomenclature, description, etc.

        class self::Entity_Property

          def has_custom_moniker  # [#014] maybe a smell, maybe not
            false
          end

          def under_expression_agent_get_N_desc_lines expression_agent, n=nil
            LIB_.N_lines.
              new( [], n, @desc_p_a, expression_agent ).execute
          end
        end

      # ~ support

      Brazen_.event.selective_builder_sender_receiver self

      private

        def produce_handle_event_selectively_via_channel  # :+#public-API (#hook-in)

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
      formal = self.formal_properties
      scn = formal.to_stream

      stack = Brazen_::Entity.properties_stack.new formal.get_names  # could pass oes
      bx = any_secondary_box
      bx and stack.push_frame_via_box bx
      stack.push_frame_via_box primary_box

      while prop = scn.gets
        i = prop.name_i
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
            raise say_wont_clobber_ivar( x, x_, ivar )
          end
        else
          instance_variable_set ivar, x
        end
      end ; nil
    end

    def say_wont_clobber_ivar x_, x, ivar
      p = Brazen_::Lib_::Strange
      "sanity - won't clobber existing #{ ivar } #{
        }(#{ p[ x ] }) with new value (#{ p[ x_ ] })"
    end




    end  # end building the extension module
  end  # M-odel_
end  # sl [br]
