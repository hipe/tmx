module Skylab::Cull

  class API::Action < Face::API::Action

    attr_accessor :pth

    attr_reader :be_verbose  # accessed by common `api` implementation

  protected

    def model *i_a
      @client.model( *i_a )
    end
  end
end
