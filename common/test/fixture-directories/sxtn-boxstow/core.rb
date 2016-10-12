module Skylab::Common::TestSupport

  module FixtureDirectories::SxtnBoxstow

    Autoloader_[ self, :boxxy ]

    stowaway :ShimmyJIMMY, 'shimmy-jimmy/chumba-wumba'

    # this module both is boxxy *and* registers a stowaway, a stowaway
    # that modifies how an item of the boxxy membership is to be loaded.

    # at writing if a stowaway is registered that is *not* among the
    # normally inferred boxxy membership (i.e a node that is not on the
    # filesystem *somehow*), it will *not* just magically become part of
    # the boxxy membership. such a feature has not yet been wanted.

    # rather, this scenario is meant to represent that classification of
    # scenarios where an item of a boxxy membership wishes to express
    # itself in a "main file" that is something other than an eponymous
    # file or core file.

  end
end
