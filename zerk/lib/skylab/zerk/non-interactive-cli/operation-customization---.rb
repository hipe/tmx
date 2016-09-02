module Skylab::Zerk

  class NonInteractiveCLI

    class OperationCustomization___

      # this is the DSL-like controller that gets passed into the jawn

      def initialize fr
        @_frame = fr
      end

      def custom_option_parser_by & p
        @_frame.operation_customization_says_use_this_op_proc__ p ; nil
      end

      def map_these_formal_parameters read

        # (currently #public-API but only called from here for now.)

        # `read` is a reader: must respond to `[]`, typically hash or proc.
        #
        # for each existing formal parameter, the reader is passed its name
        # symbol. what happens next will amaze you. with the result:
        #
        #   - if the result is `false`, this means remove the parameter
        #     (not yet implemented, just the idea. should be easy.)
        #
        #   - if the result is `nil`, do nothing (the parameter remains as-is)
        #
        #   - otherwise (and the result is true) yadda

        _begin_mutate_box

        remove_these = nil

        @_box.each_name do |k|
          x = read[ k ]
          x.nil? && next
          if x
            _apply_parameter_mapping x, k
          else
            ( remove_these ||= [] ).push k
          end
        end

        if remove_these
          # note we MUST do this after NOT DURING traversal of the box!
          self._FUN_AND_EASY_all_you_need_to_do_is_cover_it_and_box_remove
        end

        _end_mutate_box
        NIL
      end

      def map k, & p
        _begin_mutate_box
        _apply_parameter_mapping p, k
        _end_mutate_box
      end

      def for k, & p

        _begin_mutate_box

        existing_par = @_box.fetch k
        frame = @_frame

        _instead = existing_par.dup_by do |o|

          o.default_proc = -> do
            p[ existing_par, frame ]
          end

          o.be_provisioned__

        end
        @_box.replace k, _instead
        _end_mutate_box
      end

      def _begin_mutate_box
        @_box = @_frame.operation_customization_says_parameters_being_mutable_box_
        NIL
      end

      def _apply_parameter_mapping p, k

        par_ = p[ @_box.fetch( k ), @_frame ]
        if ! par_
          self._COVER_ME_this_is_not_the_way_to_remove_parameters  # #todo
        end
        @_box.replace k, par_
        NIL
      end

      def _end_mutate_box
        remove_instance_variable :@_box ; nil
      end
    end
  end
end
# #history: broke out from "stack frame"
