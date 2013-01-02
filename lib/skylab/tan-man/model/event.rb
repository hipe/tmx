module Skylab::TanMan
  class Model::Event < ::Struct
    #
    # all here.
    #
    # Some notes about model events: 1) they are #experimental.
    # 2) they are structs with a little extra added behavior
    # 3) one day we will reconcile how they are at odds with API events,
    # for now we bridge this gap by always calling to_h, and letting
    # the api create an event anew with our custom, business-specific
    # metadata in it. 2) for absolutely *no* reason except we find it
    # more readable with their generally more-than-two-word-long const
    # names, we give them Names_Like_This (camel + underscore), which
    # we are going to make a thing, for all business event subclasses
    #
    # How they are different from API events:
    # 1) they are subclients, which allows for rich rendering in
    # the `build_message` impls.  2) they don't fit into an event
    # graph (is it :info or is it :error etc), which may actually be
    # a good thing. Generally they are different in that we create one
    # such subclass (struct) for each kind of (business) event we emit.
    #

    include Core::SubClient::InstanceMethods

    ANCHOR_MODULE = TanMan        # for `normalized_event_name` below

    class << self
      extend MetaHell::Let        # just for memoizing belo in the class object
      let :normalized_event_name, & Headless::Action::FUN.build_normalized_name
    end


    def is? sym                   # this has the obvious barrel of the
      if ::Symbol === sym         # obvious shotgun it is staring down,
        normalized_event_name.last == sym              # maybe several
      else
        normalized_event_name == sym # ick
      end
    end

    def message
      @message || build_message
    end

    attr_writer :message

    def normalized_event_name
      self.class.normalized_event_name
    end

    def to_h
      members.reduce( message: message ) do |memo, member|
        val = self[member]
        if val.respond_to? :to_h
          val = val.to_h
        end
        memo[member] = val
        memo
      end
    end

    def to_s
      message
    end

  protected

    def initialize request_client, *a
      @message = nil
      _tan_man_sub_client_init! request_client
      members.zip( a ).each { |k, v| self[k] = v }
    end
  end


  class Model::Event::Aggregate < Model::Event.new :list

    def build_message
      list.map(&:message).join '. '
    end

    def initialize *a
      if a.length.zero?
        super nil, [ ]
      else
        super # expert mode
      end
    end
  end
end
