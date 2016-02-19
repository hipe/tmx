module Skylab::Autonomous_Component_System

  class Parameter

    class Normalize  # much docs at [#028]

      def initialize sel_stack, fo_st

        @_formals_stream = fo_st
        @selection_stack = sel_stack

        @_receive_parameter_value_source = -> m, x do
          remove_instance_variable :@_receive_parameter_value_source
          send m, x
        end

        @_output_operation = -> m do
          remove_instance_variable :@_output_operation
          send m
        end
      end

      # -- asserted to happen only once

      def argument_stream= st
        @_receive_parameter_value_source[ :__recv_arg_stream_once, st ] ; st
      end

      def parameters_value_reader= rdr
        @_receive_parameter_value_source[ :__recv_params_value_rdr_once, rdr ]
        rdr
      end

      def to_flat_platform_arglist
        @_output_operation[ :__flush_to_platform_arguments_once ]
      end

      def write_into o
        @_parameter_value_recipient = o
        @_output_operation[ :__flush_to_write_into_once ]
      end

      # -- only once's

      def __recv_arg_stream_once arg_st
        @_argument_shape = :Argument_Stream
        @__argument_stream = arg_st ; nil
      end

      def __recv_params_value_rdr_once rdr
        @_argument_shape = :Parameters_Reader
        @__parameters_reader = rdr ; nil
      end

      def __flush_to_platform_arguments_once

        _execute :Platform_Arglist
      end

      def __flush_to_write_into_once

        _ent = remove_instance_variable :@_parameter_value_recipient

        _execute _ent, :Write_Into
      end

      def _execute * args, target_sym

        _const = :"#{ target_sym }__via__#{ @_argument_shape }___"

        _x = Here_.const_get _const, false

        _x.new( * args, self ).execute
      end

      # -- for subs

      def flush_formals_stream_to_box_
        bx = Callback_::Box.new
        st = release_formals_stream_
        begin
          fo = st.gets
          fo or break
          bx.add fo.name_symbol, fo
          redo
        end while nil
        bx
      end

      def release_formals_stream_
        remove_instance_variable :@_formals_stream
      end

      def release_parameters_value_reader__
        remove_instance_variable :@__parameters_reader
      end

      def parse_from_argument_stream_into_against_ h, fo_bx  # [#]"head parse"

        st = @__argument_stream

        if 1 == fo_bx.length
          if st.no_unparsed_exists
            self._COVER_ME_probably_fine_to_just_finish
          else
            _k = fo_bx.at_position( 0 ).name_symbol
            h[ _k ] = st.gets_one
          end
        else
          fo_h = fo_bx.h_
          begin
            if st.no_unparsed_exists
              break
            end
            k = st.current_token
            fo = fo_h[ k ]
            fo or break
            st.advance_one
            h[ k ] = st.gets_one
            redo
          end while nil
        end

        h
      end

      def normalize_argument_hash_against_stream_ rdr_p, fo_st, & accept

        Require_field_library_[]

        # in formal order but for only those entries that exist in the hash
        # (where entries with false & nil values count as existing), the
        # block will receive each value-formal pair

        miss_a = nil

        begin
          par = fo_st.gets
          par or break
          k = par.name_symbol

          had = true
          x = rdr_p.call k do
            had = false ; nil
          end

          did = false
          if x.nil? && Field_::Has_default[ par ]
            x = par.default_proc.call
            did = true
          end

          if x.nil? && Field_::Is_required[ par ]
            ( miss_a ||= [] ).push par
            redo
          end

          if had || did  # [#]"why we skip certain acceptances"
            accept[ x, par ]
          end

          redo
        end while nil

        if miss_a

          # [#004]#exe explains why we raise here
          # but this may change soon..
          raise ::ArgumentError, ___say_missing( miss_a )
        else
          ACHIEVED_
        end
      end

      def ___say_missing par_a

        _s_a = @selection_stack[ 1 .. -1 ].map do |qk|
          "`#{ qk.name.as_variegated_symbol }`"
        end

        _for = " for #{ _s_a * SPACE_ }"

        _s_a = par_a.map do |par|
          "`#{ par.name_symbol }`"
        end

        "missing required argument(s) (#{ _s_a * ', '})#{ _for }"
      end
    end
  end
end
