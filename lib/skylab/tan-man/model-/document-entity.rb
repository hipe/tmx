module Skylab::TanMan

  class Model_

    class Document_Entity < self

      class Silo < Brazen_.model.silo_class

        def collection_controller_via_document_controller dc, & oes_p

          pc = Callback_::Box.new
          pc.add :dot_file, dc

          mc = model_class

          mc.collection_controller_class.new_with(
            :action, :__no_action__,
            :preconditions, pc,
            :model_class, mc,
            :kernel, @kernel, & oes_p )
        end

        def model_class
          self.class.__model_class
        end

        class << self
          def __model_class
            @__model_class ||= TanMan_.lib_.basic::Module.value_via_relative_path( self, '..' )
          end
        end
      end

      Silo_Controller = ::Class.new Brazen_.model.silo_controller_class

      class Collection_Controller < Brazen_.model.collection_controller_class

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

      class << self

        def IO_properties
          IO_properties__[].each_value
        end

        def IO_properties_shell
          IO_properties__[]
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

          sess = _new_IO_arg_partition_session

          @input_argument_a, @output_argument_a = sess.to_input_and_output_args

          _bc = sess.bound_call_unless_exactly_one_means @input_argument_a, :input
          _bc or sess.bound_call_unless_exactly_one_means @output_argument_a, :output
        end

        def resolve_document_upstream_or_produce_bound_call_

          sess = _new_IO_arg_partition_session

          @input_argument_a = sess.to_input_args

          sess.bound_call_unless_exactly_one_means @input_argument_a, :input
        end

        def _new_IO_arg_partition_session
          IO_Argument_Partition_Session.new(
            method( :to_actual_argument_stream ),
            self.class.properties,
            & handle_event_selectively )
        end
      end

      class IO_Argument_Partition_Session

        def initialize to_arg_stream, prp, & oes_p
          @on_event_selectively = oes_p
          @properties = prp
          @to_actual_arg_stream = to_arg_stream
        end

        def to_one_input_and_one_output_arg
          in_a, out_a = to_input_and_output_args
          ok = _one in_a, :input
          ok &&= _one( out_a, :output )
          ok and begin
            [ in_a.fetch( 0 ), out_a.fetch( 0 ) ]
          end
        end

        def _one a, sym
          case 1 <=> a.length
          when -1
            _maybe_send_non_one_event a, sym  # or pick one ..
          when  0
            a.fetch 0
          when  1
            _maybe_send_non_one_event a, sym
          end
        end

        def to_input_and_output_args

          in_a = []
          out_a = []

          st = _to_IO_related_twosome_stream
          o = st.gets
          while o

            if o.property.can_be_used_for_input
              in_a.push o.pair
            end

            if o.property.can_be_used_for_output
              out_a.push o.pair
            end

            o = st.gets
          end

          [ in_a, out_a ]
        end

        def to_input_args
          _to_IO_related_twosome_stream.map_reduce_by do | o |

            if o.property.can_be_used_for_input
              o.pair
            end
          end.to_a
        end

        def _to_IO_related_twosome_stream

          props = @properties

          @to_actual_arg_stream[].map_reduce_by do | pair |

            if pair.value_x  # intentionally set nils are meaningless here

              prp = props[ pair.name_symbol ]  # the formals may be some
                # arbitrary other set, like e.g they are the topic formals

              if prp and prp.respond_to? :can_be_used_for_input  # not all props relate

                if :config_filename != prp.name_symbol  # not relevant to counts

                  Twosome___[ pair, prp ]
                end
              end
            end
          end
        end

        Twosome___ = ::Struct.new :pair, :property

        def bound_call_unless_exactly_one_means arg_a, direction_i
          case 1 <=> arg_a.length
          when  1
            __bc_when_non_1_doc_IO arg_a, direction_i
          when -1
            self._DO_ME  # do we play favorites or fail with ambiguity?
          end
        end

        def __bc_when_non_1_doc_IO arg_a, direction_i
          Brazen_.bound_call.via_value _maybe_send_non_one_event( arg_a, direction_i )
        end

        def _maybe_send_non_one_event arg_a, direction_i

          @on_event_selectively.call :error, :non_one_IO do
            __build_non_one_IO_event direction_i, arg_a
          end
        end

        def __build_non_one_IO_event direction_i, arg_a

          _PROPS = @properties

          Callback_::Event.inline_not_OK_with :non_one_IO,
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
        # we attempt to resolve (as necessary per the operation) exactly
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
