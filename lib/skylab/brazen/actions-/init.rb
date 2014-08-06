module Skylab::Brazen

  class Actions_::Init < Brazen_::Action_

    desc do |y|
      y << "init a #{ highlight '<workspace>' }"
      y << "this is the second line of the init description"
    end

    def self.properties ; end

  end
end
