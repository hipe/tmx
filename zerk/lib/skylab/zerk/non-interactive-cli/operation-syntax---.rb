module Skylab::Zerk

  class NonInteractiveCLI

    class Operation_Syntax___

      # those resources that option parsing and argument parsing share are
      # wrapped here. a subject instance is created IFF one or more of:
      #
      # • the any option parser needs to be expressed under help
      # • there is a non-empty ARGV array that needs to be parsed for options
      # • the any formal arguments need to be expressed under help
      # • there is a non-empty ARGV array that needs to be parsed for arguments
      #
      # these bullets correspond roughly to the sections in this document.

      def initialize fo_frame

        @_determine_APC = true  # not all syntaxes will have these
        @_fo_frame = fo_frame
        @_init_OI = true
        @_init_OPC = true  # because of help system, all syntaxes have these
      end

      def option_parser__  # only for help
        @_init_OPC && _init_OPC
        @_OPC.the_option_parser__
      end

      def parse_opts__ argv, client, & pp
        @_init_OPC && _init_OPC
        @_OPC.parse__ argv, client, & pp
      end

      def _init_OPC
        @_init_OPC = false
        @_init_OI && _init_OI
        @_OPC = Here_::Option_Parser_Controller___.new @_operation_index
        NIL_
      end

      # --

      def any_argument_attributes_array__  # only for help (the usage line)

        @_determine_APC && _determine_APC

        if @_has_APC
          @_APC.attributes_array__
        end
      end

      def custom_section__ & p  # only for help

        @_determine_APC && _determine_APC

        if @_has_APC
          @_APC.the_custom_section__( & p )
        end
      end

      def has_formal_arguments__

        @_determine_APC && _determine_APC
        @_has_APC
      end

      def parse_arguments__ argv, client, & pp  # assume is known to have formal args

        @_APC.parse__ argv, client, & pp
      end

      def _determine_APC

        # #optimization: make these assumptions: if ARGV had been non-empty,
        # we would have parsed for options by now (for help at least). if we
        # parsed for options we built the o.p, and if we build the o.p then
        # we built the o.i. SO if we don't have the o.i then we know that
        # ARGV is empty! when ARGV is empty and there are no stated formal
        # parameters, then we can avoid doing #heavy-lift of o.i entirely..
        # :#spot-2

        @_determine_APC = false

        if @_init_OI

          if @_fo_frame.has_stated_parameters__
            yes = true
            _init_OI
          else
            @_operation_index = :_NO_OPERATION_INDEX_
          end
        else
          # if you have the o.i already, then don't touch the above box
          # because otherwise we would traverse the same stream twice..
          yes = @_operation_index.arguments_
        end

        if yes
          @_APC = Here_::Argument_Parser_Controller_.new @_operation_index
          @_has_APC = true
        else
          @_has_APC = false
        end
        NIL_
      end

      # --

      def _init_OI  # the "heavy lift"
        @_init_OI = false
        @_operation_index = Here_::Operation_Index.new_from_top__ @_fo_frame
        NIL_
      end

      def existent_operation_index__  # assume (assert-esque) it was initted
        @_operation_index
      end
    end

    # ==

    class Receive_ARGV_value_

      # the distinction between option & argument parsing is a superficial
      # & volatilve one - make sure they share the behavior effected here.

      def initialize qkn, oi, client, & pp
        @__client = client
        @__oes_pp = pp
        @_oi = oi
        @_qkn = qkn
      end

      def execute
        send RECV___.fetch @_oi.niCLI_reception_set_symbol_for_ @_qkn.name_symbol
      end

      RECV___ = {
        _bespoke_: :__when_bespoke_value,
        _appropriated_: :__when_appropriated_value,
        _scope_node_not_appropriated_: :__when_scope_not_appropriated_value,
      }

      def __when_bespoke_value

        @__client.store_floaty_value_of_bespoke__ @_qkn  # guaranteed.
        # per [#016] it is not appropriate to allow validation here.
        ACHIEVED_
      end

      # -- writing scope values - they must be written to the ACS
      #    tree (in part so operation dependencies can see such values.)

      def __when_scope_not_appropriated_value
        _when_scope_value  # (hi.)
      end

      def __when_appropriated_value
        _when_scope_value  # (hi.)
      end

      def _when_scope_value

        @_name_symbol = @_qkn.name_symbol

        @_si = @_oi.scope_index_
        @_asc = @_si.node_ticket_via_node_name_symbol_( @_name_symbol ).association

        ok = __check_availability
        ok &&= __init_appropriated_component_value
        ok && __write_value
      end

      def __init_appropriated_component_value

        @_frame = @_si.modality_frame_via_node_name_symbol_ @_name_symbol

        _oes_pp = -> _ do
          # the model doesn't know the component's asssociation but we do:
          @__oes_pp[ @_asc ]
        end

        _st = Home_.lib_.fields::Argument_stream_via_value[ @_qkn.value_x ]

        qk = ACS_::Interpretation::Build_value.call(
          _st,
          @_asc,
          @_frame.ACS,
          & _oes_pp
        )
        if qk
          @__component_qk = qk ; ACHIEVED_
        else
          qk
        end
      end

      def __write_value
        @_frame.reader_writer_.write_value @__component_qk  # guaranteed
        ACHIEVED_
      end

      def __check_availability

        p = @_asc.unavailability_proc
        if p
          unava_p = p[ asc ]
        end
        if unava_p
          self._WAHOO_this_will_be_fun_for_open  # #open [#022]
        else
          ACHIEVED_
        end
      end
    end
  end
end
