module Skylab::Brazen::TestSupport

  module Collection_Adapters::Git_Config::Mutable

    class << self
      def [] tcc

        TS_.lib_( :collection_adapters_git_config )[ tcc ]

        tcc.extend Module_Methods___
        tcc.include Instance_Methods___
        NIL_
      end
    end  # >>

    # <-

  module Module_Methods___

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
        doc = subject.parse_string s do self._NEVER end
        document_p = -> { doc } ; doc
      end
      define_method :__build_document__ do
        document_p[].dup_via_parse_context parse_context
      end ; nil
    end

    def subject
      Home_::Collection_Adapters::Git_Config::Mutable  # repeat
    end
  end

  module Instance_Methods___

    def document
      @document ||= __build_document__
    end

    def parse_context
      @parse_context ||= bld_parse_context
    end

    def bld_parse_context
      @ev_a = nil
      subject::Pass_Thru_Parse__.new_with :on_event_selectively, -> *, & ev_p do
        ev = ev_p[]
        if do_debug
          debug_IO.puts ev.description
        end
        ( @ev_a ||= [] ).push ev
        nil
      end
    end

    def touch_section subsect_s=nil, sect_s, & x_p
      document.sections.touch_section subsect_s, sect_s, & x_p
    end

    # ~ expectations

    def expect_document_content expected_string
      _actual_string = @document.unparse
      _actual_string.should eql expected_string
    end

    # ~ support

    def subject
      super_subject::Mutable
    end

    def super_subject
      Home_::Collection_Adapters::Git_Config
    end
  end
  # ->
  end
end

# Home_::Collection_Adapters::Git_Config::Mutable
