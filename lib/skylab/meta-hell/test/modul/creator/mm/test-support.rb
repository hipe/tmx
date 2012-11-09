require_relative '../test-support'

module ::Skylab::MetaHell::TestSupport::Modul::Creator::ModuleMethods
  ::Skylab::MetaHell::TestSupport::Modul::Creator[ self ]

  MM_TestSupport = self

  MetaHell = MetaHell # #nec
  Modul = MetaHell::Modul # #nec
end
