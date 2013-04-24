module Skylab::Cull

  class Models::Data::Source::Collection

    CodeMolester::Config::File::Entity::Collection.enhance self do

      with Models::Data::Source

      add

      list_as_json

    end
  end
end
