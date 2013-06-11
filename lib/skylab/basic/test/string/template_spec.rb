require_relative '../test-support'

module Skylab::Basic::TestSupport::String

  ::Skylab::Basic::TestSupport[ String_TestSupport = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  describe "#{ Basic::String::Template }" do

    context "nifty function pasta for update_members'ing of structs" do
      s = "no members 'fling' or 'ding' in struct"
      it s do
        -> do
          Basic::String::Template.new pathname: 'foo', fling: 'bar', ding: 'x'
        end.should raise_error( ::NameError, s )
      end
    end

    context "works as a simple templating thing" do

      it "interpolates strings {{ like_this }} - minimal case" do
        o = Basic::String::Template.new string: "foo {{ bar_baz }} bif"
        s = o.call bar_baz: 'bongo'
        s.should eql('foo bongo bif')
      end

      context "left diff -- params that are in template but not in actuals" do

        it "are left as-is (for now) in the output (!)" do
          o = Basic::String::Template.new string: ' {{foo}} {{bar}} {{baz}} '
          str = o.call bar: 'biff'
          str.should eql(' {{foo}} biff {{baz}} ')
        end

      end

      context "right diff -- params that are in params but not in template" do

        it "do not trigger any errors" do
          o = Basic::String::Template.new string: 'one{{two}}'
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
        o = Basic::String::Template.new string: template_string
        a = o.normalized_formal_parameter_names
        a.should eql([:bar_baz, :bongo])
      end

      it "with `formal_paramters`, offset data, surface representation too" do
        o = Basic::String::Template.new string: template_string
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
  end
end
