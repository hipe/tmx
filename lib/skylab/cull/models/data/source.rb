module Skylab::Cull

  module Models::Data::Source

    # (see also Skylab::Cull::API::Actions::DataSource::Add)

    Basic::Field::Box.enhance self do  # `field_box`

      # meta_meta_fields :property

      meta_fields :required, :body, :list,
        [ :regex, :property ], [ :rx_fail_predicate_tmpl, :property ]

      fields  [ :name, :required, :regex, /\A[-a-z]+\z/ ],
              [ :url,  :required, :body ],
              [ :tag_a, :body, :list, :regex, /\A[-_a-z0-9]+\z/,
                                  :rx_fail_predicate_tmpl,
                                  "contains invalid character, must be #{
                                    }lowercase alphanumeric for now #{
                                    }(had {{ick}})" ]
    end
  end

  class Models::Data::Source::Collection

    CodeMolester::Config::File::Entity::Collection.enhance self do

      with Models::Data::Source

      add

      list_as_json

    end
  end

  class Models::Data::Source::Controller

    CodeMolester::Config::File::Entity::Controller.enhance self do

      with Models::Data::Source

      add

    end

  end
end
