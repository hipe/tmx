require_relative '../test-support'

module Skylab::Headless::TestSupport::API::Iambics

  ::Skylab::Headless::TestSupport::API[ self ]

  include CONSTANTS

  EMPTY_A_ = Headless::EMPTY_A_ ; Headless = Headless

  extend TestSupport::Quickie

  DSL_method_name = :DSL_writer_method_name

  DSL = -> do
    Headless::API::Iambic_parameters_DSL
  end

end
