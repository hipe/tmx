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
    def self.extended mod # [#sl-111]
      mod.extend Model::Event::ModuleMethods
      mod.send :include, Model::Event::InstanceMethods
    end
  end

  module Model::Event::ModuleMethods
    extend MetaHell::Let          # just for memoizing below

    let :name_function do
      Headless::Name::From::Module_Anchored self, self::EVENTS_ANCHOR_MODULE
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
