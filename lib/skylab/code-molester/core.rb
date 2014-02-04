require_relative '..'
require 'skylab/callback/core'
require 'skylab/headless/core'

module ::Skylab::CodeMolester

  %i| CodeMolester Headless MetaHell Callback |.each do |i|
    const_set i, ::Skylab.const_get( i, false )
  end

  ::Skylab::Subsystem[ self ]

end
