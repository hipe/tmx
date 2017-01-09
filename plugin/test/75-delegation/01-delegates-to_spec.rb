require_relative '../test-support'

module Skylab::Plugin::TestSupport

  lib_( :delegation ).use

  module Delegation_Namespace  # <-

  describe "[pl] delegation - the oldschool way" do

    it "'employ_the_DSL_method_called_delegates_to'" do

      class Client_Oldschool

        Subject_[ self, :employ_the_DSL_method_called_delegates_to ]

        delegates_to :morple, :downcase, :id2name

        def morple
          :MORPLE
        end
      end

      x = Client_Oldschool.new
      x.downcase.should eql :morple
      x.id2name.should eql 'MORPLE'
    end
  end
# ->
  end
end
