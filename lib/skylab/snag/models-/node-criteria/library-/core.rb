module Skylab::Snag

  module Models_::Node_Criteria

    module Library_

      Methodic_ = Callback_::Actor.methodic_lib

      module Association_Parse_Functions_

        def scan_the_verb_token_ st  # assume some. iff there is content after

          d = st.current_index
          if @verb_lemma == st.current_token_object.value_x
            st.advance_one
            if st.unparsed_exists
              d
            else
              st.current_index = d
              DID_NOT_PARSE__
            end
          end
        end

        def parse_a_verb_modifier_phrase_ st  # assume some

          bx = @named_functions_
          h = bx.h_
          sym, obj = bx.a_.reduce nil do | _, k |

            x = h.fetch( k ).output_node_via_input_stream st
            if x
              break [ k, x ]
            end
          end
          if sym
            Output_Node_.new obj.value_x, sym
          end
        end

        def parse_a_conjunctive_token_ st  # iff there is content after

          if st.unparsed_exists
            s = st.current_token_object.value_x
            sym = if OR___ == s
              :or
            elsif AND___ == s
              :and
            end
            if sym
              d = st.current_index
              st.advance_one
              if st.unparsed_exists
                sym
              else
                st.current_index = d
                DID_NOT_PARSE__
              end
            end
          end
        end
      end

      AND___ = 'and' ; OR___ = 'or'

      class Common_Adapter_

        include Methodic_.iambic_processing_instance_methods

        def process_iambic_stream_fully st
          _ok = super
          _ok && via_default_proc_and_is_required_normalize
        end
      end

      class Output_Node_

        def initialize x, sym
          @symbol = sym
          @value_x = x
        end

        attr_reader :symbol, :value_x

        def to_tree_
          LIB_.basic::Tree::Immutable_Leaf.new @symbol
        end
      end

      DID_NOT_PARSE_ = nil
      Library_ = self  # future proof the name, avoid mis-accessing super
      LIB_ = Snag_.lib_
      NEWLINE_ = "\n"
    end
  end
end
