module Skylab::Cull

  module Models::Data::Source

    -> do  # `self.field_box`
      field_box = Models::Field::Box[
        [ :name, :required ],
        [ :url, :required, :body ],
        [ :tags, :body ]
      ]
      define_singleton_method :field_box do field_box end
    end.call

  end
end
