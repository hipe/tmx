module Skylab::Face

  class API::Action

    #         ~ params related declaration & processing ~

    -> do
      empty_a = [ ].freeze
      define_singleton_method :param_a do empty_a end
      define_singleton_method :param_h do
        @param_h ||= ::Hash.new do |h, k|
          raise "undeclared parameter - #{ k }. (none were declared for #{
            }this action (#{ self }). declare some with `params` ?)"
        end.freeze
      end
    end.call

    define_singleton_method :params, &
        MetaHell::FUN.module_mutex[ ->( * param_a ) do
      if param_a.first.respond_to? :each_index
        param_a = API::Action::Param::Flusher[ param_a, self ]
      end
      param_a.freeze
      param_h = ::Hash[ param_a.each.with_index.to_a ]
      param_h.default_proc = -> h, k do
        raise "undeclared parameter - #{ k } for #{ self }. #{
          }(add it to the list at the existing `params` macro?)"
      end
      param_h.freeze
      define_singleton_method :param_a do param_a end
      define_singleton_method :param_h do param_h end
    end ]

    def initialize client, param_h
      @client = client
      par_h = self.class.param_h
      remain_a = self.class.param_a.dup
      param_h.each do |k, v|
        idx = par_h[ k ] or fail "sanity - default_proc?"
        remain_a[ idx ] = nil
        instance_variable_set :"@#{ k }", v
      end
      remain_a.compact!
      if remain_a.length.nonzero?
        raise ::ArgumentError, "missing argument(s) for #{ self.class } - #{
          }#{ remain_a.inspect }"
      end
      nil
    end

    #         ~ *experimental* event wiring facilities up here ~

    extend Face::Services::PubSub::Emitter
      # child classes define the event stream graph.

    public :on, :with_specificity  # from emitter above, hosts like these public

    class << self
      alias_method :_face_original_emits, :emits  # #todo
    end

    define_singleton_method :emits, & MetaHell::FUN.module_mutex[ ->( *a ) do
      _face_original_emits( *a )
      @event_stream_graph.names.each do |i|
        define_method i do |x|
          emit i, x
          nil
        end
      end
      nil
    end ]
  end
end
