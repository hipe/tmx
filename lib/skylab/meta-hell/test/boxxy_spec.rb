require_relative 'test-support'

module Skylab::MetaHell::TestSupport::Boxxy

  ::Skylab::MetaHell::TestSupport[ Boxxy_TestSupport = self ]

  include CONSTANTS

  MetaHell = ::Skylab::MetaHell  # increase its visibility for below modules

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

  describe "Skylab::MetaHell::Boxxy" do
    context "your boxxy module gets `const_fetch`. you can get the value of a const" do
      Sandbox_1 = Sandboxer.spawn
      before :all do
        Sandbox_1.with self
        module Sandbox_1
          module Adapters

            MetaHell::Boxxy[ self ]

            module Foo
            end

            module BarBaz
            end

            BONGO_TONGO = :fiz
          end
        end
      end
      it "stored with a simple, conventional name via a lowercase symbol" do
        Sandbox_1.with self
        module Sandbox_1
          Adapters.const_fetch( :foo ).should eql( Adapters::Foo )
        end
      end
      it "by passing it an array of (one) symbol name(s)" do
        Sandbox_1.with self
        module Sandbox_1
          Adapters.const_fetch( [ :foo ] ).should eql( Adapters::Foo )
        end
      end
      it "get a compound camel-case const via a `normalized`-looking symbol" do
        Sandbox_1.with self
        module Sandbox_1
          Adapters.const_fetch( :bar_baz ).should eql( Adapters::BarBaz )
        end
      end
      it "you can use dashes in the name" do
        Sandbox_1.with self
        module Sandbox_1
          Adapters.const_fetch( 'bar-baz' ).should eql( Adapters::BarBaz )
        end
      end
      it "or spaces" do
        Sandbox_1.with self
        module Sandbox_1
          Adapters.const_fetch( 'bar baz' ).should eql( Adapters::BarBaz )
        end
      end
      it "wow amazing, it still reolves the name even if it is in all caps" do
        Sandbox_1.with self
        module Sandbox_1
          Adapters.const_fetch( :'bongo-tongo' ).should eql( :fiz )
        end
      end
    end
    context "`FUN.fuzzy_const_get` is supposed to work on any module" do
      Sandbox_2 = Sandboxer.spawn
      it "here is one that has three layers of depth, and we use a whacky name" do
        Sandbox_2.with self
        module Sandbox_2
          module Foo
            module BarBaz
              module Biffo_Blammo
                WIZ_BANG = :wow
              end
            end
          end

          MetaHell::Boxxy::FUN.fuzzy_const_get[ Foo,
          [ :'bar-baz', 'bIFFO bLAMMO', :wiz_bang ] ].should eql( :wow )
        end
      end
    end
    context "`const_fetch` deep names, defaults, errors in a nested moudule" do
      Sandbox_3 = Sandboxer.spawn
      before :all do
        Sandbox_3.with self
        module Sandbox_3
          module Noodles

            MetaHell::Boxxy[ self ]

            module Ramen
              module Shin
                NAME = :ramyun
              end
            end
          end
        end
      end
      it "`const_fetch` with an array of names can fetch one such value" do
        Sandbox_3.with self
        module Sandbox_3
          Noodles.const_fetch( [ :ramen, :shin, :name ] ).should eql( :ramyun )
        end
      end
      it "`const_fetch` out of the box, when not found will raise a ::NameError" do
        Sandbox_3.with self
        module Sandbox_3
          -> do
            Noodles.const_fetch( :and_co )
          end.should raise_error( NameError,
                       ::Regexp.new( "\\Auninitialized\\ con" ) )
        end
      end
      it "`const_fetch` can honor a default provided in a block" do
        Sandbox_3.with self
        module Sandbox_3
          Noodles.const_fetch( :not_there ) { :derp }.should eql( :derp )
        end
      end
      it "`const_fetch` can honr a default provided in a proc" do
        Sandbox_3.with self
        module Sandbox_3
          Noodles.const_fetch( :no_wai, -> { :zerp } ).should eql( :zerp )
        end
      end
      it "`const_fetch` with both a proc and a block doesn't make sense" do
        Sandbox_3.with self
        module Sandbox_3
          -> do
            Noodles.const_fetch( :ramen, -> { } ) { }
          end.should raise_error( ArgumentError,
                       ::Regexp.new( "\\Atoo" ) )
        end
      end
      it "a `const_fetch` NameError has fun metadata" do
        Sandbox_3.with self
        module Sandbox_3
          name_error = Noodles.const_fetch( [ :ramen, :maru_chan ] ) { |x| x }
          name_error.const.should eql( :maru_chan )
          name_error.module.should eql( Noodles::Ramen )
        end
      end
    end
    context "`names` and `const_fetch_all` are 2 kinds of constituent fetchers" do
      Sandbox_4 = Sandboxer.spawn
      before :all do
        Sandbox_4.with self
        module Sandbox_4
          module Fazzlebert
            MetaHell::Boxxy[ self ]
            module WizBang
            end
            FROB_BOB = :no_see
          end
        end
      end
      it "`names` results in an enumerator of name functions" do
        Sandbox_4.with self
        module Sandbox_4
          Fazzlebert.names.map( & :as_slug ).should eql( [ 'wiz-bang', 'frob-bob' ] )
        end
      end
      it "use caution! the `names` are actually 1 flyweight you might need to dupe" do
        Sandbox_4.with self
        module Sandbox_4
          a = Fazzlebert.names.to_a
          a.length.should eql( 2 )
          a.first.object_id.should eql( a.last.object_id )
          a = Fazzlebert.names.map( & :dupe )
          a.length.should eql( 2 )
          a.first.as_natural.should eql( 'wiz bang' )
          a.last.as_natural.should eql( 'frob bob' )
        end
      end
      it "`const_fetch_all` fetches at once the values of a tuple that you specify" do
        Sandbox_4.with self
        module Sandbox_4
          wb, fb = Fazzlebert.const_fetch_all :wiz_bang, :frob_bob
          wb.should eql( Fazzlebert::WizBang )
          fb.should eql( Fazzlebert::FROB_BOB )
        end
      end
    end
    context "`optimistic constant inference` is something crazy your boxxy module does" do
      Sandbox_5 = Sandboxer.spawn
      it "`constants` demonstrating `optimisitic constant inference` in action" do
        Sandbox_5.with self
        module Sandbox_5
          Flowers = module MetaHell::TestSupport::Boxxy::Fixtures::Flowers
            self
          end

          Flowers.constants.length.should eql( 0 )

          module Flowers
            MetaHell::Boxxy[ self ]  # now it gets super-charged..
          end

          # ( NOTE - the 'flowers/' folder exists, has 'calla-lily.rb' )

          Flowers.constants.should eql( [ :Calla_Lily ] )

          Flowers.const_fetch( :Calla_Lily ).should eql( :in_bloom_again )

          Flowers.constants.should eql( [ :CALLA_LiLy ] )
        end
      end
    end
    context "`constants` caches the inferences derived form the filesystem once" do
      Sandbox_6 = Sandboxer.spawn
      it "but caches the ruby internal `constants` listing not at all." do
        Sandbox_6.with self
        module Sandbox_6
          Cafes = module MetaHell::TestSupport::Boxxy::Fixtures::Cafes
            Espresso_Royale_cafe = :erc
            MetaHell::Boxxy[ self ]  # there are 2 in the filesystem, too
            Espresso_bar = :eb
            self
          end

          Cafes.constants.should eql( [ :Espresso_Royale_cafe, :Espresso_bar, :Lab_Cafe ] )

          module Cafes
            Elixir_Vitae = :el
          end

          Cafes.constants.should eql( [ :Espresso_Royale_cafe, :Espresso_bar, :Elixir_Vitae, :Lab_Cafe ] )
        end
      end
    end
    context "boxxy is not recursive." do
      Sandbox_7 = Sandboxer.spawn
      it "a boxxy module does NOT make its loaded branch nodes themselves boxxy" do
        Sandbox_7.with self
        module Sandbox_7
          Mammals = module MetaHell::TestSupport::Boxxy::Fixtures::Mammals
            MetaHell::Boxxy[ self ]  # (there is a corresponding 'mammals/')
            self
          end

          Mammals::Bats.constants.length.should eql( 0 )
          Mammals::Bats::SomeBat.touch
          Mammals::Bats.constants.length.should eql( 1 )
        end
      end
    end
    context "your boxxy module gets `each` which loads all values while correcting" do
      Sandbox_8 = Sandboxer.spawn
      it "like so" do
        Sandbox_8.with self
        module Sandbox_8
          Spiders = module MetaHell::TestSupport::Boxxy::Fixtures::Spiders

            MetaHell::Boxxy[ self ]  # (there is a corresponding 'spiders/')

            Wolf = :wolf
            CAMEL = :camel

            self
          end

          a_i = [ ] ; a_x = [ ]
          Spiders.each do |i, x|
            a_i << i ; a_x << x
          end

          a_i.should eql( [ :Wolf, :CAMEL, :TaranTULA ] )
          a_x.should eql( [ :wolf, :camel, :nope ] )
        end
      end
    end
    context "`abbrev` is b.y.o implementation" do
      Sandbox_9 = Sandboxer.spawn
      it "like so" do
        Sandbox_9.with self
        module Sandbox_9
          module Foo
            MetaHell::Boxxy[ self ]
            abbrev f: :Foo, b: [ :Bar, :Baz]
          end

          Foo.abbrev_box.fetch( :f ).should eql( :Foo )
          Foo.abbrev_box.fetch( :b ).should eql( [ :Bar, :Baz ] )
        end
      end
    end
    context "change your inference naming scheme if you really need to, in `enhance`" do
      Sandbox_10 = Sandboxer.spawn
      it "like so" do
        Sandbox_10.with self
        module Sandbox_10
          module Cafes       # (here we rob the same filesystem fixtures
            @dir_pathname =  # for this, a different module)
              MetaHell::TestSupport::Boxxy::Fixtures::Cafes.dir_pathname
            MetaHell::Boxxy.enhance self do
              inferred_name_scheme :CamelCase
            end
          end

          Cafes.constants.should eql( [ :EspressoBar, :LabCafe ] )
        end
      end
    end
    context "`your_module.boxxy.dsl do .. end` - an experimental runtime DSL block" do
      Sandbox_11 = Sandboxer.spawn
      before :all do
        Sandbox_11.with self
        module Sandbox_11
          DSL_ = module Foo
            MetaHell::Boxxy[ self ]
            ZIP = :zap
            r = nil
            boxxy { r = self }
            r
          end
        end
      end
      it "`original_constants`" do
        Sandbox_11.with self
        module Sandbox_11
          DSL_.original_constants.should eql( [ :ZIP ] )
        end
      end
      it "`dir_pathname`" do
        Sandbox_11.with self
        module Sandbox_11
          ( !! DSL_.dir_pathname.to_s.match( %r{/foo\z} ) ).should eql( true )
        end
      end
      it "`pathify`" do
        Sandbox_11.with self
        module Sandbox_11
          DSL_.pathify( :'FooBar_' ).should eql( 'foo-bar-' )
        end
      end
      it "`extname`" do
        Sandbox_11.with self
        module Sandbox_11
          DSL_.extname.should eql( ::Skylab::Autoloader::EXTNAME )
        end
      end
      it "`upwards`" do
        Sandbox_11.with self
        module Sandbox_11
          DSL_.upwards( module Fiz ; self end )
          ( !! Fiz.dir_pathname.to_s.match( /fiz\z/ ) ).should eql( true )
        end
      end
      it "`get_const`" do
        Sandbox_11.with self
        module Sandbox_11
          DSL_.get_const( :ZIP ).should eql( :zap )

          module Zangief ; end
          -> do
            DSL_.get_const( :Zangief )
          end.should raise_error( NameError,
                       ::Regexp.new( "\\Auninitialized\\ consta" ) )
        end
      end
    end
    TestSupport::Coverage::Muncher.munch -> do
      MetaHell::Boxxy.dir_pathname.to_s
    end, '--cover', $stderr, ::ARGV
  end
end
