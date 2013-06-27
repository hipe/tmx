module Skylab::Cull

  class API::Action < Face::API::Action

    attr_reader :be_verbose  # accessed by common `api` implementation

    taxonomic_streams  # none. (but this allows us to check for unhandled
    # non-taxonomic streams - sorta future-proofing it.)

    def self.cfg
      # leave it as a hook for now
    end
  end
end
