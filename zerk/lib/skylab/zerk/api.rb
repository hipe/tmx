module Skylab::Zerk  # intro in [#001] README

  module API

    # "API" is an auxiliary modality for zerk. this node is not used in the
    # delivery of zerk's main modality, that of [#001] "interactive CLI".
    #
    # this attempts to facilite the exposure of a zerk-compatible [ac] ACS
    # as an API, so that its underlying operations can be invoked directly
    # without needing to go thru the UI.
    #
    # having this can be useful to test your operatinos without having the
    # overhead, noise and extra moving parts of the UI. as well it can be
    # useful so that your zerk application is also a callable library.

    class << self

      def call args, acs, & p

        _oes_p_p = Home_.handler_builder_for_ acs, & p

        bc = Produce_bound_call___[ args, acs, & _oes_p_p ]
        if bc
          bc.receiver.send bc.method_name, * bc.args, & bc.block
        else
          bc
        end
      end
    end  # >>

    class Produce_bound_call___

      # (there is no and will continue to be no fuzzy matching of node names)

      class << self

        def [] args, acs, & oes_p_p

          _st = Callback_::Polymorphic_Stream.via_array args
          new( _st, acs, & oes_p_p ).bound_call
        end

        alias_method :__new_via, :new
        private :new
      end  # >>

      def initialize st, acs, & oes_p_p

        @ACS = acs
        @_argument_stream = st
        @__oes_p = nil
        @_oes_p_p = oes_p_p
      end

      def __bc_via_recurse_into qkn

        remove_instance_variable :@__oes_p

        _ACS = remove_instance_variable :@ACS
        _st = remove_instance_variable :@_argument_stream  # unless #pop-back
        _oes_p_p = remove_instance_variable :@_oes_p_p  # #when-context

        _cmp = if qkn.is_effectively_known
          qkn.value_x  # [sa]
        else
          ACS_::For_Interface::Build_and_attach[ qkn.association, _ACS ].value_x
          # #needs-upwards
        end

        _ = self.class.__new_via _st, _cmp, & _oes_p_p
        _.bound_call
      end

      def bound_call
        if @_argument_stream.no_unparsed_exists
          __when_no_arguments_for_ACS
        else
          __bc_via_the_parse_loop
        end
      end

      def __bc_via_the_parse_loop

        begin

          node = ___custom_parse_node
          if ! node
            bc = __when_no_match_under_ACS
            break
          end

          if node.association.model_classifications.looks_compound
            bc = __bc_via_recurse_into node
            break
            # (hypothetically we could allow returning to this frame. :#pop-back)
          end

          if @_argument_stream.no_unparsed_exists

            bc = __custom_parse_when_no_arguments node
            break
          end

          ok = __custom_parse_when_arguments node
          if ! ok
            bc = ok
            break
          end

          if @_argument_stream.no_unparsed_exists
            bc = Callback_::Bound_Call.via_value ACHIEVED_  # not sure..
            break
          end

          redo
        end while nil
        bc
      end

      # -- ("custom" means the result shape is ad-hoc and very mixed..)

      def ___custom_parse_node  # assume at least one token in upstream

        token_symbol = @_argument_stream.current_token

        st = API_node_stream_for__[ @ACS ]

        begin
          node = st.gets
          node or break

          if token_symbol == node.name.as_variegated_symbol
            break
          end

          redo
        end while nil

        if node
          @_argument_stream.advance_one
        end

        node
      end

      def __custom_parse_when_no_arguments terminal_node

        # #EXPERIMENTAL: the good news is we will stop the parse no matter
        # what. now, think of a "buttonlike" as an operation defined by an
        # association (and model or proc). a buttonlike from this state is
        # OK: the parse must now result with the appropriate bound call of
        # the buttonlike's chosing. conversely, a field-like must stop the
        # parse with failure talkin bout missing required argument. can we
        # accomplish that through a purely autonomous means, inferring the
        # argument arity from only the behavior pattern (where each field-
        # like does not have to whine for itself)?

        o = _begin_build_value terminal_node
        d = o.emission_handler_builder.count
        wv = o.execute
        if wv  # something succeeded.

          if wv.is_known_known  # by this decree it MUST be from a buttonlike..
            wv.value_x          # .. AND FURTHERMORE be a bound call!
          else

            # otherwise it is the known unknown. we don't remember what
            # #[#ac-002]Detail-one is for but we know that from this state:

            _when_missing_expected_argument_for terminal_node
          end

        elsif d == emission_handler_builder.count

          # othewise (and it failed to interpret), since it didn't emit
          # anything we hereby decree that is assumed to be something like
          # a field and wanted arguments so we:

          _when_missing_expected_argument_for node
        else

          # otherwise (and it failed to interpret and something was emitted),
          # we assume that whatever was emitted was sufficiently meaningful.
          wv
        end
      end

      def __custom_parse_when_arguments terminal_node

        # #EXPERIMENTAL (again) - if the node is fieldlike that is OK. but if
        # the button is buttonlike then we have unexpected arguments. can we
        # determine which is which using the response pattern alone?

        o = _begin_build_value terminal_node
        d = o.emission_handler_builder.count
        wv = o.execute

        if wv
          ___accept wv, terminal_node

        elsif d == o.emission_handler_builder.count

          # the node failed to interpret the input and nothing was emitted.
          # assume it is button-like and wanted no arguments.

          _when_extra_arguments_for terminal_node
        else
          wv  # assume that whatever was emitted was what we think it is
        end
      end

      def ___accept wv, node

        p = ACS_::Interpretation::Accept_component_change[
          wv.value_x,
          node.association,
          @ACS,
        ]

        _handler.call :info, :set_leaf_component do
          p[]
        end

        KEEP_PARSING_
      end

      def _begin_build_value node

        @__hbwc ||= ___build_handler_builder_with_counter

        ACS_::Interpretation_::Build_value.begin(
          @_argument_stream,
          node.association,
          @ACS,
          & @__hbwc )
      end

      def ___build_handler_builder_with_counter

        # experiment - can we distinguish buttons with unexpected arguments
        # from fields with invalid arguments using only this? (also try to
        # distinguish a field missing an argument vs. a button with this too!)

        oes_p_p_o = Emission_Counter___.new do |_|

          oes_p = @_oes_p_p[ nil ]

          -> * i_a, & ev_p do
            oes_p_p_o.count += 1
            oes_p[ * i_a, & ev_p ]
            UNRELIABLE_
          end
        end
        oes_p_p_o.count = 0
        oes_p_p_o
      end

      class Emission_Counter___ < ::Proc
        attr_accessor :count
      end

      # -- when

      def __when_no_arguments_for_ACS

        _get_handler.call :error, :expression, :empty_arguments do | y |
          y << "#{ highlight 'empty' } argument list."
        end
        UNABLE_
      end

      def __when_no_match_under_ACS

        _get_handler.call :error, :uninterpretable_token do
          __build_uninterpretable_token_event
        end

        UNABLE_  # hypothetially could be a b.c instead..
      end

      def _when_missing_expected_argument_for node

        _get_handler.call :error, :expression, :request_ended_prematurely do | y |

          y << "expecting value for #{ par node.name }"
        end

        UNABLE_  # important
      end

      def _when_extra_arguments_for node

        x = @_argument_stream.current_token

        _get_handler.call :error, :expression, :request_had_unexpected_argument do |y|

          y << "unexpected argument #{ ick x }"
        end

        UNABLE_
      end

      def __build_uninterpretable_token_event

        Require_field_library_[]

        _st = API_node_stream_for__[ @ACS ]

        _st_ = _st.map_by do | qkn |
          qkn.name.as_variegated_symbol
        end

        _st__ = _st_.flush_to_polymorphic_stream

        o = Fields_::MetaMetaFields::Enum::Build_extra_value_event.new

        o.invalid_value = @_argument_stream.current_token

        o.valid_collection = _st__

        o.property_name = Callback_::Name.via_human 'argument'

        o.event_name_symbol = :uninterpretable_token

        o.execute
      end

      def _handler
        @__oes_p ||= @_oes_p_p[ @ACS ]
      end

      def _get_handler
        if @__oes_p
          @__oes_p
        else
          @_oes_p_p[ @ACS ]
        end
      end
    end

    API_node_stream_for__ = Interface_stream_for_.curry[ :API ]

  end
end
