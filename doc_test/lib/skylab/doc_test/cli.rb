module Skylab::DocTest

  module CLI

    # for their compelling simplicity line-streams are the dominant idiom
    # (both inbound and out) of the exposed operations of the implementor,
    # our ACS (and so API). the onus is on the CLI, then, (and so bulk of
    # this file) to speak in the expected idiom of supporting STDIN/STDOUT
    # and filesystem paths for its arguments, and adapt these appropriately
    # to and from the implementing operations.
    #
    # as well (and along these same lines), we want it to be possible for CLI
    # to add an operation that isn't there in the implementing API - that of
    # "synchornize" which umm EDIT
    #
    # the majority of this file is towards accomplishing this layer of
    # customization, customization that is both more natural for this UI
    # modality and totally boring. what is more interesting is the
    # frontiering of a customization API that accompanies it.

    class << self

      def new sin, sout, serr, pn_s_a

        o = My_noninteractive_CLI_prototype___[].dup

        o.universal_CLI_resources sin, sout, serr, pn_s_a

        o.filesystem_by { ::File }

        o.produce_reader_for_root_by = -> acs, produce_reader_for do

          reader = produce_reader_for[ acs ]

          reader.BUILD_READ_FORMAL_OPERATION = Custom_build_read_formal_operation___

          reader
        end

        o.finish
      end
    end  # >>

    Custom_build_read_formal_operation___ = -> reader do

      normal = reader.build_read_formal_operation_normally

      -> sym do
        if :synchronize == sym
          Build_custom_synchronize_formal_operation___
        else
          normal[ sym ]
        end
      end
    end

    Build_custom_synchronize_formal_operation___ = -> ss do

      ACS_::Operation::Formal.via_by :synchronize, ss do |y|

        _wat = Synchronize_for_CLI___.new ss

        y.yield(

          :parameter, :reverse, :is_flag,

          :parameter, :original_test_path, :optional,
          :description, -> y_ do
            y_ << '(without this, dummy placeholder content is expresed.)'
          end,

          :via_ACS_by, -> do
            _wat
          end,
        )
      end
    end

    class Synchronize_for_CLI___

      def initialize ss

        # (for now we've got to nil out "manually" those components of
        # ours that are optional according to the expression block somewhere
        # above.)

        @original_test_path = nil
        @reverse = nil

        root_frame = ss.first

        cli = root_frame.CLI

        @_filesystem = cli.filesystem
        @_root_ACS = root_frame.ACS

        #== EXPERIMENT

        @_oes_p = cli.build_common_emission_handler_where do |o|

          o.selection_stack = ss

          o.subject_association = NOTHING_

        end
      end

      def __asset_path__component_association

        yield :description, -> y do
          y << "a code file with some participating comments."
        end

        -> st do
          Path__[ st ]
        end
      end

      def __original_test_path__component_association

        yield :description, -> y do
          y << 'use the bytes in this file as a startingpoint.'
        end

        -> st do
          Path__[ st ]
        end
      end

      def __reverse__component_association

        yield :description, -> y do
          y << "(coming soon.)"
        end

        -> st do
          ::Kernel._K
        end
      end

      def execute

        _ok = __resolve_upstream_line_stream
        _ok && __result_via_upstream_line_stream
      end

      def __result_via_upstream_line_stream

        _asset_line_stream = remove_instance_variable :@__asset_line_stream
        original_test_line_stream = remove_instance_variable :@__original_test_line_stream

        op = Home_::Operations_::Synchronize.new( & @_oes_p )
        op.asset_line_stream = _asset_line_stream
        op.original_test_line_stream = original_test_line_stream
        op.output_adapter = :quickie

        _x = op.execute
        if _x.respond_to? :gets
          $stderr.puts "(looks ok in CLI client)"
        else
          $stderr.puts "(something funny in CLI client)"
        end
        _x
      end

      def __resolve_upstream_line_stream

        _FS = @_filesystem
        path = @original_test_path

        begin

          if path
            original_test_line_stream = _FS.open path
          end

          asset_line_stream = _FS.open @asset_path

        rescue ::Errno::ENOENT => e
        end

        if e
          __express_exception e
          UNABLE_
        else
          remove_instance_variable :@asset_path
          remove_instance_variable :@original_test_path
          @__asset_line_stream = asset_line_stream
          @__original_test_line_stream = original_test_line_stream
          ACHIEVED_
        end
      end

      def __express_exception e
        @_oes_p.call :error, :expression do |y|
          y << e.message
        end
      end
    end

    Path__ = -> st do
      x = st.gets_one
      if x
        Common_::Known_Known[ x ]
      else
        x
      end
    end

    My_noninteractive_CLI_prototype___ = Lazy_.call do

      Require_zerk_[]

      o = Zerk_::NonInteractiveCLI.begin

      o.root_ACS_by do
        Root_Autonomous_Component_System_.new
      end

      # o.location_module = CLI

      o
    end
  end
end
# #history: born anew