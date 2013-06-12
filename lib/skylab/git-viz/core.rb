# assuming operating under tmx for now. skipping canonical entrypoint setup.

module Skylab::GitViz

  %i| GitViz MetaHell Porcelain |.each do |i|
    const_set i, ::Skylab.const_get( i, false )
  end

  extend MetaHell::MAARS

  stowaway :API, 'api/client'

  module CLI
    extend MetaHell::MAARS
  end

  module Core
  end

  module Core::Client_IM_
  private
    def camelize s
      s.to_s.gsub(/(?:^|-)([a-z])/) { $1.upcase }
    end
  end
end
