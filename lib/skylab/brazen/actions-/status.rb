module Skylab::Brazen

  class Actions_::Status < Brazen_::Action_

    desc do |y|
      y << "get status of a workspace"
    end

    Brazen_::Entity_[ self, -> do

      o :flag, :property, :verbose


      o :default, '.'
      o :description, "the location of the workspace"
      o :description, -> y do
        y << "it's #{ highlight 'really' } neat"
      end
      o :property, :path

    end ]
  end
end
