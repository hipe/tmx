module Skylab::Face

  class Model::Manager

    # #experimental -
    # abstracted from *one* application, the main thing a `Model::Manager`
    # does is manage that there is only one memory-persistent instance
    # of each collection (and, if desired per model, one controller).


    # `initialize` - assumes `models_module` is boxxy (that is, responds
    # to `const_fetch`

    def initialize models_module, host
      @models_module = models_module
      @h = { }
      @host = host
    end

    # `aref` - `model_ref_a` is a singular or plural sounding name,
    # whose single- or plural-sounding-ness will be used to determine
    # if this name references a controller or a collection (controller).
    #
    # ("aref" is a more low-level sounding name for `[]`, borrowed from
    # the ruby source). currently our behavior is to result in the
    # memoized instance of the model controller/collection if one exists,
    # otherwise instiate one and, if it is deemed appropriate, memoize it.
    # result is the new or existing nerk, and you have no way of knowing
    # which.

    def aref model_ref_a
      @h.fetch model_ref_a do
        k, is_collection = resolve_ref model_ref_a
        sty = k.plugin_story
        c = k.new
        c.load_plugin @host.plugin_services, sty
        if sty.do_memoize.nil? && is_collection or sty.do_memoize
          @h[ model_ref_a ] = c
        end
        c
      end
    end

    # `has_instance` - note the non-globbiness of the signature.

    def has_instance model_ref_a
      @h.key? model_ref_a
    end

    # `set_new_valid_instance` - poka yoke!
    # the init block comes from upstream and the validation happens
    # downstream yay! we are the middleman who memoizes the valid entity
    # (or collection). `x_if_yes` gets the entity if it takes one argument,
    # otherwise (if yes) is called with no arguments.

    def set_new_valid_instance model_ref_a, init_blk, x_if_yes, if_no
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
        a = model_ref_a.dup
        if rx =~ a.last
          is_collection = true
          a[ -1 ] = $~.pre_match.intern
          a << :collection
        else
          a << :controller
        end
        [ @models_module.const_fetch( a ), is_collection ]
      end
      private :resolve_ref
    end.call
  end
end
