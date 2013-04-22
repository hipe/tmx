module Skylab::Cull

  module Models::Config

    Collection = CodeMolester::Model::Config::Collection
    Controller = CodeMolester::Model::Config::Controller

    -> do
      fn = '.cullconfig'
      define_singleton_method :filename do fn end
    end.call

    module File
      # used by data source
      Invalid = Models::Event.new do |cm_invalid_reason_o|
        cm_invalid_reason_o.render
      end
    end
  end
end
