module Skylab::TanMan
  class API::Action
    # extend Autoloader                 # recursiveness apparently o
    extend Core::Action::ModuleMethods

    include Core::Action::InstanceMethods

    event_class API::Event

    # Using call() gives us a thick layer of isolation between the outward
    # representation and inward implementation of an action.  Outwardly,
    # actions are represented merely as constants inside of some Module
    # that, all we know is, these constants respond to call().  Inwardly,
    # they might be just lambdas, or they might be something more.  This
    # pattern may or may not stick around, and is part of [#sl-100]
    #
    def self.call request_client, params_h, events
      block_given? and fail 'sanity - no blocks here!'
      action = new request_client, events
      result = action.set! params_h
      if result                        # we violate the protected nature of
        result = action.send :execute  # it only b/c we are the class!
      end                              # it is protected for the usual reasons
      result
    end

  public

    # none

  protected

    def initialize request_client, events # pass the callable explicity
      _sub_client_init! request_client
      events[ self ]
    end
  end
end
