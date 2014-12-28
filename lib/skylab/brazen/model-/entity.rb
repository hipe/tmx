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

      class << self::Module_Methods

        def defn_frozen_prop_a method_name, boolean_attr_reader_method_name

          # define a module method `method_name` that produces a frozen,
          # memoized array of properites that are true-ish along the
          # metaproperty indicated by `boolean_attr_reader_method_name`

          define_method method_name do
            h = @__entity_property_memoized_frozen_arrays__ ||= {}
            h.fetch method_name do
              h[ method_name ] = properties.reduce_by( & boolean_attr_reader_method_name ).to_a.freeze
            end
          end
          nil
        end

        def defn_any_frozen_prop_a method_name, boolean_attr_reader_method_name

          # as above but result in nil for arrays that are zero length

          define_method method_name do
            h = @__entity_property_memoized_frozen_arrays__ ||= {}
            h.fetch method_name do
              a = properties.reduce_by( & boolean_attr_reader_method_name ).to_a
              h[ method_name ] = ( a.freeze if a.length.nonzero? )
            end
          end
          nil
        end
      end



      # • ad-hoc normalizer

        class self::Entity_Property
        private
          def ad_hoc_normalizer=
            add_norm( & iambic_property )
          end

          def add_norm & p
            @has_ad_hoc_normalizers = true
            ( @norm_p_a ||= [] ).push p
            KEEP_PARSING_
          end
        public

          attr_reader :has_ad_hoc_normalizers, :norm_p_a
        end

        def prop_level_normalization_for_normalize
          ok = KEEP_PARSING_
          if self.class.any_ary_of_properties_with_ad_hoc_normalizers
            self.class.any_ary_of_properties_with_ad_hoc_normalizers.each do |pr|
              ok = aply_ad_hoc_normalizers pr
              ok or break
            end
          end
          ok
        end

        module self::Module_Methods
          defn_any_frozen_prop_a :any_ary_of_properties_with_ad_hoc_normalizers, :has_ad_hoc_normalizers
        end

        def aply_ad_hoc_normalizers pr  # this evolved from [#fa-019]
          ok = true
          bx = actual_property_box_for_write
          pr.norm_p_a.each do | three_p |

            arg = get_bound_property_via_property pr
              # at each step, value might have changed.
              # [#053] bound is not truly bound.

            ok = three_p.call arg,

              -> new_value_x do
                bx.set arg.name_i, new_value_x
                KEEP_PARSING_
              end,

              -> * x_a, msg_p do  # #open [#072]
                maybe_send_event :error, x_a.first do
                  build_event_via_iambic_and_message_proc x_a, msg_p
                end
              end

            ok or break
          end
          ok
        end



      # • "argument arity"

        class self::Entity_Property
        private
          def flag=
            @argument_arity = :zero
            KEEP_PARSING_
          end

        public

          def argument_is_required  # *not the same as* parameter is required
            :one == @argument_arity or :one_to_many == @argument_arity
          end

          def takes_argument
            :one == @argument_arity
          end

          def takes_many_arguments
            :zero_to_many == @argument_arity or :one_to_many == @argument_arity
          end
        end

        def receive_value_of_entity_property x, prop  # #hook-in

          # overwrite this hook-in called by our produced iambic writer methods
          # (determiend by topic) so that we write not to ivars but to this box.

          actual_property_box_for_write.add prop.name_i, x
          KEEP_PARSING_
        end

        def actual_property_box_for_write
          actual_property_box  # :++#hook-out
        end

        def any_property_value_via_property prop
          actual_property_box[ prop.name_i ]  # :++#hook-out
        end



      # • "argument moniker" (used in some modalities to label the arg iteslf)

      o :meta_property, :argument_moniker



      # • default

      o :property_hook, -> pc do

          _DEFAULT_X = pc.upstream.gets_one
          # we future-pad it to accomodate one day procs and not just values

          ( -> prop do
            prop.set_dflt_proc do | _entity |  # [#hl-119] name conventions are employed
              _DEFAULT_X
            end
          end )
        end,

        :meta_property, :default

        class self::Entity_Property

          def set_dflt_proc & p
            @has_default = true
            @dflt_p = p
            KEEP_PARSING_
          end

          attr_reader :has_default

          def default_value_via_any_entity ent  # :+#public-API
            @dflt_p[ ent ]
          end
        end

        def dflt_for_normalize
          ok = KEEP_PARSING_
          if self.class.any_ary_of_defaulting_props
            self.class.any_ary_of_defaulting_props.each do | pr |
              x = any_property_value_via_property pr
              if x.nil?
                ok = receive_value_of_entity_property( pr.default_value_via_any_entity( self ), pr )
                ok or break
              end
            end
          end
          ok
        end

        module self::Module_Methods
          defn_any_frozen_prop_a :any_ary_of_defaulting_props, :has_default
        end



      # • "description"

        class self::Entity_Property
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

        public
          attr_reader :has_description, :desc_p_a
        end



      # • "environment", "hidden" (experiment)

        class self::Entity_Property
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

        public

          attr_reader :can_be_from_environment, :is_hidden

          def upcase_environment_name_symbol
            :"BRAZEN_#{ @name.as_variegated_symbol.upcase }"
          end
        end



      # • "integer" related

        class self::Entity_Property
        private
          def integer_greater_than_or_equal_to=

            _NORMER = Model_::Entity.normalizers.number(
              :number_set, :integer,
              :minimum, iambic_property )

            add_norm do | arg, val_p, ev_p |
              if arg.value_x.nil?
                KEEP_PARSING_
              else
                _NORMER.normalize_via_three arg, val_p, ev_p
              end
            end
          end

          def non_negative_integer=

            _NORMER = Model_::Entity.normalizers.number(
              :number_set, :integer,
              :minimum, 0 )

            add_norm do | arg, val_p, ev_p |
              if arg.value_x.nil?
                KEEP_PARSING_
              else
                _NORMER.normalize_via_three arg, val_p, ev_p
              end
            end
          end
        end



      # • "parameter arity" - read synopsis [#fa-024]

        class self::Entity_Property
        private
          def required=
            @parameter_arity = :one
            KEEP_PARSING_
          end
        end

        def chck_parameter_arity_for_normalize
          miss_a = self.class.ary_of_nonzero_param_arity_props.reduce nil do | m, pr |
            _x = any_property_value_via_property pr
            if _x.nil?
              ( m ||= [] ).push pr
            end
            m
          end
          if miss_a
            receive_missing_required_props miss_a
          else
            KEEP_PARSING_
          end
        end

        module self::Module_Methods
          defn_frozen_prop_a :ary_of_nonzero_param_arity_props, :is_required
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



        # near [#006] we aggregate three of the above concerns into this one
        # normalization hook because a) logically the order in which they are
        # called must be fixed with respect to one another and b) there is
        # less jumping around this way. if we require more modularity these
        # can be broken up into separate hooks but the relative order must
        # be as below: 1) first default those that are nil 2) apply any
        # custom normalizations defined for the property 3) check that there
        # are no nil required fields.

        during_entity_normalize do | ent |
          _ok = ent.dflt_for_normalize
          _ok &&= ent.prop_level_normalization_for_normalize
          _ok && ent.chck_parameter_arity_for_normalize
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
