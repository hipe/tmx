module Skylab::Cull

  module Models::Config

    Collection = CodeMolester::Model::Config::Collection
    Controller = CodeMolester::Model::Config::Controller

    module File
      # used by data source
      Invalid = Models::Event.new do |cm_invalid_reason_o|
        cm_invalid_reason_o.render
      end
    end
  end
end
