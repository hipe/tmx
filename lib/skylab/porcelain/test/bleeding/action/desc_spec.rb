require_relative 'test-support'

module Skylab::Porcelain::TestSupport::Bleeding::Action # #po-008

  describe "[po][bl] action desc, an inheritable attribute" do

    extend Action_TestSupport

    incrementing_anchor_module!

    klass :Base do
      extend Bleeding::Action
    end

    let(:base) { send(:Base) }

    context "All classes that extend Action have a desc that by default" do
      let(:subject) { base.desc }
      specify { should eql([]) }
      it "have a consistent oid" do
        base.desc.object_id.should eql(base.desc.object_id)
      end
    end

    it "You can add a string of desc with the DSL, which will change #{
        }the object_id of the desc" do

      oid = base.desc.object_id
      base.desc 'foo'
      base.desc.should eql(['foo'])
      base.desc.object_id.should_not eql(oid)
    end

    it "You can mutate desc with the familiar array accessors #{
        }(won't change oid)" do

      base.desc 'foo'
      oid = base.desc.object_id
      base.desc.concat(['bar', 'baz'])
      base.desc.should eql(['foo', 'bar', 'baz'])
      base.desc.object_id.should eql(oid)
    end

    context "When you have a child class of a base class with a desc" do
      klass( :Child, extends: :Base ) ; let( :child ) { send(:Child) }
      before(:each) do
        base.desc 'foo', 'bar'
      end

      it "the desc of the child will start out as the same as that of the #{
          }base at that time" do
        child.desc.should eql(['foo', 'bar'])
      end

      it "but it is a different object, and won't pick up subsequent #{
          }changes in the base desc" do

        base.desc 'bazzo'
        coid = child.desc.object_id
        coid.should_not eql(base.desc.object_id)
        child.desc.should eql(['foo', 'bar', 'bazzo'])
        base.desc 'bizzo'
        child.desc.should eql(['foo', 'bar', 'bazzo'])
        child.desc.object_id.should eql(coid)
      end

      it "and most importantly, the partent desc won't pick up subequent #{
          }changes in the child" do

        child.desc 'bingo'
        child.desc.should eql(['foo', 'bar', 'bingo'])
        base.desc.should eql(['foo', 'bar'])
      end
    end

    Bleeding = Bleeding # #annoying

    context "(bugfix: be sure that flyweighting doesn't interfere)" do
      klass :CLI, extends: Bleeding::Runtime do
        def initialize rt
          self.parent = rt  # try trigger errors, it should be just @parent
        end
        module self::Actions ; end
        class self::Action
          extend Bleeding::Action
        end
        class self::Actions::Ferp < self::Action
          desc "wing"
        end
        class self::Actions::Derp < self::Action
          desc "ding"
        end
      end

      it "it should not have flyweighting fuck this whole thing up" do
        emit_spy = self.emit_spy
        app = self.CLI.new emit_spy
        app.invoke [ '-h' ]
        a = emit_spy.delete_emission_a
        styled = TestLib_::CLI[]::Pen::FUN.unstyle_styled
        line = -> { styled[ a.shift.payload_x ] }
        line[].should match( /ferp.+derp/ )  # usage line
        line[].should match( /^ *actions\b/i )
        line[].should match( /^ *ferp\b.+\bwing\b/ )
        line[].should match( /^ *derp\b.+\bding\b/ )
        line[].should match( /for help on a particular acti/)
        a.length.should eql( 0 )
      end
    end
  end
end
