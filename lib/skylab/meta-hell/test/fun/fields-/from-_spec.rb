require_relative 'test-support'

module Skylab::MetaHell::TestSupport::FUN::Fields_::From_

  ::Skylab::MetaHell::TestSupport::FUN::Fields_[ From__TestSupport = self ]

  include CONSTANTS

  MetaHell = ::Skylab::MetaHell

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

  describe "Skylab::MetaHell::FUN::Fields_::From_" do
    context "let a class define its fields via particular methods it defines" do
      Sandbox_1 = Sandboxer.spawn
      before :all do
        Sandbox_1.with self
        module Sandbox_1
          class Foo

            def one
            end

            MetaHell::FUN::Fields_::From_.methods do
              def two a
                @two_value = a.shift
              end
            end

            attr_reader :two_value

            def three
            end

            alias_method :initialize, :absorb
          end
        end
      end
      it "in a special DSL block" do
        Sandbox_1.with self
        module Sandbox_1
          Foo.new( :two, "foozle" ).two_value.should eql( 'foozle' )
        end
      end
      it "a subclass will inherit the same behavior and fieldset (by default)" do
        Sandbox_1.with self
        module Sandbox_1
          class Bar < Foo
          end

          Bar.new( :two, "fazzle" ).two_value.should eql( 'fazzle' )
        end
      end
      it "a subclasss can extend the fieldset (and it won't do the bad thing)" do
        Sandbox_1.with self
        module Sandbox_1
          class Baz < Foo

            MetaHell::FUN::Fields_::From_.methods do
              def four a
                @four_value = a.shift
              end
            end

            attr_reader :four_value
          end

          Baz.new( :four, "frick" ).four_value.should eql( 'frick' )
          -> do
            Foo.new( :four, "frick" )
          end.should raise_error( ArgumentError,
                       ::Regexp.new( "\\Aunrecognized\\ keyword\\ \"four\"\\ \\-\\ did\\ you\\ mean\\ two\\?\\z" ) )
        end
      end
    end
  end
end
