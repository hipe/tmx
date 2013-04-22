module Skylab::Cull

  module Models::Data::Source

    Basic::Field::Box.enhance self do  # `field_box`

      meta_fields :required, :body

      fields  [ :name, :required ],
              [ :url,  :required, :body ],
              [ :tags, :body ]
    end
  end
end
