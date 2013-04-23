module Skylab::CodeMolester

  # entity-related nerks need too many different subproducts to make
  # following the convention worth it.

  CodeMolester::Services.const_get :Basic, false

  CodeMolester::Services.const_get :Face, false

  module Config::File::Entity

    Entity = self

    %i| Basic CodeMolester Face Headless MetaHell |.each do |i|
      const_set i, ::Skylab.const_get( i, false )
    end

    Event = Face::Model::Event

  end
end
