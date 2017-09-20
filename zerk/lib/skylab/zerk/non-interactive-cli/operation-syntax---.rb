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

      # #during #milestone-9 all these sanity checks..

      def initialize etc_p, fo_frame

        @__custom_OP_proc = etc_p
        @_determine_APC = true  # not all syntaxes will have these
        @_fo_frame = fo_frame
        @_init_OI = true
        @_init_OPC = true  # because of help system, all syntaxes have these
      end

      def option_parser__  # only for help
        @_init_OPC && _init_OPC
        @_OPC.the_option_parser__
      end

      def parse_options argv, client, & pp  # experimenal for [dt]
        @_init_OPC && _init_OPC
        @_OPC.parse__ argv, client, & pp
      end

      def _init_OPC
        @_init_OPC = false
        @_init_OI && _init_OI
        _p = remove_instance_variable :@__custom_OP_proc
        @_OPC = Here_::OptionParserController.new _p, @_operation_index
        NIL_
      end

      # --

      def remove_positional_argument__ sym

        @_determine_APC && _determine_APC
        a = @_APC.attributes_array__
        d = a.index do |par|
          par.name_symbol == sym
        end
        x = a.fetch d
        a[ d, 1 ] = EMPTY_A_
        if a.length.zero?
          @_has_APC = false
          remove_instance_variable :@_APC
          # eek! but it's what we want
        end
        x
      end

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
        # :#spot1.2

        @_determine_APC = false

        if @_init_OI

          if @_fo_frame.has_stated_parameters__
            _init_OI
            yes = @_operation_index.arguments_
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
      # & volatile one - make sure they share the behavior effected here.

      def initialize qkn, oi, client, tmp_sym, & pp
        @__client = client
        @__oes_pp = pp
        @_oi = oi
        @_qkn = qkn
        @TEMP_SYM = tmp_sym
      end

      def execute
        @_k = @_qkn.association.name_symbol
        send RECV___.fetch @_oi.niCLI_reception_set_symbol_for_ @_k
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

        @_si = @_oi.scope_index_
        @_asc = @_si.node_reference_via_node_name_symbol_( @_k ).association

        ok = __check_availability
        ok &&= __init_appropriated_component_value
        ok && __write_value
      end

      def __init_appropriated_component_value

        @_frame = @_si.modality_frame_via_node_name_symbol_ @_k

        _oes_pp = -> _ do
          # the model doesn't know the component's asssociation but we do:
          @__oes_pp[ @_asc ]
        end

        _scn = Home_.lib_.fields::Argument_scanner_via_value[ @_qkn.value ]

        qk = Arc_::Magnetics::QualifiedComponent_via_Value_and_Association.call(
          _scn,
          @_asc,
          @_frame.ACS,
          & _oes_pp
        )
        if qk
          @_component_qk = qk ; ACHIEVED_
        else
          qk
        end
      end

      def __write_value

        send SINGPLUR___.fetch @_asc.singplur_category
      end

      SINGPLUR___ = {
        :singular_of => :__write_value_when_singof,
        :plural_of => :__write_value_when_plurof,
        nil => :__write_value_normally,
      }

      def __write_value_normally

        sym = @_asc.argument_arity
        if sym
          :zero == sym or self._SANITY
        end

        _write_value
      end

      # contrary to [#ac-026] and as explained in [#036] we want these
      # values to aggregate. (when writing to the single, the former would
      # clobber the slot with a 1-length array each time.) see the latter
      # about handling "inborn defaults", which we do here too. (so we
      # corral the singles to the plural "slot" ourselves here.)

      def __write_value_when_singof

        :_TEMP_VIA_OPTS_ == @TEMP_SYM or self._SANITY

        # remove all ivars that now have ambiguous allegiance

        sing_asc = remove_instance_variable :@_asc
        remove_instance_variable :@_k
        sing_qkn = remove_instance_variable :@_qkn

        # --

        _value_x = sing_qkn.value
        _plur_k = sing_asc.singplur_referent_symbol
        _plur_asc = @_si.node_reference_via_node_name_symbol_( _plur_k ).association

        # --

        __write_value_aggregatingly _value_x, _plur_asc
      end

      def __write_value_when_plurof

        # for now there less work to do than with the above if these
        # assumptions hold: assume appropriated thru argument. each such
        # value is already assembled into an array by the parsing performer.
        # each such array should always clobber any that is already there.

        :_TEMP_VIA_ARGV_ == @TEMP_SYM or self._SANITY

        remove_instance_variable :@_asc  # plur asc
        plur_k = remove_instance_variable :@_k

        # pristinity doesn't enter into our concerns (because we always
        # clobber) but let's flip the bit for sanity and consistency

        pristinity_h = @_si.pristinity_
        _yes = pristinity_h.fetch plur_k  # sanity
        _yes or self._SANITY
        pristinity_h[ plur_k ] = false

        # --

        _write_value
      end

      def __write_value_aggregatingly x, plur_asc

        plur_k = plur_asc.name_symbol

        pristinity_h = @_si.pristinity_
        is_pristine = pristinity_h.fetch plur_k  # sanity

        kn = @_frame.reader_writer_.read_value plur_asc

        if kn.is_known_known
          existing_a = kn.value
        end

        if existing_a

          if is_pristine

            # then assume this is in an "inborn default" state - clobber
            existing_a.clear
            pristinity_h[ plur_k ] = false
            existing_a.push x
          else
            # (hi.) then assume we already did the above or the below
            existing_a.push x
          end
        else
          # then probably no inborn default and this is the first invocation
          # use the already existing handling of these .. or not

          pristinity_h[ plur_k ] = false
          _write_value
        end

        ACHIEVED_
      end

      def _write_value
        @_frame.reader_writer_.write_value @_component_qk  # guaranteed
        ACHIEVED_
      end

      def __check_availability

        p = @_asc.unavailability_proc
        if p
          unava_p = p[ asc ]
        end
        if unava_p
          self._WAHOO_this_will_be_fun_for_open  # #open [#022.A]
        else
          ACHIEVED_
        end
      end
    end
  end
end
