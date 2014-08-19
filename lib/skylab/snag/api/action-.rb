module Skylab::Snag

  class API

    class Action_  # replacement

      include API::Action::Business_Methods___

      def initialize _API_client
        @API_client = _API_client
        @listener = nil
      end

      def invoke_via_iambic x_a
        process_iambic_fully x_a
        if_any_missing_required_raise_argument_error
        execute
      end

      attr_reader :up_from_path

    private

      def if_any_missing_required_raise_argument_error
        scn  = self.class.properties.to_value_scanner ; a = nil
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
        "missing required API propert{y|ies} (#{ a.map( & :name_i ) * ', ' })"
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

      Snag_::Model_.name_function self

      Entity_ = Snag_::Lib_::Entity[][ -> do

        o :meta_property, :is_required

        o :ad_hoc_processor, :make_listener_properties, -> x do
          Make_Listener_Properties__.new( x ).go
        end

        o :ad_hoc_processor, :make_sender_methods, -> x do
          Make_Sender_Methods__.new( x ).go
        end

        property_class_for_write
        class self::Property
          o do
            o :iambic_writer_method_name_suffix, :'='
            def required=
              @is_required = true
            end
          end
        end

      end ]

      class Ad_Hoc_Processor_
        def initialize scn
          @scn = scn
        end
      end

      class Make_Listener_Properties__ < Ad_Hoc_Processor_
        def go
          _ = @scn.gets_one  # name
          kernel = @scn.reader.property_scope_krnl
          lcls = @scn.reader.const_get :Listener, false
          lcls.ordered_dictionary.each_value do |slot|
            i = :"on_#{ slot.name_i }"
            kernel.add_property_via_i i do
              instance_variable_set :"@#{ i }", :_provided_
              some_listener.send slot.attr_writer_method_name, iambic_property
            end
          end
        end
      end

      class Make_Sender_Methods__ < Ad_Hoc_Processor_
        def go
          _ = @scn.gets_one  # name
          mod = @scn.reader
          lcls = mod.const_get :Listener, false
          lcls.ordered_dictionary.each_value do |slot|
            m_i = :"send_#{ slot.name_i }"
            m_i_ = :"receive_#{ slot.name_i }"
            mod.send :define_method, m_i do |ev|
              @listener.send m_i_, ev
            end
          end ; nil
        end
      end

      def some_listener
        @listener ||= self.class::Listener.new
      end

      # ~ comport to business methods

      def send_to_listener i, x
        some_listener.send :"receive_#{ i }", x
      end
    end
  end
end
