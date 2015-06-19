module Skylab::Plugin

  module Pub_Sub  # see [#005]

    class Dispatcher < Dispatcher_

      def initialize resources=nil, emit_sym_a, & x_p

        bx = Callback_::Box.new
        emit_sym_a.each do | sym |
          bx.add sym, []
        end

        @_subscriptions_bx = bx

        super resources || self, & x_p
        freeze
      end

      # ~ ( duping a dispatcher is non-trivial:

      def dup  # FOLLOW

        otr = super
        yield otr  # caller must set oes_p and resources
        otr.__via_resources_initialize_dup @_subscriptions_bx, @plugin_a
        otr
      end

      def initialize_dup _

        # the onus is on caller to reconcile:

        @on_event_selectively = false
        @plugin_a = false
        @resources = false

        # we will do this later:

        @_subscriptions_bx = false
      end

      attr_accessor(  # for initting dups only
        :on_event_selectively,
        :resources,
      )

      def __via_resources_initialize_dup subs_bx, plugin_a

        # the dup gets its own deep copy of the subscription
        # tree, which itslef has no objects, just primitives

        bx_ = subs_bx.class.new

        subs_bx.each_pair do | sym, listeners_a |
          bx_.add sym, listeners_a.dup
        end

        @_subscriptions_bx = bx_

        # each plugin (or strategy etc) might need to freeze immediately,
        # so when it is duped it must be able to access the correct rsx

        @plugin_a = plugin_a.map do | pu |

          pu.dup do
            self
          end
        end

        NIL_
      end

      # ~ )

      def receive_plugin pu_d=nil, pu

        sym_a = pu.subscription_name_symbols

        if sym_a && sym_a.length.nonzero?

          pu_d ||= @plugin_a.length

          sym_a.each do | sym |

            @_subscriptions_bx.fetch( sym ).push pu_d
          end
        end

        super
      end

      def accept sym, & visit

        ok = KEEP_PARSING_
        @_subscriptions_bx.fetch( sym ).each do | pu_d |

          ok = visit[ @plugin_a.fetch( pu_d ) ]
          ok or break
        end
        ok
      end

      def subscriptions
        @_subscriptions_bx
      end

      def retrieve_plugin d
        @plugin_a.fetch d
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
          self.class::SUBSCRIPTIONS  # you must look up
      end

      attr_writer(
        :on_event_selectively,
        :plugin_identifier,
        :subscription_name_symbols,
      )
    end
  end
end
