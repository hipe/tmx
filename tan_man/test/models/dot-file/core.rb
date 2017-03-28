module Skylab::TanMan::TestSupport

  module Models::Dot_File

    # superb hackery to overcome our loss of dedicated test modules..

    class << self

      def [] tcc

        TS_::Operations[ tcc ]
        tcc.include self
      end

      def client_class__
        Client_class__[]
      end
    end  # >>

    def fixtures_path_
      self._SOMETHING
    end

    def prepare_to_produce_result
      @parse = client_class.new Meh___[]
      true
    end

    # --

    Meh___ = Lazy_.call do

      # even the standalone parsing "client" needs an invocation so that
      # it can make a #[#007.C] sub-invocation to the "paths" service.
      # memoizing this invocation (which in turn memoizes one particular
      # path) frees us from invoking a lot of heavy machinery many dozens of
      # times just to produce the same path over and over. under #tombstone-B
      # that action was a plain old proc, but perhaps was heavier than this
      # memoized.

      Home_::API.invocation_via_argument_array do |*i_a, &ev_p|
        TS_._COVER_ME__something_failed_at_a_low_level__
      end
    end

    # -- client class "discovery" is mostly an exercise

    def client_class
      Client_class__[]
    end

    yes = true
    x = nil
    discover_client_class = nil

    Client_class__ = -> do
      if yes
        yes = nil
        x = discover_client_class[]
      end
      x
    end

    discover_client_class = -> do

      _path = Models::Dot_File.dir_path

      TS_::client_proximity_index_.nearest_such_class_to_path _path
    end

    # --

    module Manipulating
      module Label

      end
    end
  end
end
# :#tombstone-B: attempting to get rid of memoized, monolithic kernel
# (document history: "proximity index" broke out of this and took the history)
