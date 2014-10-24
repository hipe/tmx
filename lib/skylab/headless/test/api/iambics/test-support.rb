require_relative '../test-support'

module Skylab::Headless::TestSupport::API::Iambics

  ::Skylab::Headless::TestSupport::API[ self ]

  include Constants

  extend TestSupport_::Quickie

  EMPTY_A_ = Headless_::EMPTY_A_

  DSL_method_name = :DSL_writer_method_name

  DSL = -> do
    Headless_::API::Iambic_parameters_DSL
  end

  Headless_ = Headless_

end
