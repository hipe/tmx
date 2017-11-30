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

      expect( @document.sections.length ).to be_zero
    end

    def a_section_parses
      with "[sectum]\n"
      want_config do |conf|
        expect( conf.sections.length ).to eql 1
        expect( conf.sections.first.external_normal_name_symbol ).to eql :sectum
      end
    end

    def a_section_and_a_comment_parses
      with <<-HERE.gsub! MARGIN_RX__, EMPTY_S_
        [scto]
         # commo
      HERE
      want_config do |conf|
        expect( conf.sections.length ).to eql 1
        expect( conf.sections.first.external_normal_name_symbol ).to eql :scto
      end
    end

    def some_comments_and_one_section_parses
      with <<-HERE.gsub! MARGIN_RX__, EMPTY_S_

        # it's time
        [scton]

           ; wazoozle
      HERE
      want_config do |conf|
        expect( conf.sections.length ).to eql 1
        expect( conf.sections.first.external_normal_name_symbol ).to eql :scton
      end
    end

    def the_subsection_name_parses
      with '[ -.secto-2014.08 "foo \\" \\\\ " ]'
      want_config do |conf|
        sect = conf.sections.first
        expect( sect.internal_normal_name_string ).to eql '-.secto-2014.08'
        sect.subsection_string == 'foo " \\ ' || fail
      end
    end

    def two_section_names_parse

      with <<-HERE.gsub! MARGIN_RX__, EMPTY_S_
        [ wiz "waz" ]
        [WiZ]
      HERE

      want_config do |conf|

        expect( conf.sections.map { |x| x.external_normal_name_symbol } ).to eql [ :wiz, :wiz ]
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

      expect( chan_i_a ).to eql [ :error, :config_parse_error ]
      expect( ev.parse_error_category_symbol ).to eql :section_expected
      expect( ev.lineno ).to eql 1
      expect( ev.column_number ).to eql 1
      expect( ev.line ).to eql 'moby'
    end

    def a_simple_assignment_works
      with <<-HERE.gsub! MARGIN_RX__, EMPTY_S_
        [SECT]
        foo=bar
      HERE
      want_config do |conf|
        _sect = conf.sections.dereference :sect
        ast = _sect.assignments.first
        expect( ast.internal_normal_name_string ).to eql 'foo'
        expect( ast.value ).to eql 'bar'
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

        expect( o[ :foo_moMMy ] ).to eql true
        expect( o[ :int_not_bool ] ).to eql 1
        expect( o[ :multi_word ] ).to eql 'one two three'
        expect( o[ :multi_word_with_comment ] ).to eql 'one two three'
        expect( o[ :quotes_with_etc ] ).to eql 'so; you think you can "dance" ? '
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
