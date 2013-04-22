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
    # if this name references a  controller or a collection (controller).
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
        c.load_plugin sty, @host.plugin_services
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

    def set_instance model_ref_a, init_blk
      if @h.key? model_ref_a
        raise "already cached, won't clobber - #{ model_ref_a }"
      end
      kls, = resolve_ref model_ref_a
      kls.new_valid -> o do
        # NOTE we used to set api client here..
        init_blk[ o ]
      end, -> o do
        @h[ model_ref_a ] = o
      end, -> rsn do
        raise ::ArgumentError, rsn
      end
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
