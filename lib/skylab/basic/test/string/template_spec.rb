require_relative 'test-support'

module Skylab::Basic::TestSupport::String

  describe "[ba] string template" do

    it "loads" do
      subject
    end

    context "works as a simple templating thing" do

      it "interpolates strings {{ like_this }} - minimal case" do
        o = subject.via_string "foo {{ bar_baz }} bif"
        s = o.call bar_baz: 'bongo'
        s.should eql('foo bongo bif')
      end

      context "left diff -- params that are in template but not in actuals" do

        it "are left as-is (for now) in the output (!)" do
          o = subject.new_with :string, ' {{foo}} {{bar}} {{baz}} '
          str = o.call bar: 'biff'
          str.should eql(' {{foo}} biff {{baz}} ')
        end
      end

      context "right diff -- params that are in params but not in template" do

        it "do not trigger any errors" do
          o = subject.new_with :string, 'one{{two}}'
          str = o.call two: 'TWO', three: 'THREE'
          str.should eql('oneTWO')
        end
      end
    end

    context "reflects on the names found in the template" do

      let :template_string do
        "foo {{ bar_baz }} biff {{bongo}}"
      end

      it '`to_formal_variable_stream`' do

        subject.new_with( :string, template_string ).
          to_formal_variable_stream.map_by( & :name_symbol ).to_a.should eql(
            [ :bar_baz, :bongo ] )
      end

      it "with `formal_paramters`, offset data, surface representation too" do

        o = subject.new_with :string, template_string
        a = o.to_formal_variable_stream.to_a

        a.length.should eql 2

        a.first.surface_s.should eql '{{ bar_baz }}'
        a.first.name_symbol.should eql :bar_baz
        a.first.offset.should eql 4

        a.last.surface_s.should eql '{{bongo}}'
        a.last.name_symbol.should eql :bongo
        a.last.offset.should eql 23
      end
    end

    context "margins" do

      it "ok" do
        _doc_s = <<-HERE.gsub %r(^[ ]{10}), EMPTY_S_
          so the other {{ day }}
          i was like {{ wow }} and {{ that }}
          wizzie wazie
          {{dork}}
        HERE

        _template = subject.new_with :string, _doc_s
        p = _template.method :first_margin_for

        p[ :day ].should eql 'so the other '
        p[ :wow ].should eql 'i was like '
        p[ :that ].should be_nil
        p[ :dork ].should eql EMPTY_S_
      end
    end

    def subject
      Basic_::String.template
    end
  end
end
