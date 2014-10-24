module Skylab::Headless
  module Model
    # everything here is *very* #experimental -- we are trying to
    # keep it solid and only float things up here carefully because what we
    # end up with could either be something wonderful or something wonderfully
    # smelly.

    # specifically, message building is an area of extreme experimentation
    # that is no where near ready to be distilled up into here yet!
    # we do *not* want to require that event objects be sub-clients!
  end


  module Model::Event

    def self.apply_on_client mod
      mod.extend Model::Event::ModuleMethods
      mod.send :include, Model::Event::InstanceMethods
    end

    def self.extended mod  # [#sl-111]  :+#deprecation:until-universal-integration
      raise "`extend` is deprecated here - use `apply_on_client` instead"
    end
  end

  module Model::Event::ModuleMethods

    def name_function
      @nf ||= Headless_::Name.via_module_name_anchored_in_module_name(
        self, self::EVENTS_ANCHOR_MODULE )
    end

    def event_anchored_normal_name
      name_function.local_normal_name
    end
  end

  module Model::Event::InstanceMethods

    def is? sym                   # this has the obvious barrel of the
      if ::Symbol === sym         # obvious shotgun it is staring down,
        event_anchored_normal_name.last == sym              # maybe several
      else
        event_anchored_normal_name == sym # ick
      end
    end

    def event_anchored_normal_name
      self.class.event_anchored_normal_name
    end
  end
end
