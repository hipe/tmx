require_relative '../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] digraph" do

    it "here have an empty one" do
      digraph = Home_::Digraph.new
      expect( digraph.node_count ).to eql( 0 )
    end

    it "here have one with one node" do
      digraph = Home_::Digraph[ :solo ]
      expect( digraph.node_count ).to eql( 1 )
      node = digraph.fetch :solo
      expect( node.normalized_local_node_name ).to eql( :solo )
    end

    it "here have the minimal graph" do
      digraph = Home_::Digraph[ child: :parent ]
      expect( digraph.node_count ).to eql( 2 )
      expect( digraph.fetch( :child ).normalized_local_node_name ).to eql( :child )
      expect( digraph.fetch( :parent ).normalized_local_node_name ).to eql( :parent )
      expect( digraph.fetch( :child ).direct_association_targets_include( :parent ) ).to eql( true )
      expect( digraph.fetch( :child ).direct_association_targets_include( :foo ) ).to eql( false )
    end

    it "hay your nodes can point to multiple parents" do
      d = Home_::Digraph[ :fing, bing: :bong, bing_2: :bong,
                                     sing: [:song], wing: [:wrong, :dong] ]
      expect( d.node_count ).to eql( 9 )  # it didn't somehow double on on 'bong'
      expect( d.fetch( :fing ).direct_association_target_names ).to eql( nil )
      expect( d.fetch( :bing ).direct_association_target_names ).to eql( [:bong] )
      expect( d.fetch( :bing_2 ).direct_association_target_names ).to eql( [:bong] )
      expect( d.fetch( :sing ).direct_association_target_names ).to eql( [:song] )
      expect( d.fetch( :wing ).direct_association_target_names ).to eql( [:wrong, :dong] )
    end

    plant = -> do
      d = Home_::Digraph[ :plant, flower: :plant, bedillia: :flower ]
      plant = -> { d }
      d
    end

    context "there are box-like accessors you can use:" do

      it "did you know that you can use `has?`" do
        d = Home_::Digraph[ :mineral, dog: :animal ]
        expect( (d.has?( :mineral ) && d.has?( :dog ) && d.has?( :animal )) ).to eql( true )
        expect( d.has?( :aardvark ) ).to eql( false )
      end


      it "you can use `names` (is there even a flower called a `bedillia`?)" do
        d = plant[]
        names = d.names
        expect( names ).to eql([:plant, :flower, :bedillia])
        expect( (d.names.object_id == names.object_id) ).to eql( false )
      end

      it "you can use `fetch` to fetch by name" do
        d = plant[]
        got = d.fetch :flower
        expect( got.normalized_local_node_name ).to eql( :flower )
        dont = d.fetch :animal do end
        expect( dont ).to be_nil
      end
    end

    big_one = -> do
      d = Home_::Digraph[ animal: :thing, penguin: :animal,
        mineral: :thing, tux: [ :penguin, :icon ], my_tux_sticker: :tux,
        icon: :symbol ]
      big_one = -> { d }
      d
    end

    context 'walk_pre_order' do
      it 'walk_pre_order min depth 1 - gets you all ancestors excluding self' do
        digraph = big_one[ ]
        expect( digraph.walk_pre_order( :my_tux_sticker, 1 ).to_a ).to eql( [ :tux, :penguin, :animal, :thing, :icon, :symbol ] )
      end
    end

    context 'duping a graph -' do
      it 'makes a deep copy of the whole graph' do
        d1 = Home_::Digraph[ :alpha, beta: :gamma, delta: [ :epsilon, :chi] ]
        d2 = d1.dupe
        expect( d2.node_count ).to eql( 6 )
        expect( d2.fetch( :beta ).normalized_local_node_name ).to eql( :beta )
        expect( (d2.fetch( :gamma ).object_id == d1.fetch( :gamma ).object_id) ).to eql( false )
        expect( d2.fetch( :delta ).direct_association_target_names ).to eql([:epsilon, :chi])
      end
    end

    context 'clearing a graph - ' do
      it 'flatly removes the nodes from the graph' do
        d = Home_::Digraph[ :one ]
        expect( d.names ).to eql( [ :one ] )
        expect( d.node_count ).to eql( 1 )
        expect( d.clear ).to eql( nil )  # returns nothing
        expect( d.node_count ).to eql( 0 )
        expect( d.names ).to eql( [] )
      end
    end

    context 'describing a graph - ' do
      it 'works (and looks a little like ..)' do
        d = plant[ ]
        _exp = <<-HERE.unindent.chop
          flower -> plant
          bedillia -> flower
        HERE
        expect( d.describe_digraph( :with_spaces ) ).to eql _exp
      end
    end

    context 'node inspection - SYLLOGISMS' do
      it "nerk" do
        d = big_one[ ]
        t = d.fetch :tux
        expect( t.direct_association_targets_include( :penguin ) ).to eql( true )
        expect( t.direct_association_targets_include( :animal ) ).to eql( false )
        expect( d.indirect_association_targets_include( :tux, :tux ) ).to eql( false )
        expect( d.indirect_association_targets_include( :tux, :penguin ) ).to eql( false )
        expect( d.indirect_association_targets_include( :tux, :animal ) ).to eql(true)
        expect( d.indirect_association_targets_include( :tux, :symbol ) ).to eql(true)
        expect( d.indirect_association_targets_include( :tux, :mineral) ).to eql(false)
      end
    end

    context "THE DIFFERENCE ENGINE" do

      context "(you can distill graphs down to a flat list of associations)" do

        it "zero" do

          expect( _describe( :zero ) ).to eql '# (empty)'
        end

        it "one" do

          expect( _describe( :one ) ).to eql 'one'
        end

        it "b_a" do

          expect( _describe( :b_a ) ).to eql 'b->a'
        end

        it "f_m_l" do

          expect( _describe( :f_m_l ) ).to eql <<-O.unindent.chop
            f->a
            l->a
            m->l
            p->l
          O
        end

        it "orph" do

          expect( _describe( :orph ) ).to eql "c\nb->a"
        end

        def _describe sym

          send( sym ).describe_digraph
        end
      end

      context "you can invert a graph" do

        it "zero" do

          expect( _invert( :zero ) ).to eql '# (empty)'
        end

        it "one" do

          expect( _invert( :one ) ).to eql 'one'
        end

        it "b_a" do

          expect( _invert( :b_a ) ).to eql 'a->b'
        end

        it "f_m_l" do

          expect( _invert( :f_m_l ) ).to eql <<-O.unindent.chop
            a->f
            a->l
            l->m
            l->p
          O
        end

        it "orph" do
          expect( _invert( :orph ) ).to eql "c\na->b"
        end

        def _invert sym

          send( sym ).invert.describe_digraph
        end
      end

      define_singleton_method :digraph do | meth, arr |

        define_method meth, ( Common_.memoize do

          Home_::Digraph[ * arr ]
        end )
      end

      digraph :zero,  []
      digraph :one,   [ :one ]
      digraph :b_a,   [ b: :a ]
      digraph :f_m_l, [ f: :a, l: :a, m: :l, p: :l ]
      digraph :orph,  [ :c, b: :a ]
      digraph :real,  [row: :text, info: :text, empty: :info, row_count: :data ]

      # cb-digraph-viz brazen/core.rb [some moudule] --ope

      context "you can ACHIEVE SEMANTIC DIFFERENCE" do

        it "subtract one target and one inner - you are left with partial subset" do
          d2 = real.minus( [:info, :data, :strange] )
          expect( d2.node_count ).to eql( 2 )
          expect( d2.describe_digraph ).to eql 'row->text'
        end

        it "subtract the minimum covering set - you are left with none" do
          d2 = real.minus( [:text, :data] )
          expect( d2.node_count ).to eql( 0 )
        end

        it "just the two leaf nodes - the target node subset" do
          d2 = real.minus [ :empty, :row_count ]
          expect( d2.node_count ).to eql( 4 )
          expect( d2.describe_digraph.split( "\n" ).join( ' ' ) ).to eql "row->text info->text data"
        end
      end
    end
  end
end
