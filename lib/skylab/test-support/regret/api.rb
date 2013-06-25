module Skylab::TestSupport::Regret::API

  API = self
  Face = ::Skylab::TestSupport::Services::Face
  Basic = Face::Services::Basic
  Headless = ::Skylab::Headless
  MetaHell = Face::MetaHell
  Face::API[ self ]
  EMPTY_A_ = [].freeze

  action_name_white_rx( /[a-z0-9]$/ )

  before_each_execution do Headless::CLI::PathTools.clear end

end
