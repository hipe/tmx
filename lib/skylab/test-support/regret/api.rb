module Skylab::TestSupport::Regret::API

  API = self
  Face = ::Skylab::TestSupport::Services::Face
  Headless = ::Skylab::Headless
  MetaHell = Face::MetaHell
  Face::API[ self ]

  action_name_white_rx( /[a-z0-9]$/ )

  before_each_execution do Headless::CLI::PathTools.clear end

end
