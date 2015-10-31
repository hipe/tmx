module Skylab::Snag

  class Models_::Criteria

    module Library_

      class Domain_Adapter

        # immutability? who needs it! conceived in [#029]

        class << self

          def new_via_kernel_and_NLP_const kr, const

            x = new kr
            src = kr.reactive_tree_seed

            src.constants.each do | const_ |

              x_ = src.const_get const_, false
              x_.respond_to? :const_get or next

              p = x_.const_get( :Expression_Adapters, false ).
                const_get :EN, false

              p or next
              p[ x ]
            end
            x
          end
        end  # >>

        def initialize kr

          @_kernel = kr
          @model_box_ = Callback_::Box.new
        end


        def new_criteria_tree_via_word_array s_a, & x_p

          DA_::Actors_::Interpret_criteria.new( s_a, self, & x_p ).execute
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

        def interpret__model_reflection__via__singular_model_name__ in_st, & oes_p

          _produce_one_model_reflection_by in_st, oes_p do | model_rfx |
            model_rfx.to_item_for_singular_name
          end
        end

        def interpret__model_reflection__via__plural_model_name__ in_st, & oes_p

          _produce_one_model_reflection_by in_st, oes_p do | model_rfx |
            model_rfx.to_item_for_plural_name
          end
        end

        def _produce_one_model_reflection_by in_st, oes_p, & rfx_p

          _f = Home_.lib_.parse_lib.function(

            :item_from_matrix

          ).new_via_item_stream_proc do

            _to_model_reflection_stream( & rfx_p )
          end

          pair = _f.output_node_via_input_stream in_st, & oes_p
          pair and pair.value_x
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
              x_p ) do | in_st_, f, & oes_p_ |

            f.interpret_verb_phrase_head_out_of_under_ in_st_, g_ctxt, & oes_p_
          end
        end

        class Model_Reflection___

          def initialize sym_a

            @associated_models_box = Callback_::Box.new
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
            Callback_::Pair.new self, s_a_
          end

          def to_item_for_singular_name

            @__singular_item ||= __build_singular_item
          end

          def __build_singular_item

            Callback_::Pair.new self, _human_s_a
          end

          def _human_s_a

            @__human_s_a ||= __build_human_s_a
          end

          def __build_human_s_a

            @_sym_a.map do | sym |
              Callback_::Name.via_const( sym ).as_human
            end
          end

          # ~ association-related

          def __to_association_adapter_stream model_bx_

            h = model_bx_.h_
            _st = Callback_::Stream.via_nonsparse_array @associated_models_box.a_

            _st.expand_by do | id |

              Callback_::Stream.via_nonsparse_array(
                h.fetch( id ).__association_adapters || fail )
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

        Autoloader_[ Actors_ = ::Module.new ]

        DA_ = self
      end
    end
  end
end
