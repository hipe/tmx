require_relative 'creator/test-support'

module ::Skylab::MetaHell::TestSupport::Klass::Creator
  describe "say, did you know: #{MetaHell::Klass::Creator}" do
    extend Creator_TestSupport

    context "lets you define a minimal class with \"klass\" which" do
      snip do
        klass :Feeple do
          def darymple ; end
        end
      end
      it "gives you klass accessor, object accessor, persistent, to_s hack" do
        klass = o.klass
        klass.should be_kind_of(::Class)
        o.klass.object_id.should eql(klass.object_id) # klass is memoized

        # o.object is memozed. but klass and object behave as expected
        object = o.object
        object.should be_kind_of(klass)
        object2 = klass.new
        object2.object_id.should_not eql(object.object_id)
        object2.class.should eql(object.class)
        object.class.should eql(klass)
        o.object.object_id.should eql(object.object_id)

        klass.to_s.should eql('Feeple')
        object.class.to_s.should eql(klass.to_s)
      end
    end

    context "lets you use a klass 'delcaration' without a class body which" do
      snip do
        klass :Darymple
      end
      it "is fine, the same as defining one with an empty body" do
        o.klass.to_s.should eql('Darymple')
        o.klass.should be_kind_of(::Class)
      end
    end

    context "ridiculously gives you a DSL (\"extends:\") for #{
      }specifying the parent class" do

      context "but using any 'option' other than 'extends:'" do
        snip do
          klass :Fimple, existential: :Nerp
        end
        doing { o }
        borks 'invalid option "existential" (did you mean "extends"?)'
      end

      context "for which if you use a literal class constant" do
        snip do
          klass :MyEnumerator, extends: ::Enumerator do
            def initialize ; end # override parent
          end
        end
        it "the created class will subclass it" do
          o = self.o.object
          o.class.to_s.should eql('MyEnumerator')
          o.should be_kind_of(::Enumerator)
        end
      end

      context "for which if you try to subclass a non-class" do
        snip do
          klass :MyEnumerator, extends: ::Enumerable
        end
        doing { o.klass }
        borks "invalid 'extends:' value - expecting Class or Symbol, had Module"
      end
    end

    context "ridiculously lets you use symbolic names for parent class" do

      context "but if you use a randomass unresolvable name" do
        snip do
          klass :Darymple, extends: :FunTimes__Pollyp
          klass :FunTimes__Pimple
        end
        doing { o.Darymple }
        borks %r{:FunTimes__Pollyp is not in the definitions graph\. The def}
      end

      context "but with a symbolic name that *is* in the definition graph" do
        snip do
          klass :Darymple, extends: :FunTimes__Pimple
          klass :FunTimes__Pimple
        end
        it "works oh shit wat" do
          o = self.o.Darymple.new
          a = o.class.ancestors.map(&:to_s)
          a.should be_include('Darymple')
          a.should be_include('FunTimes::Pimple')
        end
      end
      context "watch what happens if you do A::B::C < A::B straight up" do
        snip do
          klass :A__B__C, extends: :A__B
        end
        doing { o.klass }
        borks "superclass must be a Class (Module given)"
      end
      context "but if you foward-declare the parent class it's ok" do
        snip do
          klass :A__B
          klass :A__B__C, extends: :A__B
        end
        doing { o.klass }
        it "ok" do
          subject.call.to_s.should eql('A::B::C')
        end
      end
    end

    context "with reopening classes" do
      context "what happens when you go [0, 1]" do
        snip do
          klass :Foo
          klass :Foo, extends: ::Enumerator
        end
        doing { o.klass }
        borks 'superklass mismatch for Foo (nothing then Enumerator)'
      end
      context "what happens when you go [1, 0]" do
        snip do
          klass :Foo, extends: ::Enumerator
          klass :Foo
        end
        it "ok, as in ruby" do
          o.klass.to_s.should eql('Foo')
          o.klass.ancestors.should be_include(::Enumerator)
        end
      end
      context "what happens when you go [A, B]" do
        snip do
          klass :Foo, extends: ::String
          klass :Foo, extends: ::Enumerator
        end
        doing { o.klass }
        borks 'superklass mismatch for Foo (String then Enumerator)'
      end
      context "what hppens when you go [A, A]" do
        snip do
          klass :Foo, extends: ::Enumerator
          klass :Foo, extends: ::Enumerator
        end
        it "works" do
          (o.klass.ancestors & [o.Foo, ::Enumerator]).length.should eql(2)
        end
      end
    end
  end
end
