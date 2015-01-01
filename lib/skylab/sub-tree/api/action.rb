module Skylab::SubTree

  class API::Action

    class << self

      def edit_entity_directly _, oes_p, & edit_p  # #hook-near [br]
        o = new _, & oes_p
        o.instance_exec( & edit_p )
        o
      end
    end

    extend SubTree_::Lib_::Bzn_[].name_library.name_function_proprietor_methods

    Callback_::Actor.methodic self, :simple, :properties

    SubTree_.lib_.event_lib.selective_builder_sender_receiver self

    def initialize _, & oes_p
      @on_event_selectively = oes_p
    end

    def is_API_action
      true
    end

    def bound_call_against_iambic_stream st  # #hook-near [br]
      _ok = recv_iambic_stream st
      _ok && bound_call
    end

  private

    # ~ intiation lifecycle

    def recv_iambic_stream st
      ok = process_iambic_stream_fully st
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
      maybe_send_event :error, :missng_required_properties do
        ev
      end
      UNABLE_
    end

    # ~ creating & sending events

    def whine_about_invalid prop_i, template_s  # 'noun', 'x'

      @oes.call :error, :invalid_property_value do
        bld_invalid_property_value_event prop_i, template_s
      end
    end

    def bld_invalid_property_value_event prop_i, template_s

      prop = self.class.properties.fetch prop_i
      x = instance_variable_get prop.name.as_ivar

      build_not_OK_event_with :invalid_property_value,
          :x, x, :prop, prop, :tmpl_s, template_s do |y, o|

        _noun = par o.prop
        _tmpl = SubTree_.lib_.string_lib.template.via_string o.tmpl_s
        _x = ick o.x
        _s = _tmpl.call x: _x,  noun: _noun
        y << _s
      end
    end

    Data_Event_ = SubTree_.lib_.event_lib.data_event_class_factory

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
