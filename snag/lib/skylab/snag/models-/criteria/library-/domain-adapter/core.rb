module Skylab::Snag

  class Models_::Criteria

    module Library_

      class DomainAdapter

        # immutability? who needs it! conceived in [#029]

        class << self

          def via_NLP_const_and_invocation_resources__ const, invo_rsx

            # crazy but OK: in order for every "silo" to write their domain-
            # specific linguistic knowledge into the subject, we traverse
            # over all the "model" "modules (those that are modules) and:

            mutable_me = __begin_mutable_me

            scn = invo_rsx.microservice_feature_branch_.to_symbolish_reference_scanner

            until scn.no_unparsed_exists

              ref = scn.gets_one

              x = ref.dereference_loadable_reference
              if ! x.respond_to? :const_get
                next  # maybe the "silo" is not a module. (ping used to be this. no longer)
              end

              expads = x.const_get :ExpressionAdapters, false
              if ! expads
                next  # the "silo" is stating explicitly that it doesn't participate
              end

              p = expads.const_get :EN, false
              if ! p
                next
              end

              p[ mutable_me ]
            end

            mutable_me
          end

          alias_method :__begin_mutable_me, :new  # #testpoint
          undef_method :new
        end  # >>

        def initialize

          @model_box_ = Common_::Box.new
        end

        def new_criteria_tree_via_word_array s_a, & x_p

          Here___::Magnetics_::CriteriaInterpretation_via_Arguments.new( s_a, self, & x_p ).execute
        end

        # ~ write

        def under_target_model_add_association_adapter id_x, assoc_adptr

          mdl_rfx = _model_reflection id_x
          assoc_adptr.receive_model_identifier_ mdl_rfx.identifier
          mdl_rfx.__add_association_adapter assoc_adptr
          NIL_
        end

        def source_and_target_models_are_associated id_x, id_x_

          _model_reflection( id_x ).__receive_knowledge_of_associated_model(
            _normalize_model_identifier( id_x_ ) )

          NIL_
        end

        def module
          Library_
        end

        # ~ support

        def _model_reflection id_x

          sym_a = _normalize_model_identifier id_x

          @model_box_.touch sym_a do
            Model_Reflection___.new sym_a
          end
        end

        def _normalize_model_identifier x

          ::Array.try_convert( x ) || [ x ]
        end

        # ~ public API for private ancillary nodes (actors etc)

        def interpret__model_reflection__via__singular_model_name__ in_st, & p

          _produce_one_model_reflection_by in_st, p do | model_rfx |
            model_rfx.to_item_for_singular_name
          end
        end

        def interpret__model_reflection__via__plural_model_name__ in_st, & p

          _produce_one_model_reflection_by in_st, p do | model_rfx |
            model_rfx.to_item_for_plural_name
          end
        end

        def _produce_one_model_reflection_by in_st, p, & rfx_p

          _f = Home_.lib_.parse_lib.function(

            :item_from_matrix

          ).via_item_stream_proc do

            _to_model_reflection_stream( & rfx_p )
          end

          pair = _f.output_node_via_input_stream in_st, & p
          pair and pair.value
        end

        def _to_model_reflection_stream & map_p

          if map_p
            @model_box_.to_value_stream.map_by( & map_p )
          else
            @model_box_.to_value_stream
          end
        end

        def possible_assoc_adptrs_through_longest_head_verb_ in_st, g_ctxt, mdl_id, & x_p

          _mod_rfx = @model_box_.h_.fetch mdl_id

          _ada_st = _mod_rfx.__to_association_adapter_stream @model_box_

          Produce_highest_scoring_candidates_.call(
              in_st,
              _ada_st,
              x_p ) do | in_st_, f, & p_ |

            f.interpret_verb_phrase_head_out_of_under_ in_st_, g_ctxt, & p_
          end
        end

        class Model_Reflection___

          def initialize sym_a

            @associated_models_box = Common_::Box.new
            @_sym_a = sym_a
          end

          # ~ name-related

          def identifier
            @_sym_a
          end

          def to_item_for_plural_name

            @__plural_item ||= __build_plural_item
          end

          def __build_plural_item

            s_a = _human_s_a
            s_a_ = s_a.dup
            s_a_[ -1 ] = Home_.lib_.NLP::EN::POS::Noun[ s_a.fetch( -1 ) ].plural
            Common_::QualifiedKnownKnown.via_value_and_association self, s_a_
          end

          def to_item_for_singular_name

            @__singular_item ||= __build_singular_item
          end

          def __build_singular_item

            Common_::QualifiedKnownKnown.via_value_and_association self, _human_s_a
          end

          def _human_s_a

            @__human_s_a ||= __build_human_s_a
          end

          def __build_human_s_a

            @_sym_a.map do | sym |
              Common_::Name.via_const_symbol( sym ).as_human
            end
          end

          # ~ association-related

          def __to_association_adapter_stream model_bx_

            h = model_bx_.h_
            _st = Stream_[ @associated_models_box.a_ ]

            _st.expand_by do | id |

              Stream_[ h.fetch( id ).__association_adapters || fail ]
            end
          end

          # ~ writers

          def __receive_knowledge_of_associated_model id

            @associated_models_box.touch id do
              true
            end
            NIL_
          end

          def __add_association_adapter assoc_adptr
            ( @__association_adapters ||= [] ).push assoc_adptr
            NIL_
          end

          attr_reader :__association_adapters
        end

        Here___ = self
      end
    end
  end
end
