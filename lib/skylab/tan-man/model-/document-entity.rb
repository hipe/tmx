module Skylab::TanMan

  class Model_

    class Document_Entity < self

      class Collection_Controller < Brazen_.model.collection_controller

      private

        def flush_maybe_changed_document_to_output_adapter did_mutate
          if did_mutate
            flush_changed_document_to_ouptut_adapter
          else
            when_document_did_not_change
          end
        end

        def when_document_did_not_change
          maybe_send_event :info, :document_did_not_change do
            build_neutral_event_with :document_did_not_change do |y, o|
              y << "document did not change."
            end
          end ; nil
        end

        def flush_changed_document_to_ouptut_adapter
          datastore_controller.persist_via_args(
            @action.any_argument_value( :dry_run, ), * @action.output_arguments )
        end

      public def unparse_entire_document
          datastore_controller.unparse_entire_document
        end

        def datastore_controller
          @preconditions.fetch :dot_file  # yes
        end
      end

      class Silo_Controller < Brazen_.model.silo_controller

      end

      class << self

        def IO_properties
          IO_properties__[].each_value
        end

        def input_properties  # an array
          Input_properties__[]
        end

        def action_class
          Action__
        end
      end

      class Action__ < Action_

        def input_arguments
          @input_argument_a
        end

        def output_arguments
          @output_argument_a
        end

      private

        def resolve_document_IO_or_produce_bound_call_

          @input_argument_a, @output_argument_a = __input_pairs_and_output_pairs

          _bc = _mutate_exactly_1_means_or_bc( @input_argument_a, :input )
          _bc || _mutate_exactly_1_means_or_bc( @output_argument_a, :output )
        end

        def __input_pairs_and_output_pairs

          in_a = []
          out_a = []

          props = self.class.properties

          st = to_actual_argument_stream

          while pair = st.gets

            pair.value_x or next
              # intentionally set nils are meaningless here

            prp = props.fetch pair.name_symbol

            prp.respond_to? :can_be_used_for_input or next
              # certainly not all properties are related to this topic

            :config_filename == prp.name_symbol and next
              # this property is important but not relevant to our counts here

            if prp.can_be_used_for_input
              in_a.push pair
            end

            if prp.can_be_used_for_output
              out_a.push pair
            end
          end

          [ in_a, out_a ]
        end

        def _mutate_exactly_1_means_or_bc arg_a, direction_i
          case 1 <=> arg_a.length
          when  1
            __bc_when_non_1_doc_IO arg_a, direction_i
          when -1
            self._DO_ME  # do we play favorites or fail with ambiguity?
          end
        end

        def __bc_when_non_1_doc_IO arg_a, direction_i
          _x = maybe_send_event :error, :non_one_IO do
            bld_non_one_IO_event direction_i, arg_a
          end
          Brazen_.bound_call.via_value _x
        end

        def bld_non_one_IO_event direction_i, arg_a

          _PROPS = self.class.properties

          build_not_OK_event_with :non_one_IO,
              :direction_i, direction_i, :arg_a, arg_a do |y, o|

            if o.arg_a.length.zero?

              meth_sym = {
                input: :can_be_used_for_input,
                output: :can_be_used_for_output
              }.fetch o.direction_i

              _prop_a = _PROPS.reduce_by do |arg|

                prp = _PROPS.fetch arg.name_symbol

                prp.respond_to?( meth_sym ) and  # :+[#br-046]
                   prp.send( meth_sym ) and
                     :config_filename != prp.name_symbol

              end

              _s_a = _prop_a.map do |x|
                par x
              end

              _xtra = " (provide #{ or_ _s_a })"

            else
              _s_a = arg_a.map do |arg|
                par _PROPS.fetch arg.name_symbol
              end
              _xtra = " (#{ _s_a * ', ' })"
            end
            y << "need exactly 1 #{ o.direction_i }-related argument, #{
             }had #{ o.arg_a.length }#{ _xtra }"
          end
        end
      end

      IO_properties__ = Callback_.memoize do

        # every (relevant) document entity action does at least one of the
        # following: 1) operate on an input graph 2) produce an output graph.
        #
        # the below table expresses the traits along these lines for a
        # typical document entity action:
        #
        #     create   [ maybe one input ]   definitely one output
        #     list     definitely one input
        #     delete   definitely one input  definitely one output
        #
        # as the above table suggests, operations that mutate the graph
        # need one output. every operation can potentially start with an
        # existing graph. in fact all operations necessarily start with
        # an existing graph except (perhaps) the create operation.
        #
        # as such, the typical action of the document entity needs to resolve
        # maybe one input plan, maybe one output plan, and at least one of
        # these if not both. inputs and outputs alike can be expressed
        # variously as a string (buffer), a path, or as properties in the
        # workspace.
        #
        # the properties for string and path are straightforward: there
        # exist four specific properties for the the four permutations
        # (`input_string`, `output_path` and the other two.)
        #
        # however, if a workspace is expressed in the argument list,
        # this *can* be used to express both input and output graph.
        #
        # we attempt to resovle (as necessary per the operation) exactly
        # one input means and exactly one output means.

        module IO_Proprietor____

          TanMan_::Entity_.call self do

            entity_property_class_for_write  # until #wishlist [#br-084] a flag meta meta property
            class Entity_Property

              attr_reader :can_be_used_for_input,
                :can_be_used_for_output

            private

              def can_be_used_for_input=
                @can_be_used_for_input = true
              end

              def can_be_used_for_output=
                @can_be_used_for_output = true
              end
            end

            o :can_be_used_for_input, :property, :input_string,
            :can_be_used_for_input, :property, :input_path,

            :can_be_used_for_output, :property, :output_string,
            :can_be_used_for_output, :property, :output_path,

            :can_be_used_for_input,
            :can_be_used_for_output, :property, :workspace_path,

            :can_be_used_for_input,
            :can_be_used_for_output, :property, :config_filename

          end

          self
        end.properties
      end

      Input_properties__ = Callback_.memoize do

        IO_properties__[].to_stream.reduce_by( & :can_be_used_for_input ).to_a.freeze

      end
    end
  end
end
