module Skylab::Cull

  class API::Action < Face::API::Action

    attr_accessor :pth

    attr_reader :be_verbose  # accessed by common `api` implementation

  end
end
