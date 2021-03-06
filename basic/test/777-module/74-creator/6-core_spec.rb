require_relative '../../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] module creator" do

    TS_[ self ]
    use :module_creator_define_klass, ( Mdl_Crtr_Cr__ = ::Module.new )

    context "defining a single module" do

      context "with no block" do

        define_klass_ do

          modul :Hello_1
        end

        it "works, is persistent, gives you a convenience accessor" do

          o = klass_.new
          expect( o.Hello_1 ).to be_kind_of ::Module
          expect( o.Hello_1.object_id ).to eql o.Hello_1.object_id
          expect( o._Hello_1 ).to eql o.Hello_1
        end
      end

      context "with a block" do

        define_klass_ do

          modul :Hello_2 do
            def fizzo
              :bizzo
            end
          end
        end

        it "works" do

          _o = klass_.new
          expect( _o.Hello_2.instance_methods ).to eql [ :fizzo ]
        end
      end
    end

    context "defining a nested module (1 level)" do

      context "with no block" do

        define_klass_ do
          modul :Mi__Familia
        end

        it "things are persistent everywhere" do

          o = klass_.new

          mod = o.Mi
          m1 = o.Mi__Familia
          m2 = mod::Familia
          m3 = o.Mi.const_get :Familia, false

          expect( [ m1, m2, m3 ].map( & :object_id ).uniq.length ).to eql 1

          expect( mod.object_id ).to eql o.Mi.object_id
        end

        it "lazy eval. vs. kicks" do

          o = klass_.new
          expect( o.Mi.constants.length ).to eql(1)
          o.Mi__Familia
          expect( o.Mi.constants.length ).to eql(1)
        end
      end
    end

    context "multi-statement kicking of children" do

      define_klass_ do
        modul :American__Family
        modul :American__Gothic
      end

      it "happens" do

        expect( klass_.new.American.constants.length ).to eql 2
      end
    end


    context "and holy crap what is this shit" do

      _COUNTER = 0

      define_klass_ do

        # (note this block is run multiple times, once for each test below)

        modul( :My__Pho )     { def zap ; end }

        modul( :My__BaMi )    { def zip ; end ; def zoop ; end }

        modul( :His__Pho )    { def glyph ; end }

        modul :My__BaMi do
          undef_method :zip
          def zip a
          end
          def zorp
          end
        end

        modul :My__Pho__Pas do
          def zangeif
          end
        end
      end

      it "per module appears to follow the order it was defined in" do

        o = klass_.new
        expect( o.My__BaMi.instance_methods ).to eql [ :zip, :zoop, :zorp ]
        expect( o.My__BaMi.instance_method( :zip ).parameters ).to eql [ [:req, :a ] ]
      end

      it "looks like it realizes the whole graph, but still lazily wtf!!" do

        o = klass_.new

        m = o.meta_hell_anchor_module

        expect( m.constants ).to eql EMPTY_A_

        o.My__Pho

        expect( m.object_id ).to eql o.meta_hell_anchor_module.object_id
        expect( m.constants ).to eql [ :My, :His ]

        _x = m.const_get( :My, false ).
          const_get( :Pho, false ).
            const_get( :Pas, false )

        expect( _x.instance_methods ).to eql [ :zangeif ]
      end
    end
  end
end
