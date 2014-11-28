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
          datastore_controller.persist_via_args( *
            @action.output_related_arguments )
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

        def input_properties
          IO_properties__[].at :input_string, :input_pathname
        end

        def action_class
          Action__
        end
      end

      class Action__ < Action_

        def output_related_arguments  # assumes partitioned
          @output_argument_a
        end

        def input_arguments
          @input_argument_a
        end

        def output_arguments
          @output_argument_a
        end

      private
        def any_bound_call_for_resolve_document_IO
          partition_IO_related_arguments
          bc = any_bc_for_exactly_one_input_argument
          bc || any_bc_for_exactly_one_output_argument
        end

        def partition_IO_related_arguments
          scn = get_actual_argument_scan
          props = self.class.properties
          in_a = [] ; out_a = []
          while bound = scn.gets
            prop = props.fetch bound.name_i
            prop.respond_to? :IO_direction or next  # :+[#br-046]
            case prop.IO_direction
            when :input ; bound.value_x and in_a.push bound
            when :output ; bound.value_x and out_a.push bound
            end
          end
          @input_argument_a = in_a
          @output_argument_a = out_a ; nil
        end

        def any_bc_for_exactly_one_input_argument
          any_bc_for_IO :input, @input_argument_a
        end

        def any_bc_for_exactly_one_output_argument
          any_bc_for_IO :output, @output_argument_a
        end

        def any_bc_for_IO direction_i, arg_a
          1 != arg_a.length and bc_when_non_1_doc_IO( direction_i, arg_a )
        end

        def bc_when_non_1_doc_IO direction_i, arg_a
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
              _prop_a = _PROPS.reduce_by do |arg|
                prop = _PROPS.fetch arg.name_i
                prop.respond_to? :IO_direction and direction_i == prop.IO_direction  # :+[#br-046]
              end
              _s_a = _prop_a.map do |x|
                par x
              end
              _xtra = " (provide #{ or_ _s_a })"
            else
              _s_a = arg_a.map do |arg|
                par _PROPS.fetch arg.name_i
              end
              _xtra = " (#{ _s_a * ', ' })"
            end
            y << "need exactly 1 #{ o.direction_i }-related argument, #{
             }had #{ o.arg_a.length }#{ _xtra }"
          end
        end
      end

      IO_properties__ = -> do

        p = -> do

          module IO_Proprietor___

            TanMan_::Entity_[ self, -> do

              o :meta_property, :IO_direction, :enum, [ :input, :output ]

              o :IO_direction, :input, :property, :input_string,
                :IO_direction, :input, :property, :input_pathname,
                :IO_direction, :output, :property, :output_string,
                :IO_direction, :output, :property, :output_pathname

            end ]
          end

          p = -> { IO_Proprietor___.properties }

          IO_Proprietor___.properties
        end

        -> { p[] }
      end.call
    end
  end
end
