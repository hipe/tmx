module Skylab::SubTree

  class API::Action

    extend SubTree_::Lib_::Bzn_[].name_library.name_function_proprietor_methods

    Callback_::Actor.methodic self, :simple, :properties

    SubTree_::Lib_::Event_lib[].sender self

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
        _tmpl = SubTree_::Lib_::String_lib[].template.via_string o.tmpl_s
        _x = ick o.x
        _s = _tmpl.call x: _x,  noun: _noun
        y << _s
      end

      send_event _ev
    end

    def send_event ev
      @event_receiver.receive_event ev
    end

    module Data_Event_

      class << self
        def new * i_a
          ::Module.new.module_exec do
            extend Module_Methods__
            i_a.freeze
            define_singleton_method :members do
              i_a
            end
            self
          end
        end
      end  # >>

      module Module_Methods__

        def [] * a
          build_via_arglist a
        end

        def build_via_arglist a
          evnt_class.via_arglist a
        end

      private

        def evnt_class
          @evnt_cls ||= bld_event_class
        end

        def bld_event_class
          x_a = [ name_i ]
          members.each do |i|
            x_a.push i, nil
          end
          x_a.push :ok, true
          ecls = SubTree_::Lib_::Event_lib[].
            prototype.via_deflist_and_message_proc x_a, nil
          const_set :Event___, ecls
          ecls
        end

        def name_i
          Callback_::Name.via_module( self ).as_trimmed_variegated_symbol
        end
      end
    end

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
