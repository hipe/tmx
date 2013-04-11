module Skylab::Cull

  class CLI::Namespace < Face::Namespace
    module InstanceMethods
    end
    include InstanceMethods  # built-out below

  protected

  end

  module CLI::Namespace::InstanceMethods

  protected

    def initialize( * )
      super
      @param_h = { }
    end

    def api *args
      a = normalized_child_name
      param_h = complete_param_h args
      action = api_client.build_action a, param_h
      set_behaviors action
      handle_events action
      action.execute
    end

    def normalized_child_name
      x = @last_normalized_child_slug or fail 'sanity'
      a = [ x ]
      visit_normalized_name a
      if instance_variable_defined? :@parent and @parent
        @parent.send :visit_normalized_name, a
      end
      a
    end

    def visit_normalized_name a
      a.unshift @sheet.slug.intern
      nil
    end

    def complete_param_h args
      @param_h or fail 'sanity'
      m = method @last_normalized_child_slug
      m.parameters.each_with_index do | (_, k), i|
        @param_h[ k ] = args.fetch i
      end
      param_h = @param_h ; @param_h = nil
      param_h
    end

    %i| api_client set_behaviors handle_events |.each do |i|
      define_method i do |*a, &b|
        @parent.send i, *a, &b
      end
    end
  end
end
