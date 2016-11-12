module Skylab::TMX

  class CLI

    class Magnetics_::BoundCall_via_TestDirectoryOrientedOperation  # 1x

      # [#006]

      def initialize bc, as, cli
        @argument_scanner = as
        @CLI = cli
        @_remote_operation = bc.receiver
        @_result_in_the_same_bound_call_we_stared_with = bc
        @selection_stack = cli.selection_stack
        @_test_directory_collection = @_remote_operation.test_directory_collection
        @__test_directory_entry_name_by = cli.release_test_directory_entry_name_by__
      end

      def execute

        Add_slice_primary_[ SECOND_TO_LAST_POSITION_, @argument_scanner, @CLI ]

        __add_verbose_primary_maybe

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

      # -- this

      def __add_verbose_primary_maybe
        _k = @selection_stack.last.name_symbol
        p = VERBOSITIES___.fetch _k
        if p
          vh = VerbosityHandler___.new @CLI
          @argument_scanner.add_primary_at_position(
            SECOND_TO_LAST_POSITION_, :verbose, vh.on_primary, vh.on_help )
          p[ vh ]
        end
        NIL
      end

      # -- initing the compunded primaries parser

      def __init_map_operation_and_compounded_primaries

        map_op = Home_::Operations_::Map.begin( & @CLI.listener )

        as = @argument_scanner

        map_op.argument_scanner = as

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

      # ==

      show_the_find_commands = [
        -> y do
          y << "show the find commands used"
        end,
        -> cli do
          cli.receive_notification_that_you_should_express_find_commands
        end,
      ]

      VERBOSITIES___ = {

        # (operations are high-level to low-level.)
        # (verbosity increments are sequential (1, 2, etc))

        require_only: -> v do

          cli = v.CLI
          serr = cli.serr
          stabby = '  >>>> '

          # - (at zero)

            cli.on_this_do_this :test_file_path do
              serr.write DOT_
              NIL
            end

            cli.on_this_do_this :end_of_list do
              serr.puts
              cli.rewrite_ARGV '--format', 'progress'  # dots
              NIL
            end

          # -

          v.add_one(

            -> y do
              y << "emit every file just before it is loaded"
            end,

            -> _ do

              cli.on_this_do_this :test_file_path do |ee|
                serr.write stabby
                serr.puts ee.emission_proc.call
                NIL
              end

              cli.on_this_do_this :end_of_list do
                cli.rewrite_ARGV '--format', 'documentation'
                NOTHING_  # but absorb the emission so it doesn't propagate
              end

              ACHIEVED_
            end,
          )

          v.add_one( * show_the_find_commands )
        end,

        counts: -> v do

          v.add_one(
            -> y do
              y << "add table column for \"lipstick\" visualization"
            end,
            -> cli do
              cli.receive_notification_that_you_should_add_lipstick_column
            end,
          )

          v.add_one( * show_the_find_commands )
        end,

        list_files: -> v do

          v.add_one( * show_the_find_commands )
        end,
      }

      # ==

      class VerbosityHandler___

        def initialize cli

          me = self

          @on_help = -> y do
            # (ignoring this context, which is expag)
            me.__describe_into y
          end

          @CLI = cli
          @current_verbosity_COUNT = 0
          @_desc_a = []
          @_handle_a = []
          @on_primary = method :__at_verbose
        end

        # -- define

        def add_one desc_p, handler_p
          @_desc_a.push desc_p
          @_handle_a.push handler_p ; nil
        end

        # -- use (mutate)

        def __at_verbose
          max_count = @_handle_a.length
          if max_count == @current_verbosity_COUNT
            __when_hit_max max_count
          else
            @CLI.selection_stack.last.argument_scanner.advance_one
            d = @current_verbosity_COUNT
            @current_verbosity_COUNT = d + 1
            @_handle_a.fetch( d )[ @CLI ]
          end
        end

        def __when_hit_max d

          @CLI.listener.call :error, :expression, :operator_parse_error do |y|
            y << "ineffectual #{ prim :verbose } primary (max: #{ d })"
          end
          UNABLE_
        end

        # -- read

        def __describe_into y
          case 1 <=> @_desc_a.length
          when 1
            __describe_into_when_none y
          when 0
            __describe_into_when_one y
          when -1
            __describe_into_when_more_than_one y
          end
          y
        end

        def __describe_into_when_none y
          y << "adds verbosity to the operation (for some operations)"
        end

        def __describe_into_when_more_than_one y
          count = 0
          p = nil
          my_y = ::Enumerator::Yielder.new do |line|
            p[ line ]
          end
          subsequent_line = -> line do
            y << "     #{ line }"
          end
          first_line = -> line do
            p = subsequent_line
            y << "#{ count }x - #{ line }"
          end
          @_desc_a.each do |user_p|
            count += 1
            p = first_line
            user_p[ my_y ]
          end
        end

        def __describe_into_when_one y
          @_desc_a.first[ y ]
        end

        attr_reader(
          :CLI,
          :on_help,
          :on_primary,
        )
      end

      SECOND_TO_LAST_POSITION_ = -2  # (a popular location for
      # for items - we usually want to leave -help at the end.)
    end
  end
end
