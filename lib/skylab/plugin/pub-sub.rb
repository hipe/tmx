module Skylab::Plugin

  module Pub_Sub  # see [#005]

    class Dispatcher < Dispatcher_

      def initialize resources=nil, emit_sym_a, & oes_p

        bx = Callback_::Box.new
        emit_sym_a.each do | sym |
          bx.add sym, Callback_::Box.new
        end
        @_bx = bx

        super resources || self, & oes_p
        freeze
      end

      def receive_plugin pu_d=nil, pu

        bx = @_bx
        sym_a = pu.subscription_name_symbols

        if ! pu_d
          pu_d = @_bx.length
        end

        if sym_a
          sym_a.each do | sym |

            bx.fetch( sym ).set pu_d, true
          end
        end

        super
      end

      def accept sym, & each_pu

        ok = KEEP_PARSING_
        @_bx.fetch( sym ).a_.each do | pu_d |

          ok = each_pu[ @plugin_a.fetch( pu_d ) ]
          ok or break
        end
        ok
      end
    end

    class Subscriber

      class << self

        def new_via_resources x, & x_p
          new nil, x, & x_p
        end

        alias_method :new_via_plugin_identifier_and_resources, :new
        private :new
      end  # >>

      attr_reader(
        :on_event_selectively,
      )

      def initialize pu_d, resc, & oes_p
        @on_event_selectively = oes_p
        @plugin_identifier = pu_d
        @resources = resc
        @subscription_name_symbols = nil
      end

      def subscription_name_symbols

        @subscription_name_symbols or
          self.class.const_get :SUBSCRIPTIONS, false  # until etc
      end

      attr_writer(
        :on_event_selectively,
        :plugin_identifier,
        :subscription_name_symbols,
      )
    end
  end
end
