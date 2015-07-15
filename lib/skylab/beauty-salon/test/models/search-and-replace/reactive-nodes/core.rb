module Skylab::BeautySalon::TestSupport

  module Models::Search_And_Replace::Reactive_Nodes

    def self.[] tcc
      Models::Search_And_Replace[ tcc ]
      tcc.include self
    end

    define_method :common_args_, -> do
      x = nil
      p = -> do
        x = [
          :search, /\bwazoozle\b/i,
          :dirs, TestSupport_::Data.dir_pathname.to_path,
          :files, '*-line*.txt',
          :preview,
          :matches,
          :grep,
        ].freeze
      end
      -> do
        x || p[]
      end
    end.call

    def basename_ s
      ::File.basename s
    end

    define_method :_THREE_LINES_FILE, -> do
      x = nil
      -> do
        x ||= 'three-lines.txt'
      end
    end.call
  end
end
