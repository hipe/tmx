module Skylab::TanMan

  class Models_::Hear_Front < Model_

    Actions = ::Module.new

    class Actions::Hear < Action_

      @is_promoted = true

      @after_name_symbol = :status

      Entity_.call self,

        :branch_description, -> y do
          y << 'experimental natural language-ISH interface'
        end,

        :inflect, :noun, nil, :verb, 'understand',

        :reuse, Model_::Document_Entity.IO_properties,

        :flag, :property, :dry_run,

        :required, :argument_arity, :one_or_more, :property, :word

      def produce_result

        bx = to_qualified_knownness_box__

        bx.add :stdout, Common_::Qualified_Knownness.
          via_value_and_symbol( stdout_, :stdout )

        bc = @kernel.silo( :hear_front ).__bound_call_via_qualified_knownness_box(
          bx,
          & handle_event_selectively )

        if bc
          bc.receiver.send bc.method_name, * bc.args
        else
          bc
        end
      end
    end

    class Silo_Daemon < ::Object

      # every top-level model node has zero or more parse functions. these are
      # instantiated lazily, only as many as are needed to find one that
      # parses the input. but each that is created is cached, so that we only
      # ever create one parse function for the lifetime of the process.

      def initialize k, _model_class

        @k = k

        _st = Common_::Stream.ordered __to_definition_stream

        @definition_collection =
          _st.flush_to_immutable_with_random_access_keyed_to_method(
            :name_value_for_order )
      end

      def __bound_call_via_qualified_knownness_box bx, & oes_p

        word_s_a = bx.fetch( :word ).value_x

        upstream = Home_.lib_.parse_lib.input_stream.via_array word_s_a

        st = @definition_collection.to_value_stream
        dfn = st.gets
        while dfn
          on = dfn.parse_function.output_node_via_input_stream upstream
          on and break
          upstream.current_index = 0
          dfn = st.gets
        end

        if on
          dfn.external_definition.bound_call_via_heard(
            Heard__[ on.value_x, bx, @k ], & oes_p )
        else
          __when_no_matching_definition word_s_a, & oes_p
        end
      end

      def __to_definition_stream

        __to_name_of_module_that_has_hear_map_stream.expand_by do | nm |

          bx = Home_::Models_.const_get( nm.as_const, false ).const_get( :Hear_Map, false )::Definitions

          Common_::Stream.via_nonsparse_array bx.constants do | const |

            Definition__.new(
              bx.const_get( const, false ),
              const,
              nm )

          end
        end
      end

      Heard__ = ::Struct.new :parse_tree, :qualified_knownness_box, :kernel

      def __to_name_of_module_that_has_hear_map_stream

        Common_::Stream.via_nonsparse_array(

          ::Dir[ "#{ Models_.dir_pathname }/*/hear-map#{ Autoloader_::EXTNAME }" ]

            # just reading from the filesystem is easier and cheaper

        ) do | path |

          Common_::Name.via_slug( ::File.basename ::File.dirname path )
        end
      end

      def __when_no_matching_definition words, & oes_p

        oes_p.call :error, :unrecognized_utterance do

          _f_a = @definition_collection.to_value_stream.map_by do | x |
            x.parse_function
          end.to_a

          Common_::Event.inline_not_OK_with :unrecognized_utterance,
              :words, words,
              :parse_functions, _f_a do | y, o |

            y << "unrecognized input #{ ick o.words }. known definitions: "

            o.parse_functions.each do | f |
              y << f.express_all_segments_into_under( "" )
            end

            nil
          end
        end
      end
    end

    class Definition__

      def initialize cls, const, nm

        @external_definition = cls.new

        @name_value_for_order = [ nm.as_lowercase_with_underscores_symbol,
          Common_::Name.via_const_symbol( const ).as_lowercase_with_underscores_symbol ]

        @parse_function = Home_.lib_.parse_lib.function_via_definition_array(
          @external_definition.definition )

      end

      attr_reader :external_definition, :name_value_for_order, :parse_function

      def after_name_value_for_order
        @external_definition.after
      end
    end
  end
end
# (historical note of #posterity: this used to be *THE* PEG grammar file.)
