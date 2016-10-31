module Skylab::TMX

  class CLI

    class Magnetics_::BoundCall_via_TestDirectoryOrientedOperation < Common_::Actor::Dyadic

      # [#006]

      def initialize bc, cli
        @argument_scanner = cli.argument_scanner
        @CLI = cli
        @_remote_operation = bc.receiver
        @_result_in_the_same_bound_call_we_stared_with = bc
        @_test_directory_collection = @_remote_operation.test_directory_collection
        @__test_directory_entry_name_by = cli.release_test_directory_entry_name_by__
      end

      def execute
        if __parse_ALL_ARGUMENTS_using_the_compounded_primaries
          if __directories_were_named_explicitly
            if __map_related_primaries_were_used
              __when_both_map_options_are_used_AND_directories_are_named_explicitly
            else
              _use_the_remote_operation_as_is
            end
          else
            __use_map_as_is
          end
        end
      end

      # -- consequences

      def __when_both_map_options_are_used_AND_directories_are_named_explicitly

        # don't get the list of json files as normal. derive their presumable
        # location by back-inferring them from the argument test directories.

        map_op = @_map_operation
        test_dir_collection = @_test_directory_collection

        dir_st = test_dir_collection.to_test_directory_stream

        test_dir_collection.clear

        json_file_stream_once = -> do
          json_file_stream_once = nil

          _metadata_filename = @CLI.release_metadata_filename__

          dir_st.map_by do |test_dir|

            _eek = ::File.dirname test_dir

            ::File.join _eek, _metadata_filename
          end
        end

        map_op.json_file_stream_by = -> { json_file_stream_once[] }

        st = map_op.execute
        if st
          _use_this_mapped_stream_for_the_remote_operation st
        end
      end

      def __use_map_as_is  # ASSUME directories were not named explicitly

        # whether or not map-specific primaries were used, we do the same thing:

        map_op = @_map_operation

        map_op.json_file_stream_by = @CLI.release_json_file_stream_by_

        st = map_op.execute
        if st
          _use_this_mapped_stream_for_the_remote_operation st
        end
      end

      def _use_this_mapped_stream_for_the_remote_operation node_st

        test_directory_stream_once = -> do
          test_directory_stream_once = nil

          dir = remove_instance_variable( :@__test_directory_entry_name_by ).call

          node_st.map_by do |node|
            ::File.join node.get_filesystem_directory, dir
          end
        end

        @_test_directory_collection.test_directory_stream_once_by do
          test_directory_stream_once[]
        end

        _use_the_remote_operation_as_is
      end

      def _use_the_remote_operation_as_is
        @_result_in_the_same_bound_call_we_stared_with
      end

      # -- booleans

      def __map_related_primaries_were_used
        @_map_operation.stream_modifiers_were_used
      end

      def __directories_were_named_explicitly
        @_test_directory_collection.has_explicitly_named_directories
      end

      def __parse_ALL_ARGUMENTS_using_the_compounded_primaries

        __init_map_operation_and_compounded_primaries
        _ok = @__compounded_primaries.parse_against @argument_scanner
        _ok  # #todo
      end

      # -- initing the compunded primaries parser

      def __init_map_operation_and_compounded_primaries

        map_op = Home_::Operations_::Map.begin( & @CLI.listener )

        map_op.argument_scanner = @argument_scanner

        map_op.attributes_module_by = -> { Home_::Attributes_ }  # necessary for it to be able to parse '-order' primary

        @__compounded_primaries = Zerk_::ArgumentScanner::CompoundedPrimaries.define do |o|

          o.add_operation map_op do |op|
            op.not(
              :attributes_module_by,  # only ever the one set below
              :json_file_stream,  # only ever the one set below
              :json_file_stream_by,  # dito
              :result_in_tree,  # we don't ever produce the tree here
              :select,  # we don't select multiple fields here
            )
          end

          o.add_operation @_remote_operation
        end

        @_map_operation = map_op
        NIL
      end

    end
  end
end
