require_relative 'test-support'

module Skylab::MetaHell::TestSupport::Boxxy

  # Quickie!

  describe "#{ MetaHell::Boxxy }" do

    extend MetaHell::TestSupport::Boxxy

    context "minimal case: one item" do
      modul :Boxxy__Zeep do
        @dir_pathname = false  # #todo all of this changed with the post
        # _Clean Code_ overhaul of boxxy, and [mh]::Module::Creator is
        # a hassle to boot [#034]
        MetaHell::Boxxy[ self ]
        module self::Foop
        end
      end

      context "gets an element that is there" do
        it "via a normalized path" do
          mod = _Boxxy__Zeep.const_fetch [:foop]
          mod.to_s.split('::').last.should eql('Foop')
        end
        it "via a const name string" do
          mod = _Boxxy__Zeep.const_fetch 'Foop'
          mod.to_s.split('::').last.should eql('Foop')
        end
      end

      context "with a name that is invalid" do
        it "raises a ::NameError with some metadata" do
          begin _Boxxy__Zeep.const_fetch 'with/a/slash'
          rescue ::NameError => e
          end
          e.const.should eql('with/a/slash')
          e.message.should eql(
            "uninitialized constant Boxxy::Zeep::( ~ with/a/slash )" )
        end
      end

      context "with a name that is valid but not found" do
        it "raises a ::NameError with lots of metadata" do
          begin
            _Boxxy__Zeep.const_fetch [:nerp, :derp]
          rescue ::NameError => e
          end
          e.message.should match( /uninitialized constant Boxxy::Zeep.+nerp/i )
          e.module.to_s.should eql('Boxxy::Zeep')
          e.const.should eql(:nerp)
          e.name.should eql(:nerp)
        end
      end

      context "custom error handling" do
        context "can be as a block (alla actual fetch)" do
          it "which catches not found errors" do
            yay = _Boxxy__Zeep.const_fetch(:nope) { :yep }
            yay.should eql(:yep)
          end
          it "which catches invalid name errors" do
            kk = _Boxxy__Zeep.const_fetch('invalid/name') do |e|
              "wahoo: #{ e.name }"
            end
            kk.should eql('wahoo: invalid/name')
            kk = _Boxxy__Zeep.const_fetch('invalid/name') { :yep }
            kk.should eql(:yep)
          end
        end
        context "can be as one lambda" do
          it "which catches not found errors" do
            s = _Boxxy__Zeep.const_fetch([:fliff], ->(e) { "ok: #{e.const}" } )
            s.should eql('ok: fliff')
          end
          it "which catches name errors" do
            s = _Boxxy__Zeep.const_fetch( 'a space',
              ->(e) { "ok: #{ e.name }" } )
            s.should eql('ok: a space')
          end
        end
        context "can be as one proc" do
          it "which will catch not found errors" do
            s = _Boxxy__Zeep.const_fetch 'x', -> e { 'a' }
            s.should eql( 'a' )
          end
        end
        it "cannot be as a lambda and a block" do
          -> do
            _Boxxy__Zeep.const_fetch('a', ->{ }) {  }
          end.should raise_error( ::IndexError, /outside of array bounds/ )
        end
      end
    end
  end
end
