require_relative '../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] string - template" do

    TS_[ self ]
    use :the_method_called_let
    use :string

    it "loads" do
      subject
    end

    context "works as a simple templating thing" do

      it "interpolates strings {{ like_this }} - minimal case" do
        o = subject.via_string "foo {{ bar_baz }} bif"
        s = o.call bar_baz: 'bongo'
        expect( s ).to eql('foo bongo bif')
      end

      context "left diff -- params that are in template but not in actuals" do

        it "are left as-is (for now) in the output (!)" do
          o = subject.with :string, ' {{foo}} {{bar}} {{baz}} '
          str = o.call bar: 'biff'
          expect( str ).to eql(' {{foo}} biff {{baz}} ')
        end
      end

      context "right diff -- params that are in params but not in template" do

        it "do not trigger any errors" do
          o = subject.with :string, 'one{{two}}'
          str = o.call two: 'TWO', three: 'THREE'
          expect( str ).to eql('oneTWO')
        end
      end
    end

    context "reflects on the names found in the template" do

      let :template_string do
        "foo {{ bar_baz }} biff {{bongo}}"
      end

      it '`to_parameter_occurrence_stream`' do

        expect( subject.with( :string, template_string ).
          to_parameter_occurrence_stream.map_by( & :name_symbol ).to_a ).to eql(
            [ :bar_baz, :bongo ] )
      end

      it "with `formal_paramters`, offset data, surface representation too" do

        o = subject.with :string, template_string
        a = o.to_parameter_occurrence_stream.to_a

        expect( a.length ).to eql 2

        expect( a.first.surface_string ).to eql '{{ bar_baz }}'
        expect( a.first.name_symbol ).to eql :bar_baz
        expect( a.first.offset ).to eql 4

        expect( a.last.surface_string ).to eql '{{bongo}}'
        expect( a.last.name_symbol ).to eql :bongo
        expect( a.last.offset ).to eql 23
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

        _template = subject.with :string, _doc_s
        p = _template.method :first_margin_for

        expect( p[ :day ] ).to eql 'so the other '
        expect( p[ :wow ] ).to eql 'i was like '
        expect( p[ :that ] ).to be_nil
        expect( p[ :dork ] ).to eql EMPTY_S_
      end
    end

    def subject
      subject_module_::Template
    end
  end
end
