load ::File.expand_path( '../../../../../bin/tmx-bnf2treetop', __FILE__ )
require_relative '../..'
require 'skylab/test-support/core' # String#unindent
require 'skylab/headless/core'     # IO mappers filter

::Skylab::TestSupport::Quickie.enable_kernel_describe
