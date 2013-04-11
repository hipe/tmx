module Skylab::Cull

  class API::Action

    extend PubSub::Emitter  # child classes create graph.
    public :on, :with_specificity

    attr_accessor :pth

    attr_reader :is_verbose  # accessed by common `api` implementation

    def self.params *param_a
      param_a.freeze
      param_h = ::Hash[ param_a.each.with_index.to_a ].freeze
      define_singleton_method :param_a do param_a end
      define_singleton_method :param_h do param_h end
      nil
    end

    def self.emits( * )
      super
      @event_stream_graph.names.each do |i|
        define_method i do |x|
          emit i, x
          nil
        end
      end
      nil
    end

  protected

    def initialize client, param_h
      @client = client
      par_h = self.class.param_h
      remain_a = self.class.param_a.dup
      param_h.each do |k, v|
        remain_a[ par_h.fetch k ] = nil
        instance_variable_set :"@#{ k }", v
      end
      remain_a.compact!
      if remain_a.length.nonzero?
        raise ::ArgumentError, "missing argument(s) for #{ self.class } - #{
          }#{ remain_a.inspect }"
      end
      nil
    end

    def ok
      true
    end

    def model i
      @client.model i
    end
  end
end
