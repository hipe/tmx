module Skylab::TanMan::TestSupport

  module Models::Dot_File

    # superb hackery to overcome our loss of dedicated test modules..

    class << self

      def [] tcc

        Models[ tcc ]
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
      @parse = client_class.new
      true
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
# (document history: "proximity index" broke out of this and took the history)
