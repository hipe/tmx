load File.expand_path('../../../../../bin/bnf2treetop', __FILE__)
require_relative '../..'           # bootstrap in skylab.rb (after above!)
require 'skylab/test-support/core' # String#unindent
require 'skylab/headless/core'     # Headless::IO::Interceptors::Filter
