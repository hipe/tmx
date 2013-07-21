require_relative '..'

require 'skylab/headless/core'
require 'skylab/pub-sub/core'

module ::Skylab::CodeMolester

  %i| CodeMolester Headless MetaHell PubSub |.each do |i|
    const_set i, ::Skylab.const_get( i, false )
  end

  ::Skylab::Subsystem[ self ]

end
