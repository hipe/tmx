require_relative '../test-support'

module Skylab::Brazen::TestSupport::Data_Stores_::Git_Config::Mutable_Sections

  ::Skylab::Brazen::TestSupport::Data_Stores_::Git_Config[ TS_ = self ]

  include CONSTANTS

  extend TestSupport_::Quickie

  Brazen_ = Brazen_
  EMPTY_S_ = EMPTY_S_

  module ModuleMethods

    def with_empty_document
      with_content EMPTY_S_
    end

    def with_a_document_with_a_section_called_foo
      with_content "[foo]\n"
    end

    def with_a_document_with_one_subsection_called_foo_bar
      with_content "[foo \"bar\"]\n"
    end

    def with_a_document_with_two_sections
      with_content "[beta]\n[delta]\n"
    end

    def with_a_document_with_one_section_with_one_assignment
      with_content "[foo]\nbar = baz\n"
    end

    def with_content s
      document_p = -> do
        doc = Subject__[].parse_string s
        document_p = -> { doc } ; doc
      end
      define_method :__build_document__ do
        document_p[].dup
      end ; nil
    end
  end

  Subject__ = -> do
    Brazen_::Data_Stores_::Git_Config::Mutable
  end

  module InstanceMethods

    def document
      @document ||= __build_document__
    end

    define_method :subject, Subject__

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
