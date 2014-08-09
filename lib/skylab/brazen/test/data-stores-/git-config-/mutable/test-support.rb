require_relative '../test-support'

module Skylab::Brazen::TestSupport::Data_Stores_::Git_Config::Mutable_Sections

  ::Skylab::Brazen::TestSupport::Data_Stores_::Git_Config[ TS_ = self ]

  include CONSTANTS

  extend TestSupport_::Quickie

  Brazen_ = Brazen_
  EMPTY_S_ = EMPTY_S_

  module ModuleMethods

    def with_empty_document
      define_method :__build_document__ do
        subject.parse_string EMPTY_S_
      end ; nil
    end
  end

  module InstanceMethods

    def document
      @document ||= __build_document__
    end

    def subject
      Brazen_::Data_Stores_::Git_Config::Mutable
    end

    def super_subject
      Brazen_::Data_Stores_::Git_Config
    end

    # ~ expectations

    def expect_document_content expected_string
      _actual_string = @document.unparse
      _actual_string.should eql expected_string
    end
  end
end
