module Skylab::TanMan
  class API::Action
    # extend Autoloader                 # recursiveness apparently o
    extend Core::Action::ModuleMethods

    include Core::Action::InstanceMethods

    ACTIONS_ANCHOR_MODULE = API::Actions  # #experimental near [#059]

    event_class API::Event

    # Using call() gives us a thick layer of isolation between the outward
    # representation and inward implementation of an action.  Outwardly,
    # actions are represented merely as constants inside of some Module
    # that, all we know is, these constants respond to call().  Inwardly,
    # they might be just lambdas, or they might be something more.  This
    # pattern may or may not stick around, and is part of [#sl-100]
    #
    def self.call request_client, param_h, events
      block_given? and fail 'sanity - no blocks here!'
      action = new request_client, events
      result = action.set! param_h
      if result                        # we violate the protected nature of
        result = action.send :execute  # it only b/c we are the class!
      end                              # it is protected for the usual reasons
      result
    end

  public

    # none

  protected

    define_method :initialize do |request_client, events|
      init_headless_sub_client request_client
      events[ self ]

      # We cautiouly and experimentally re-introduce the idea of "knobs"
      # ([#016]) below. (knobs in porcelain.all ended up being a
      # terrible idea, but here they just feel right.)

      me = self


      # Notice there is an inversion in the taxonomy - the class/module
      # hierarchy goes TanMan::Models::<model>::<controller>
      # but the knob call goes self.<controller plural>.<model> which
      # seems fine.

      method_missing = -> controller_const do
        -> method do
          k = TanMan::Models.const_fetch( method, false ). # WE LOVE YOU BOXXY
            const_get( controller_const, false )
          x = k.new me
          x.verbose = me.send :verbose # this is so common let's sledgehammer it
          define_singleton_method( method ) { x }
          x
        end
      end

      o = @collections = ::Object.new
      o.define_singleton_method :method_missing, & method_missing[ :Collection ]

      o = @controllers = ::Object.new
      o.define_singleton_method :method_missing, & method_missing[ :Controller ]

    end

    attr_reader :collections

    attr_reader :controllers
  end
end
