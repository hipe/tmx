module Skylab::TanMan::TestSupport

  module Models::Association

    def self.[] tcc
      Models[ tcc ]
      tcc.include self
    end

    define_method :fixtures_path_, ( Common_.memoize do
      _path = Models::Association.dir_path
      ::File.join _path, FIXTURES_ENTRY_
    end )

    def collection_class
      Home_::Models::Association::Collection
    end

    def lines
      result.unparse.split NEWLINE_
    end
  end
end
