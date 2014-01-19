module Skylab::Subsystem

  class Library < ::Module

    # an experimental playground for DRY-ing up this popular pattern
    # among subproduct-level nodes :[#001]

    def initialize parent_dir_pn
      @dir_pathname = parent_dir_pn.join FILE_STEM__
      @pathname = @dir_pathname.sub_ext ::Skylab::Autoloader::EXTNAME
      const_set :FUN, ::Skylab::Subsystem::FUN ; nil
    end

    FILE_STEM__ = 'library-'.freeze

    attr_reader :pathname

    def kick * i_a  # #kicker - load the thing if not loaded
      i_a.each { |i| const_defined?( i, false ) or const_missing( i ) }
      nil
    end
  end
end
