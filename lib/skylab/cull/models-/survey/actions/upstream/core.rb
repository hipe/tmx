module Skylab::Cull

  module Models::Data::Source

    # (see also Skylab::Cull::API::Actions::DataSource::Add)

    CodeMolester::Config::File::Entity.enhance self do

      fields( [ :name,  :required, :regex, /\A[a-z][-a-z0-9]+\z/ ],
              [ :url,   :required, :body ],
              [ :tag_a, :body, :list,
                        :ivar, :tag_a,
                        :regex, /\A[-_a-z0-9]+\z/,
                        :rx_fail_predicate_tmpl, "contains invalid character, #{
                                }must be lowercase alphanumeric for now #{
                                }(had {{ick}})",
              ],
      )  # (trailing comma above is intentional)
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
