module Skylab::TanMan

  module Models_::Graph

    class Actions::Sync

      # if memory serves, this was intented to help the subject application
      # "import" (and maybe "export") graphs to other applications, like [sn]
      # but in its state it's really just the beginning of a proof of concept
      #
      # see [#026] IO resolution through parameter modeling, near syncing.

      def definition

        false and [
          :inflect, :verb, 'sync', :noun, 'graph',
        ]

        _hi = Home_::DocumentMagnetics_::CommonAssociations.all_

        [
          :flag, :property, :dry_run,

          :properties, _hi,

          :use_this_one_custom_attribute_grammar,

          :property, :hereput_string,
          :throughput_direction, :hereput,

          :property, :hereput_path,
          :throughput_direction, :hereput,
        ]
      end

      def initialize
        extend Home_::Model_::CommonActionMethods
        init_action_ yield
        @_associations_ = {}  # #[#031]
      end

      def execute
        ok = true
        ok &&= __resolve_at_most_one_parameter_per_direction
        ok &&= __do_the_rule_table_thing
        ok &&= __sync_appropriately
        ok || NIL_AS_FAILURE_
      end

      # -- D

      def __sync_appropriately
        send remove_instance_variable :@__will_write_like_this
      end

      def _sync

        This_::Sync_via_Parameters___.call_by do |o|

          # (we can strip the below values of their "association" structures
          #  because when syncing, the associations (input, hereput, output)
          #  that correspond to the BSR's are both known and uninteresting.)

          o.in_reference = ( @_input && @_input.value )
          o.here_reference = ( @_hereput && @_hereput.value )
          o.out_reference = ( @_output && @_output.value )

          o.is_dry_run = remove_instance_variable :@dry_run

          o.microservice_invocation = @_microservice_invocation_
          o.listener = _listener_
        end
      end

      # -- C

      def __do_the_rule_table_thing

        # the rule table at #spot1.2 can probably be implemented more
        # tightly than what we do here (a full, mechanistic unwinding of the
        # three booleans: TTT, TTF, TFT, TFF, ..). for example maybe the
        # absolute distillation of the policy is simply "at least two";
        # however we leave it unwound fully like this so we can inject
        # special behavior per-case without having to disrupt the overall
        # structure ("mesh") of the logic.
        #
        # the performer asserted that for each direction, it resolved no
        # more than one trueish qualified argument for that direction.
        #
        # but if zero values were resolved for the direction, that appears
        # as a "hole" in the below array. the remainder of this work, then,
        # is (partly) about deciding whether any such holes are OK.

        @_input, @_hereput, @_output = remove_instance_variable :@__QKs
        if @_input
          if @_hereput
            if @_output
              _will :_sync  # case 1
            else
              _will :_sync  # case 2
            end
          elsif @_output
            _will :_sync  # case 3
          else
            _fail_because_missing :input  # case 4
          end
        elsif @_hereput
          if @_output
            _will :_sync  # case 5
          else
            _fail_because_missing :input, :output  # case 6 (same as 8)
          end
        elsif @_output
          _fail_because_missing :input  # case 7
        else
          _fail_because_missing :input, :output  # case 8 (same 6)
        end
      end

      def _fail_because_missing * sym_a

        _q_a = remove_instance_variable :@qualifieds_via_direction_offset

        _this_performer::Emit_via_NonOneScenario.call_by do |o|
          o.qualifieds_via_direction_offset = _q_a
          o.direction_symbols = sym_a
          o.listener = _listener_
        end
        UNABLE_
      end

      def _will m
        @__will_write_like_this = m
        ACHIEVED_
      end

      # -- B

      def __resolve_at_most_one_parameter_per_direction

        _bx = to_box_

        sct = _this_performer.call_by do |o|
          o.will_solve_for :input, :hereput, :output
          o.will_NOT_enforce_minimum
          o.qualified_knownness_box = _bx
          o.listener = _listener_
        end

        if sct
          @__QKs = sct.byte_stream_reference_qualified_knownness_array
          @qualifieds_via_direction_offset = sct.qualifieds_via_direction_offset
          ACHIEVED_
        end
      end

      def _this_performer
        Home_::DocumentMagnetics_::ByteStreamReferences_via_Request
      end

      # ==

      module DID_NO_WORK_ ; class << self
        def _DO_WRITE_COLLECTION_
          FALSE
        end
      end ; end

      module DID_WORK_ ; class << self
        def _DO_WRITE_COLLECTION_
          TRUE
        end
      end ; end


      Actions = nil
      This_ = self

      # ==
      # ==
    end
  end
end
