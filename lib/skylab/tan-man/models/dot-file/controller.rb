module Skylab::TanMan
  module Models::DotFile end
  class Models::DotFile::Controller < ::Struct.new(:path, :statement)
    extend ::Skylab::Headless::Parameter::Controller::StructAdapter
    include API::Achtung::InstanceMethods
    def invoke params
      set!(params) or return
      info "WHAT THE ACTUAL FUCK BETHANY: #{statement.class.nt_name}"
    end
  end
end
