module Skylab::Cull

  class API::Action < Face::API::Action

    attr_accessor :pth

    attr_reader :is_verbose  # accessed by common `api` implementation

  protected

    def model i
      @client.model i
    end
  end
end
