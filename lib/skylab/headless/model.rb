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
      Headless::Name::From::Module::Graph self, self::EVENTS_ANCHOR_MODULE
    end

    def normalized_event_name
      name_function.normalized_name
    end
  end

  module Model::Event::InstanceMethods

    def is? sym                   # this has the obvious barrel of the
      if ::Symbol === sym         # obvious shotgun it is staring down,
        normalized_event_name.last == sym              # maybe several
      else
        normalized_event_name == sym # ick
      end
    end

    def normalized_event_name
      self.class.normalized_event_name
    end
  end
end
