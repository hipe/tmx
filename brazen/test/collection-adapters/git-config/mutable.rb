module Skylab::Brazen::TestSupport

  module Collection_Adapters::Git_Config::Mutable

    class << self

      def [] tcc

        Collection_Adapters::Git_Config::Immutable[ tcc ]

        tcc.extend Module_Methods___
        tcc.include Instance_Methods___
        NIL
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

      yes = true ; doc_proto = nil
      once = -> do

        yes = false ; once = nil

        doc_proto = Subject__[].parse_document_by do |o|
          o.upstream_string = s
        end

        NIL
      end

      define_method :__build_document_ do

        # HACKISLY don't re-parse the same content over and over again..

        yes && once[]

        _doc_ = doc_proto.DUPLICATE_DEEPLY_AS_MUTABLE_DOCUMENT_

        _doc_  # hi. #todo
      end

      NIL_
    end
  end

  module Instance_Methods___

    def document
      @document ||= __build_document_
    end

    def touch_section subsect_s=nil, sect_s, & x_p
      document.sections.touch_section subsect_s, sect_s, & x_p
    end

    # ~ expectations

    def expect_document_content expected_string
      _actual_string = __document_content
      _actual_string.should eql expected_string
    end

    def expect_these_lines_in_array_with_trailing_newlines_ act_s_a, & p

      TestSupport_::Expect_Line::
        Expect_these_lines_in_array_with_trailing_newlines[ act_s_a, p, self ]

      NIL
    end

    def __document_content
      @document.unparse
    end

    def document_to_lines_
      @document.unparse_into []
    end

    def expect_one_event_ sym
      em = expect_event
      ev = em.cached_event_value.to_event
      ev.terminal_channel_symbol.should eql sym
      if block_given?
        yield ev
      end
      em
    end

    # ~ setup

    def will_call_by_
      p = expect_emission_fail_early_listener
      call_by do
        yield p
      end
      NIL
    end

    def subject_module_
      Subject__[]
    end
  end
  # ->

    # ==

    Subject__ = -> do
      Home_::CollectionAdapters::GitConfig::Mutable
    end

    Super_subject__ = -> do
      Home_::CollectionAdapters::GitConfig
    end

    # ==
    # ==
  end
end
