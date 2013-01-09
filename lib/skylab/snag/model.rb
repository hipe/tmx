module Skylab::Snag
  module Model
  end

  class Model::Event < ::Struct
    extend Headless::Model::Event # `normalized_event_name`

    EVENTS_ANCHOR_MODULE = Snag::Models

    def self.normalized_event_name
      @nen ||= begin              # (just for fun chop out the `events`
        arr = super.dup           # box module, for aesthetics and to see
        arr[1, 1] = []            # what happens.)
        arr
      end
    end

    def self.build_message message_lambda
      define_method :message_lambda do message_lambda end
    end

    def render_for request_client
      Model::Event::SubClient.for( self.class ).
        new( request_client, self ).render
    end

    def message_lambda
    end
  end

  module Model::Event::SubClient  # this is for experiments with model event
                                  # rendering. the premise is that we make a
                                  # one-off sub-client for rendering an event,
                                  # because a) making events themselves be
                                  # sub-clients feels icky and wrong and b)
                                  # calling instance_eval on an arbitrary
                                  # request client also feels wrong.


    def self.for event_class
      if event_class.const_defined? :SubClient, false
        event_class.const_get :SubClient, false
      else
        ad_hoc_subclass = ::Class.new event_class
        event_class.const_set :SubClient, ad_hoc_subclass
        event_class.send :include, Model::Event::SubClient
        ad_hoc_subclass
      end
    end

    include Core::SubClient::InstanceMethods

  protected

    def initialize request_client, event
      _snag_sub_client_init! request_client
      @message_lambda = event.message_lambda
      event.members.each do |m|
        self[m] = event[m]
      end
    end

    def render
      instance_exec(& @message_lambda)
    end
  end
end
