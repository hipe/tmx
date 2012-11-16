require_relative '../test-support'

module ::Skylab::MetaHell::TestSupport::Klass::Creator::ModuleMethods
  (Parent_ = ::Skylab::MetaHell::TestSupport::Klass::Creator)[ self ]

  include Parent_::CONSTANTS

  MetaHell = MetaHell # #annoying

end
