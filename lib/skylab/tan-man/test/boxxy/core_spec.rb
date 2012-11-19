require_relative 'test-support'

module Skylab::MetaHell::TestSupport::Boxxy

  describe "#{ TanMan::Boxxy }" do
    extend MetaHell::TestSupport::Boxxy

    context "minimal case: one item" do
      modul :Boxxy__Zeep do   # Has to be under Boxxy only b/c our containing
        extend TanMan::Boxxy  # folder is called that, and we need
        module self::Foop     # _autoloader_init to work!.  (self necessary !)
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
          e.invalid_name.should eql('with/a/slash')
          e.message.should eql('wrong constant name with/a/slash')
        end
      end

      context "with a name that is valid but not found" do
        it "raises a ::NameError with lots of metadata" do
          begin _Boxxy__Zeep.const_fetch [:nerp, :derp]
          rescue ::NameError => e
          end
          e.message.should eql('unitialized constant Boxxy::Zeep::Nerp')
          e.module.to_s.should eql('Boxxy::Zeep')
          e.const.should eql(:Nerp)
          e.name.should eql(:nerp)
          e.seen.should eql([])
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
              "wahoo: #{e.invalid_name}"
            end
            kk.should eql('wahoo: invalid/name')
            kk = _Boxxy__Zeep.const_fetch('invalid/name') { :yep }
            kk.should eql(:yep)
          end
        end
        context "can be as one lambda" do
          it "which catches not found errors" do
            s = _Boxxy__Zeep.const_fetch([:fliff], ->(e) { "ok: #{e.const}" } )
            s.should eql('ok: Fliff')
          end
          it "which catches name errors" do
            s = _Boxxy__Zeep.const_fetch( 'a space',
              ->(e) { "ok: #{e.invalid_name}" } )
            s.should eql('ok: a space')
          end
        end
        context "can be as two lambdii" do
          it "which, the appropriate one will catch not found errors" do
            s = _Boxxy__Zeep.const_fetch( 'x', ->(e){'a'}, ->(e){'b'} )
            s.should eql('a')
          end
          it "which, the appropriate one will catch invalid name errors" do
            s = _Boxxy__Zeep.const_fetch( 'x x', ->(e){'a'}, ->(e){'b'} )
            s.should eql('b')
          end
        end
        it "cannot be as a lamba and a block" do
          -> do
            _Boxxy__Zeep.const_fetch('a', ->{ }) {  }
          end.should raise_exception( ::ArgumentError,
                                     "can't have both block and lambda args" )
        end
      end
    end
  end
end
