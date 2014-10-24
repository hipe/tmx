require_relative 'test-support'

module Skylab::Basic::TestSupport::String

  describe "[ba] string template" do

    it "loads" do
      subject
    end

    context "nifty function pasta for update_members'ing of structs" do

      s = "no members 'fling' or 'ding' in struct"
      it s do
        -> do
          subject.new pathname: 'foo', fling: 'bar', ding: 'x'
        end.should raise_error( ::NameError, s )
      end

      it "(as imabic)" do
        -> do
          subject.new :string, 'ok', :wazzup, 'no', :never, 'see'
        end.should raise_error( ::NameError, "no member 'wazzup' in struct" )
      end
    end

    context "works as a simple templating thing" do

      it "interpolates strings {{ like_this }} - minimal case" do
        o = subject.new string: "foo {{ bar_baz }} bif"
        s = o.call bar_baz: 'bongo'
        s.should eql('foo bongo bif')
      end

      context "left diff -- params that are in template but not in actuals" do

        it "are left as-is (for now) in the output (!)" do
          o = subject.new :string, ' {{foo}} {{bar}} {{baz}} '
          str = o.call bar: 'biff'
          str.should eql(' {{foo}} biff {{baz}} ')
        end
      end

      context "right diff -- params that are in params but not in template" do

        it "do not trigger any errors" do
          o = subject.new string: 'one{{two}}'
          str = o.call two: 'TWO', three: 'THREE'
          str.should eql('oneTWO')
        end
      end
    end

    context "reflects on the names found in the template" do

      let :template_string do
        "foo {{ bar_baz }} biff {{bongo}}"
      end

      it 'with `normalized_formal_paramter_names`' do
        o = subject.new :string, template_string
        a = o.normalized_formal_parameter_names
        a.should eql([:bar_baz, :bongo])
      end

      it "with `formal_paramters`, offset data, surface representation too" do
        o = subject.new string: template_string
        o = subject.new string: template_string
        a = o.get_formal_parameters.each.to_a
        a.length.should eql(2)
        a.first.surface.should eql('{{ bar_baz }}')
        a.first.local_normal_name.should eql(:bar_baz)
        a.first.offset.should eql(4)
        a.last.surface.should eql('{{bongo}}')
        a.last.local_normal_name.should eql(:bongo)
        a.last.offset.should eql(23)
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
        _template = subject.new :string, _doc_s
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
