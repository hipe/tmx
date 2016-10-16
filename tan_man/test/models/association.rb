module Skylab::TanMan::TestSupport

  module Models::Association

    def self.[] tcc
      TS_::Operations[ tcc ]
      tcc.include self
    end

    define_method :fixtures_path_, ( Lazy_.call do
      ::File.join TS_.dir_path, 'fixture-dot-files-for-association'
    end )

    def collection_class
      Home_::Models::Association::Collection
    end

    def lines
      result.unparse.split NEWLINE_
    end
  end
end
