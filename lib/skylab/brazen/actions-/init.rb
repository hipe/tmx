module Skylab::Brazen

  class Actions_::Init < Brazen_::Action_

    desc do |y|
      y << "init a #{ highlight '<workspace>' }"
      y << "this is the second line of the init description"
    end

    def self.properties
      Brazen_::Entity::Box_.the_empty_box
    end

    def property_proprietor
    end
  end
end
