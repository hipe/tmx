module Skylab::Face

  class Model::Manager  # see [#059] the narrative #intro

    def initialize models_module, host
      @models_module = models_module
      @h = { }
      @host = host
    end

    def aref model_ref_a  # #storypoint-15
      @h.fetch model_ref_a do
        klass, is_collection = resolve_ref model_ref_a
        o = klass.new
        o.receive_plugin_attachment_notification @host.plugin_host_metaservices
        b = o.plugin_metaservices.do_memoize
        if b or b.nil? && is_collection
          @h[ model_ref_a ] = 0
        end
        o
      end
    end

    def has_instance model_ref_a
      @h.key? model_ref_a
    end

    def set_new_valid_instance model_ref_a, init_blk, x_if_yes, if_no
      # #storypoint-30
      if @h.key? model_ref_a
        if_no[ Exists_[ model_ref_a: model_ref_a ] ]
      else
        kls, = resolve_ref model_ref_a
        kls.new_valid(
          init_blk,
          -> ent do
            @h.key? model_ref_a and fail "sanity"
            @h[ model_ref_a ] = ent
            if 1 == x_if_yes.arity
              x_if_yes[ ent ]
            else
              x_if_yes[ ]
            end
          end,
          if_no
        )
      end
    end

    Exists_ = Model::Event.new do |model_ref_a|
      "already memoized, won't clobber - #{ model_ref_a }"
    end

    -> do  # `resolve_ref`

      rx = /s$/

      define_method :resolve_ref do |model_ref_a|
        if ::Array === model_ref_a.first then fail 'where' end

        a = model_ref_a.dup
        if rx =~ a.last
          is_collection = true
          a[ -1 ] = $~.pre_match.intern
          a << :collection
        else
          a << :controller
        end
        [ Autoloader_.const_reduce( a, @models_module ), is_collection ]
      end
      private :resolve_ref
    end.call
  end
end
