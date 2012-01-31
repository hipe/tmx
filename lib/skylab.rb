require 'pathname'

module Skylab
  ROOT = Pathname.new(File.expand_path('../..', __FILE__))
    # warning: the sub-packages in this package should not pre-suppose that
    # they will always live under this package, hence any time you use this
    # constant from your sub-packages it will be volatile code.
    # (intented only to be used for testing, for finding e.g. a common tempdir.)
    #

  $:.include?(ROOT.join('lib')) or $:.unshift(ROOT.join('lib'))
end

