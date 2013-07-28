require 'singleton' # [#048] - - singleton goes away

require_relative '..'
require 'skylab/face/core'
require 'skylab/porcelain/core'
require 'skylab/pub-sub/core'

module Skylab::Treemap
  [ :Autoloader,
    :Basic,
    :Headless,
    :MetaHell,
    :Porcelain,
    :PubSub,
    :Treemap
  ].each do |c|
    const_set c, ::Skylab.const_get( c, false )  # (it's more readable to
  end                             # have these subproduct consts in our sandbox)

  Bleeding = Porcelain::Bleeding  # and this might as well be its own subproduct
                                  # it is a legacy f.w that might go away

  MAARS = MetaHell::MAARS

  #         ~ tiny stowaway modules, too small for their own file ~
  #                          (in load order)

  module CLI
    MAARS[ self ]
    Adapter = Porcelain::Bleeding::Adapter  # "ouroboros" ([#hl-069])

    def self.new *a, &b
      CLI::Client.new( *a, &b )   # a conventional delegation. conform to the
    end                           # standard that CLI.new always works.
  end

  module Core
    MAARS[ self ]

    stowaway :Action, :Event, :SubClient  # (load s.c to find action, event)
  end

  module Plugins                  # #stowaway
    MetaHell::Boxxy.enhance self do  # for legacy reasons and grease ..
      inferred_name_scheme :CamelCase
    end
  end

  module API
    MAARS[ self ]
    module Actions
      MetaHell::Boxxy[ self ]
    end
  end

  IDENTITY_ = MetaHell::IDENTITY_
  WRITEMODE_ = Headless::WRITEMODE_

  MAARS[ self ]                   # we put it at the
                                  # bottom as proof that we don't use it here.
end
