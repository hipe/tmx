require_relative '../test-support'

module Skylab::Headless::TestSupport::Bundles::Delegating

  describe "[hl] bundle: delegating - the oldschool way" do

    it "'employ_the_DSL_method_called_delegates_to'" do

      class Client_Oldschool

        Home_::Delegating[ self, :employ_the_DSL_method_called_delegates_to ]

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
end
