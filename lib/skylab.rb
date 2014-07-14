module Skylab

  require 'pathname'

  here = ::Pathname.new __FILE__

  DOT_DOT_ = '..'.freeze

  $:.include?( _ = here.join( DOT_DOT_ ).to_path ) or $:.unshift _

  EMPTY_S_ = ''.freeze

  dir_pathname = here.sub_ext EMPTY_S_

  define_singleton_method :dir_pathname do dir_pathname end

end
