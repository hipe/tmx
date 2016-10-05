module Skylab::Common

  # wickedly loaded at #spot-3

  # == payback

  if const_defined? :Models_, false
    self._OK_get_rid_of_this
  end

  module Models_
    module Event
      Autoloader[ self ]
    end
    Autoloader[ self ]
  end

  # == end payback

  Models_::Ping = -> pxy do

    pxy.on_event_selectively.call :info, :expression, :ping do | y |
      y << "hello from common."
    end
    :hello_from_common
  end

  module Models_::Event

    module Common_Action_Methods_

      def resolve_module_

        h = @argument_box.h_

        o = Home_::Sessions_::Resolve_Module.new( & handle_event_selectively )
        o.path = h.fetch :file
        o.qualified_const_string = h.fetch :const

        mod = o.execute
        if mod
          @module_ = mod
          ACHIEVED_
        else
          mod
        end
      end
    end

    Actions = ::Module.new

    Autoloader[ Actions, :boxxy ]  # eew

    class Actions::Fire < Brazen_::Action

      include Common_Action_Methods_

      @is_promoted = true

      Brazen_::Modelesque::Entity[ self ]

      edit_entity_class(

        :required, :property, :file,

        :required, :property, :const,

        :required, :property, :channel

      )

      def produce_result

        _ok = resolve_module_
        _ok && __via_module
      end

      def __via_module

        cls = @module_
        pay = 'wizzle pazzle whatever'
        sym = @argument_box.fetch( :channel ).intern

        _d = cls.instance_method( :initialize ).arity.abs

        o = cls.new( * _d.times.map { } )

        did = false
        ev = nil
        o.send :"on_#{ sym }" do | ev_x |
          did = true
          ev = ev_x
        end

        x = o.send :call_digraph_listeners, sym, pay
        if did
          __when_did x, ev
        else
          self._COVER_ME
        end
      end

      def __when_did x, ev

        if ! x.nil?
          maybe_send_event :payload, :expression, :strange_result do | y |
            y << "strange result: #{ ick x }"
          end
        end

        maybe_send_event :payload, :expression, :event_event do | y |

          a = []
          o = Home_.lib_.basic::String.via_mixed.dup
          o.max_width = 40
          p = o.to_proc ; o = nil

          ev.instance_variables.each do | ivar |

            _x = ev.instance_variable_get ivar
            a.push "#{ ivar }=#{ p[ _x ] }"
          end

          y << "event: #<#{ ev.class } #{ a * ', ' }>"
        end

        ACHIEVED_
      end
    end
  end
end
