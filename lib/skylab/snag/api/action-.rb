module Skylab::Snag

  module API

    class Action_  # this is a replacement action class for sibling node `Action`

      include API::Action::Business_Methods___

      Entity_ = Snag_.lib_.entity.call do

        o :ad_hoc_processor, :make_delegate_properties, -> x do
          Make_Delegate_Properties__.new( x ).go
        end

        o :ad_hoc_processor, :make_sender_methods, -> x do
          Make_Sender_Methods__.new( x ).go
        end

        entity_property_class_for_write

        class self::Entity_Property

        private

          def required=
            @parameter_arity = :one
            KEEP_PARSING_
          end
        end
      end

      def initialize _API_client
        @API_client = _API_client
        @delegate = nil
      end

      def invoke_via_argument_stream st
        process_iambic_stream_fully st
        if_any_missing_required_raise_argument_error
        execute
      end

    private

      def if_any_missing_required_raise_argument_error
        scn  = self.class.properties.to_value_stream ; a = nil
        while (( prop = scn.gets ))
          prop.is_required or next
          ivar = prop.as_ivar
          instance_variable_defined? ivar and !
            instance_variable_get( ivar ).nil? and next
          ( a ||= [] ).push prop
        end
        a and raise ::ArgumentError, say_missing_required( a )
      end

      def say_missing_required a
        "missing required API propert{y|ies} (#{ a.map( & :name_symbol ) * ', ' })"
      end

      def receive_info_string ev_s
        _ev = sign_string ev_s
        send_info_event _ev
        NEUTRAL_
      end

      def receive_info_event ev
        _ev_ = sign_event ev
        send_info_event _ev_
        NEUTRAL_
      end

      # `def send_info_event` <- `make_sender_methods`

      def receive_error_string ev_s
        _ev = sign_string ev_s
        send_error_event _ev
        UNABLE_
      end

      def receive_error_event ev
        _ev_ = sign_event ev
        send_error_event _ev_
      end

      # `def send_error_event` <- `make_sender_methods`

      # ~

      def sign_string s
        s.respond_to? :ascii_only? or self._FIXME
        ev = Snag_::Model_::Event.inflectable_via_string s
        inflect_inflectable_event ev
        ev
      end

      def sign_event ev
        ev.respond_to? :ascii_only? and self._FIXME
        ev_ = Snag_::Model_::Event.inflectable_via_event ev
        inflect_inflectable_event ev_
        ev_
      end

      def inflect_inflectable_event ev
        vnf = self.class.name_function
        nnf = ( vnf.parent && vnf.parent.name_function )
        ev.inflected_verb = vnf && vnf.as_human
        ev.inflected_noun = nnf && nnf.as_human
      end

      extend NF_[].name_function_proprietor_methods

      class Ad_Hoc_Processor_

        def initialize pc
          @upstream = pc.upstream
          @client_module = pc.downstream
        end
      end

      class Make_Delegate_Properties__ < Ad_Hoc_Processor_

        def go

          @upstream.advance_one  # name
          mod = @client_module
          sess = mod.active_entity_edit_session
          @property_class = sess.property_class

          ok = KEEP_PARSING_

          mod.const_get( :Delegate, false ).ordered_dictionary.each_value do | slot |

            _prop = bld_delegating_property_for_slot slot

            ok = sess.receive_property _prop
            ok or break

          end
          ok
        end

      private

        def bld_delegating_property_for_slot _SLOT

          stem_symbol = :"on_#{ _SLOT.name_symbol }"

          @property_class.new do

            @name = Callback_::Name.via_variegated_symbol stem_symbol

            @iambic_writer_method_proc_is_generated = false

            @iwmn = via_name_build_internal_iambic_writer_meth_nm  # #todo publicize this [br] ivar

            _IVAR = :"@#{ stem_symbol }"

            @iambic_writer_method_proc_proc = -> _prp do

              -> do

                _x = iambic_property

                _dlg = some_delegate

                instance_variable_set _IVAR, :_provided_

                _dlg.send _SLOT.attr_writer_method_name, _x

                KEEP_PARSING_
              end
            end
          end
        end
      end

      class Make_Sender_Methods__ < Ad_Hoc_Processor_

        def go

          @upstream.advance_one  # name
          mod = @client_module

          mod.const_get( :Delegate, false ).ordered_dictionary.each_value do |slot|

            _RECEIVE_METHOD_NAME = :"receive_#{ slot.name_symbol }"

            mod.send :define_method, :"send_#{ slot.name_symbol }" do |ev|

              @delegate.send _RECEIVE_METHOD_NAME, ev
            end
          end

          KEEP_PARSING_
        end
      end

      def some_delegate
        @delegate ||= self.class::Delegate.new
      end

      # ~ comport to business methods

      def send_to_delegate i, x
        some_delegate.send :"receive_#{ i }", x
      end
    end
  end
end
