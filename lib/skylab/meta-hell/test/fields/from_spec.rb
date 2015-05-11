require_relative 'test-support'

module Skylab::MetaHell::TestSupport::Fields::From

  describe "[mh] Fields::From" do

    context "in this primordial ancestor of `entity`, define fields with methods" do

      before :all do

        class Foo

          def one
          end

          MetaHell_::Fields::From.methods(
            :overriding, :argful, :destructive, :globbing, :absorber, :initialize
          ) do

            def two a
              @two_value = a.shift
            end
          end

          attr_reader :two_value

          def three
          end
        end
      end

      it "the \"absorber\" you defined was globbing, and was `initialize` so" do

        Foo.new( :two, "foozle" ).two_value.should eql 'foozle'
      end

      it "a subclass will inherit the same behavior and fieldset (by default)" do

        class Bar < Foo
        end

        Bar.new( :two, "fazzle" ).two_value.should eql 'fazzle'
      end

      it "a subclasss can mutate its own fieldset without disturbing parent" do

        class Baz < Foo

          MetaHell_::Fields::From.methods :argful do
            def four a
              @four_value = a.shift
            end
          end

          attr_reader :four_value
        end

        Baz.new( :four, "frick" ).four_value.should eql 'frick'
        _rx = ::Regexp.new( "\\Aunrecognized\\ keyword\\ 'four'\\ \\-\\ did\\ you\\ mean\\ two\\?\\z" )
        -> do
          Foo.new( :four, "frick" )
        end.should raise_error( ArgumentError, _rx )
      end
    end

    context "use the experimental `use_o_DSL` to give yourself the 'o' method" do

      before :all do

        class Fob
          MetaHell_::Fields::From.methods :use_o_DSL do

            o :desc, "a", "b"
            o :desc, "c"
            def foo
            end

            o :desc, -> y { y << "ok." }
            def bar
            end
          end
        end
      end

      it "you can add desc strings in long lists or one at a time" do

        Fob::FIELDS_[:foo].desc_p[ a = [] ]
        a.should eql %w( a b c )
      end

      it "you can define desc strings by defining functions that will produce them" do

        Fob::FIELDS_[:bar].desc_p[ a = [] ]
        a.first.should eql "ok."
      end
    end
  end
end
