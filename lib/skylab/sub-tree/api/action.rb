module Skylab::SubTree

  class API::Action

    extend SubTree_::Lib_::Bzn_[].name_library.name_function_proprietor_methods

    Callback_::Actor.methodic self, :simple, :properties

    SubTree_._lib.event_lib.sender self

    def initialize
      # you are executed before a block is instance_exec'd
    end

    def is_API_action
      true
    end

    def bound_call_via_call iambic, event_receiver
      @event_receiver = event_receiver
      ok = receive_iambic iambic
      ok && bound_call
    end

  private

    # ~ intiation lifecycle

    def receive_iambic x_a
      ok = process_iambic_fully x_a
      ok &&= via_default_proc_and_is_required_normalize
      ok && normalize
    end

    def normalize
      PROCEDE_
    end

    def bound_call
      SubTree_::Lib_::Bzn_[].bound_call nil, self, :execute
    end

    # ~ receiving events

    def receive_missing_required_properties ev
      send_event ev
      UNABLE_
    end

    # ~ creating & sending events

    def whine_about_invalid prop_i, template_s  # 'noun', 'x'

      prop = self.class.properties.fetch prop_i
      x = instance_variable_get prop.name.as_ivar

      _ev = build_not_OK_event_with :invalid_property_value,
          :x, x, :prop, prop, :tmpl_s, template_s do |y, o|

        _noun = par o.prop
        _tmpl = SubTree_._lib.string_lib.template.via_string o.tmpl_s
        _x = ick o.x
        _s = _tmpl.call x: _x,  noun: _noun
        y << _s
      end

      send_event _ev
    end

    def send_event ev
      @event_receiver.receive_event ev
    end

    Data_Event_ = SubTree_._lib.event_lib.data_event_class_factory

    module Local_Actor_

      Callback_::Actor.methodic self, :simple, :properties

      property_class_for_write

      class Property

        attr_reader :default_proc  # just a mandatory hook-out for now

      private

        def flag=
          @argument_arity = :zero
          @parameter_arity = :zero_or_one
        end

        def required=
          @parameter_arity = :one
        end
      end
    end
  end
end
