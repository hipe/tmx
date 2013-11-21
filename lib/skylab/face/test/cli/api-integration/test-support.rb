require_relative '../test-support'

module Skylab::Face::TestSupport::CLI::API_Integration

  ::Skylab::Face::TestSupport::CLI[ API_Integration_TestSupport = self ]

  module CONSTANTS

    Curriable_build_ = -> field_box, param_h do  # this used to there
      Face::CLI::API_Integration::OP_[
        :field_box, field_box,
        :param_h, param_h,
        :op, (( op = Face::Services::OptionParser.new )) ]
      op
    end

    CLI_expression_agent_ = -> do
      Face::CLI::API_Integration::EXPRESSION_AGENT_
    end
  end

  module InstanceMethods

    def client_class  # wide riggings here. #comport with above.
      application_module.const_get( :CLI, false ).const_get( :Client, false )
    end

    def rx rx
      (( line = @a.shift )) or fail "expecting line, had none (at #{ rx })"
      line.chomp!
      line.should match( rx )
      nil
    end

    def expect_no_more_lines
      @a.length.zero? or
        fail "expecing no more lines had #{ @a.fetch( 0 ).inspect }"
    end
  end
end
