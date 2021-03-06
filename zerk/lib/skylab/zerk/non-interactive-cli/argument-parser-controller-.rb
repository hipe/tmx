module Skylab::Zerk

  class NonInteractiveCLI

    class Argument_Parser_Controller_  # 1x

      def initialize oi  # assume nonzero length arguments

        # (the below is why we have an entry in [#fi-037.5.M])

        @_n11n = Remote_CLI_lib_[]::Arguments::Normalization.
          via_properties oi.arguments_

        @_n11n.be_for_random_access  # always this.. #[#015]:"c2"
        @_operation_index = oi
      end

      def attributes_array__  # only for help (the usage line)
        @_n11n.formals
      end

      def the_custom_section__ & p  # only for help - use [#061.2]

        # IFF there is at least one item, start the section. otherwise
        # don't write the header line (and don't invoke the interpreter).

        pair_st = __to_descriptive_argument_tuple_stream
        pair = pair_st.gets
        if pair
          ___render_argument_section pair, pair_st, & p
        end
      end

      def ___render_argument_section pair, pair_st

        yield :section, :name_symbol, :argument  # i.e "arguments:", "argument:"

        begin
          par, descriptor = pair

          _moniker_proc = -> par_ do
            -> _expag do
              par_.name.as_slug
            end
          end.call par  # make a closure because it's called late

          yield :item, :moniker_proc, _moniker_proc, :descriptor, descriptor

          pair = pair_st.gets

        end while pair
        NIL_
      end

      def __to_descriptive_argument_tuple_stream

        oi = @_operation_index

        par_a = oi.arguments_  # assume nonzero length

        nt_d_a = oi.node_reference_index_via_argument_index__ || EMPTY_A_

        _par_d_st = Common_::Stream.via_times par_a.length

        _par_d_st.map_reduce_by do |par_d|

          # reduce over the stream of parameters reducing down to only those
          # parameters with a description proc. look in 2 places for it:
          # first in the parameter, then second in the component association.

          par = par_a.fetch par_d
          if Field_::Has_description[ par ]
            descriptor = par
          else
            nt_d = nt_d_a[ par_d ]
            if nt_d
              asc = oi.scope_index_.scope_node_( nt_d ).association
              if Field_::Has_description[ asc ]
                descriptor = asc
              end
            end
          end
          if descriptor
            [ par, descriptor ]
          end
        end
      end

      def parse__ argv, client, & pp
        Parse___.new( argv, @_n11n, @_operation_index, client, & pp ).execute
      end

      # ==

      class Parse___

        def initialize ar, no, oi, cl, & pp
          @__argv = ar
          @client = cl
          @__n11n = no
          @__operation_index = oi
          @__listenerp = pp
        end

        def execute

          _ok = ___check_argument_arity
          _ok && __init_result_via_box
          @_result
        end

        def ___check_argument_arity

          o = remove_instance_variable( :@__n11n ).via_argv remove_instance_variable :@__argv
          ev = o.execute
          if ev
            @_result = @client.send H___.fetch( ev.terminal_channel_symbol ), ev
            UNABLE_
          else
            @_box = o.release_random_access_box
            ACHIEVED_
          end
        end

        H___ = {
          extra: :when_via_argument_parser_extra__,
          missing: :when_via_argument_parser_missing__,
        }

        # now we have a box of zero or more actual values, each of which
        # corresponds to a formal parameter. each such formal parameter is
        # either appropriated from the scope set or it is bespoke. those
        # values that are of appropriateds must store in the ACS trees so
        # that operation-dependencies can see them. the others will move
        # out out of this facility in the box they are in now to be used
        # later in the interpretation pipeline..

        def __init_result_via_box

          ok = ACHIEVED_
          st = @_box.to_value_stream
          begin
            qkn = st.gets
            qkn or break

            # whatever this qkn represents, we've got to pass it indiferrently
            # to the client (that is, not as a parameter necessarily.)

            ok = Receive_ARGV_value_.new( qkn, @__operation_index, @client, :_TEMP_VIA_ARGV_, & @__listenerp ).execute
            ok or break  # or not. but yes you really should.

            redo
          end while nil

          if ! ok
            ok = @client.when_via_argument_parser_component_rejected_request__
          end
          @_result = ok
          NIL_
        end
      end

      class Parameter_Value_Source_via_Box  # 1x

        # make available those values that were passed as arguments AS a
        # normal adapter structure consumable by the normal normalizer..

        def initialize value_bx

          # you are a parsed structure; but imagine you yourself are an
          # argument stream as we might have in a [ze] API call..

          @_value_box = value_bx
        end

        def is_known_to_be_empty
          false  # eek not sure
        end

        def to_controller_against head_parsable_formal_bx  # per [#028]:#"Head parse"

          # the ways in which this is terrible are elucidated at [#003.B]

          _EEK_KN = nil

          fo_st = head_parsable_formal_bx.to_value_stream

          _formal_parameter_stream = Common_.stream do
            begin

              fo = fo_st.gets
              fo || break

              qk = @_value_box[ fo.name_symbol ]
              if qk
                asc = qk.association
                _EEK_KN = qk
                break
              end

              if ! fo.is_provisioned
                redo
              end

              # provisioning happens at the modality level. so we have to do
              # it now because the default proc won't be there on the back..
              # this is :#spot1.6.

              asc = fo
              _anything = fo.default_proc.call
              _EEK_KN = Common_::KnownKnown[ _anything ]
              break

            end while above
            asc
          end

          _parameter_value_stream = Gets_one_proxy___.new do
            _EEK_KN.value
          end

          PVS_via_Box_Controller___[ _formal_parameter_stream, _parameter_value_stream ]
        end
      end

      Known_nothing___ = Lazy_.call do
        Common_::KnownKnown[ NOTHING_ ]
      end

      # ==

      class Gets_one_proxy___ < ::Proc
        alias_method :gets_one, :call
      end

      # ==

      PVS_via_Box_Controller___ = ::Struct.new(
        :consuming_formal_parameter_stream,
        :current_argument_scanner,
      )
    end
  end
end
# #history: created.
