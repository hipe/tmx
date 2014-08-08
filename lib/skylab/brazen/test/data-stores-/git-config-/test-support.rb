require_relative '../../test-support'

module Skylab::Brazen::TestSupport::Data_Stores_

  ::Skylab::Brazen::TestSupport[ self ]

end

module Skylab::Brazen::TestSupport::Data_Stores_::Git_Config

  ::Skylab::Brazen::TestSupport::Data_Stores_[ TS_ = self ]

  include CONSTANTS

  extend TestSupport_::Quickie

  EMPTY_S_ = EMPTY_S_

  module InstanceMethods

    def expect_no_sections_from str
      @document = subject.parse_string str
      @document.sections.length.should be_zero
    end

    def some_comments_and_one_section_parses
      with <<-HERE.gsub! MARGIN_RX__, EMPTY_S_

        # it's time
        [scton]

           ; wazoozle
      HERE
      expect_config do |conf|
        conf.sections.length.should eql 1
        conf.sections.first.normalized_name_i.should eql :scton
      end
    end

    def the_subsection_name_parses
      with '[ -.secto-2014.08 "foo \\" \\\\ " ]'
      expect_config do |conf|
        sect = conf.sections.first
        sect.name_s.should eql '-.secto-2014.08'
        sect.subsect_name_s.should eql 'foo " \\ '
      end
    end

    def two_section_names_parse
      with <<-HERE.gsub! MARGIN_RX__, EMPTY_S_
        [ wiz "waz" ]
        [WiZ]
      HERE
      expect_config do |conf|
        conf.sections.map { |x| x.normalized_name_i }.should eql [ :wiz, :wiz ]
      end
    end

    def a_bare_word_not_in_a_section_fails
      with 'moby'
      ev = subject.parse_string @input_string do |x| x end  # IDENTITY_
      ev.terminal_channel_i.should eql :section_expected
      ev.line_number.should eql 1
      ev.column_number.should eql 1
      ev.line.should eql 'moby'
    end

    def a_simple_assignment_works
      with <<-HERE.gsub! MARGIN_RX__, EMPTY_S_
        [SECT]
        foo=bar
      HERE
      expect_config do |conf|
        ast = conf.sections[ :sect ].assignments.first
        ast.name_s.should eql 'foo'
        ast.value_x.should eql 'bar'
      end
    end

    def a_variety_of_other_assignments_work
      with <<-HERE.gsub! MARGIN_RX__, EMPTY_S_
        [ secto ]
        foo-moMMy = tRuE
         ; against spec, the below is an in not a boolean
        int-not-bool =1
        multi-word = one two three
        multi-word-with-comment=   one two three   # a comment
        quotes-with-etc=  "so; you think you can \\"dance\\" ? "  ; huzzah
      HERE
      expect_config do |conf|
        o = conf.sections[ :secto ].assignments
        o[ :'foo-mommy' ].should eql true
        o[ :'int-not-bool' ].should eql 1
        o[ :'multi-word' ].should eql 'one two three'
        o[ :'multi-word-with-comment' ].should eql 'one two three'
        o[ :'quotes-with-etc' ].should eql 'so; you think you can "dance" ? '
      end
    end

    def with s
      @input_string = s ; nil
    end

    def expect_config & p
      conf = subject.parse_string @input_string
      if conf
        block_given? ? yield( conf ) : conf
      else
        fail "expected config to parse, did not."
      end
    end

    MARGIN_RX__ = /^[ ]{8}/

  end
end
