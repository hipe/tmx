module Skylab::Snag

  module API

    class Action_  # replacement

      def initialize client

        @find_closest_manifest_p = client.method :find_closest_manifest
        @listener = nil
      end

      def invoke_via_iambic x_a
        process_iambic_fully x_a
        raise_argument_error_about_missing_required
        execute
      end

      attr_reader :up_from_path

    private

      def some_listener
        @listener ||= self.class::Listener.new
      end

      def raise_argument_error_about_missing_required
        scn  = self.class.properties.to_value_scanner ; a = nil
        while (( prop = scn.gets ))
          prop.required or next
          ivar = prop.as_ivar
          instance_variable_set ivar and !
            instance_variable_get( ivar ).nil? and next
          ( a ||= [] ).push prop
        end
        a and raise ::ArgumentError, say_missing_required( a )
      end

      def say_missing_required a
        "missing required API properties (#{ a.map( & :name_i ) * ', ' })"
      end

      def execute
        if nodes
          if_nodes_execute
        else
          @nodes
        end
      end

      def nodes
        @did_rslv_nodes ||= rslv_nodes
        @nodes
      end

      def rslv_nodes
        mani = @find_closest_manifest_p[ up_from_path, -> ev_s do
          error_string ev_s
        end ]
        @nodes = mani && Snag_::Models::Node.build_collection( mani, self )
        true
      end

      def info_string ev_s
        ev = Snag_::Model_::Event.from_string ev_s
        inflect_inflectable_event ev
        send_info_event ev
        NEUTRAL_
      end

      def info_event ev
        ev_ = Snag_::Model_::Event.from_event ev
        inflect_inflectable_event ev_
        send_info_event ev_
        NEUTRAL_
      end

      def error_string ev_s
        ev = Snag_::Model_::Event.from_string ev_s
        inflect_inflectable_event ev
        send_error_event ev
        UNABLE_
      end

      def inflect_inflectable_event ev
        vnf = self.class.name_function
        nnf = ( vnf.parent && vnf.parent.name_function )
        ev.inflected_verb = vnf && vnf.as_human
        ev.inflected_noun = nnf && nnf.as_human
      end

      Snag_::Model_.name_function self

      Entity_ = Snag_::Lib_::Entity[][ -> do

        o :meta_property, :required

        o :ad_hoc_processor, :make_listener_properties, -> x do
          Make_Listener_Properties__.new( x ).go
        end

        o :ad_hoc_processor, :make_sender_methods, -> x do
          Make_Sender_Methods__.new( x ).go
        end
      end ]

      class AHP_
        def initialize scn
          @scn = scn
        end
      end
      class Make_Listener_Properties__ < AHP_
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
      class Make_Sender_Methods__ < AHP_
        def go
          _ = @scn.gets_one  # name
          mod = @scn.reader
          lcls = mod.const_get :Listener, false
          lcls.ordered_dictionary.each_value do |slot|
            m_i = :"send_#{ slot.name_i }_event"
            m_i_ = :"receive_#{ slot.name_i }_event"
            mod.send :define_method, m_i do |ev|
              @listener.send m_i_, ev
            end
          end ; nil
        end
      end
    end
  end
end
