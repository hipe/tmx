module Skylab::Brazen::TestSupport

  module Collection_Adapters::Git_Config::Immutable

    class << self
      def [] tcc
        tcc.include self
        NIL_
      end
    end  # >>

    def want_no_sections_from str

      @document = subject_module_document_via_string_ str do
        TS_._OOPS
      end

      @document.sections.length.should be_zero
    end

    def a_section_parses
      with "[sectum]\n"
      want_config do |conf|
        conf.sections.length.should eql 1
        conf.sections.first.external_normal_name_symbol.should eql :sectum
      end
    end

    def a_section_and_a_comment_parses
      with <<-HERE.gsub! MARGIN_RX__, EMPTY_S_
        [scto]
         # commo
      HERE
      want_config do |conf|
        conf.sections.length.should eql 1
        conf.sections.first.external_normal_name_symbol.should eql :scto
      end
    end

    def some_comments_and_one_section_parses
      with <<-HERE.gsub! MARGIN_RX__, EMPTY_S_

        # it's time
        [scton]

           ; wazoozle
      HERE
      want_config do |conf|
        conf.sections.length.should eql 1
        conf.sections.first.external_normal_name_symbol.should eql :scton
      end
    end

    def the_subsection_name_parses
      with '[ -.secto-2014.08 "foo \\" \\\\ " ]'
      want_config do |conf|
        sect = conf.sections.first
        sect.internal_normal_name_string.should eql '-.secto-2014.08'
        sect.subsection_string == 'foo " \\ ' || fail
      end
    end

    def two_section_names_parse

      with <<-HERE.gsub! MARGIN_RX__, EMPTY_S_
        [ wiz "waz" ]
        [WiZ]
      HERE

      want_config do |conf|

        conf.sections.map { |x| x.external_normal_name_symbol }.should eql [ :wiz, :wiz ]
      end
    end

    def a_bare_word_not_in_a_section_fails

      with 'moby'

      chan_i_a = nil
      ev = nil

      _x = subject_module_document_via_string_ @input_string do |* i_a, & ev_p|
        chan_i_a = i_a
        ev = ev_p[]
        :_BR_NO_SEE_
      end

      _x == false || fail

      chan_i_a.should eql [ :error, :config_parse_error ]
      ev.parse_error_category_symbol.should eql :section_expected
      ev.lineno.should eql 1
      ev.column_number.should eql 1
      ev.line.should eql 'moby'
    end

    def a_simple_assignment_works
      with <<-HERE.gsub! MARGIN_RX__, EMPTY_S_
        [SECT]
        foo=bar
      HERE
      want_config do |conf|
        _sect = conf.sections.dereference :sect
        ast = _sect.assignments.first
        ast.internal_normal_name_string.should eql 'foo'
        ast.value.should eql 'bar'
      end
    end

    def a_variety_of_other_assignments_work

      with <<-HERE.gsub! MARGIN_RX__, EMPTY_S_
        [ secto ]
        foo-moMMy = tRuE
         ; against spec, the below is an int not a boolean
        int-not-bool =1
        multi-word = one two three
        multi-word-with-comment=   one two three   # a comment
        quotes-with-etc=  "so; you think you can \\"dance\\" ? "  ; huzzah
      HERE

      want_config do |conf|

        _assmts = conf.sections.dereference( :secto ).assignments
        o = _assmts.method :dereference  # LOOK

        o[ :foo_moMMy ].should eql true
        o[ :int_not_bool ].should eql 1
        o[ :multi_word ].should eql 'one two three'
        o[ :multi_word_with_comment ].should eql 'one two three'
        o[ :quotes_with_etc ].should eql 'so; you think you can "dance" ? '
      end
    end

    def with s
      @input_string = s ; nil
    end

    def want_config

      conf = subject_module_document_via_string_ @input_string do |*a, & p|
        debug_IO.puts "uh-oh (on #{ a.inspect })"
        _ev = p[]
        _e = _ev.to_exception
        raise _e
      end

      if conf
        if block_given?
          yield conf
        else
          conf
        end
      else
        fail "expected config to parse, did not."
      end
    end

    def subject_module_document_via_string_ s, & p

      subject_module_.parse_document_by do |o|
        o.upstream_string = s
        o.listener = p
      end
    end

    def subject_module_
      Home_::CollectionAdapters::GitConfig
    end

    MARGIN_RX__ = /^[ ]{8}/
  end
end
