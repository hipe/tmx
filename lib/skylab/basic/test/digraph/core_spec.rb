require_relative 'test-support'

module Skylab::Basic::TestSupport::Digraph::Core

  ::Skylab::Basic::TestSupport::Digraph[ self ]

  include Constants

  extend TestSupport_::Quickie

  Callback_ = Callback_

  describe "[ba] digraph" do

    it "here have an empty one" do
      digraph = Basic_::Digraph.new
      digraph.node_count.should eql( 0 )
    end

    it "here have one with one node" do
      digraph = Basic_::Digraph[ :solo ]
      digraph.node_count.should eql( 1 )
      node = digraph.fetch :solo
      node.normalized_local_node_name.should eql( :solo )
    end

    it "here have the minimal graph" do
      digraph = Basic_::Digraph[ child: :parent ]
      digraph.node_count.should eql( 2 )
      digraph.fetch( :child ).normalized_local_node_name.should eql( :child )
      digraph.fetch( :parent ).normalized_local_node_name.should eql( :parent )
      digraph.fetch( :child ).direct_association_targets_include( :parent ).
        should eql( true )
      digraph.fetch( :child ).direct_association_targets_include( :foo ).
        should eql( false )
    end

    it "hay your nodes can point to multiple parents" do
      d = Basic_::Digraph[ :fing, bing: :bong, bing_2: :bong,
                                     sing: [:song], wing: [:wrong, :dong] ]
      d.node_count.should eql( 9 )  # it didn't somehow double on on 'bong'
      d.fetch( :fing ).direct_association_target_names.should eql( nil )
      d.fetch( :bing ).direct_association_target_names.should eql( [:bong] )
      d.fetch( :bing_2 ).direct_association_target_names.should eql( [:bong] )
      d.fetch( :sing ).direct_association_target_names.should eql( [:song] )
      d.fetch( :wing ).direct_association_target_names.should eql( [:wrong, :dong] )
    end

    plant = -> do
      d = Basic_::Digraph[ :plant, flower: :plant, bedillia: :flower ]
      plant = -> { d }
      d
    end

    context "there are box-like accessors you can use:" do

      it "did you know that you can use `has?`" do
        d = Basic_::Digraph[ :mineral, dog: :animal ]
        (d.has?( :mineral ) && d.has?( :dog ) && d.has?( :animal )).should(
          eql( true ) )
        d.has?( :aardvark ).should eql( false )
      end


      it "you can use `names` (is there even a flower called a `bedillia`?)" do
        d = plant[]
        names = d.names
        names.should eql([:plant, :flower, :bedillia])
        (d.names.object_id == names.object_id).should eql( false )
      end

      it "you can use `fetch` to fetch by name" do
        d = plant[]
        got = d.fetch :flower
        got.normalized_local_node_name.should eql( :flower )
        dont = d.fetch :animal do end
        dont.should be_nil
      end
    end

    big_one = -> do
      d = Basic_::Digraph[ animal: :thing, penguin: :animal,
        mineral: :thing, tux: [ :penguin, :icon ], my_tux_sticker: :tux,
        icon: :symbol ]
      big_one = -> { d }
      d
    end

    context 'walk_pre_order' do
      it 'walk_pre_order min depth 1 - gets you all ancestors excluding self' do
        digraph = big_one[ ]
        digraph.walk_pre_order( :my_tux_sticker, 1 ).to_a.
          should( eql( [ :tux, :penguin, :animal, :thing, :icon, :symbol ] ) )
      end
    end

    context 'duping a graph -' do
      it 'makes a deep copy of the whole graph' do
        d1 = Basic_::Digraph[ :alpha, beta: :gamma, delta: [ :epsilon, :chi] ]
        d2 = d1.dupe
        d2.node_count.should eql( 6 )
        d2.fetch( :beta ).normalized_local_node_name.should eql( :beta )
        (d2.fetch( :gamma ).object_id == d1.fetch( :gamma ).object_id).
         should eql( false )
        d2.fetch( :delta ).direct_association_target_names.should eql([:epsilon, :chi])
      end
    end

    context 'clearing a graph - ' do
      it 'flatly removes the nodes from the graph' do
        d = Basic_::Digraph[ :one ]
        d.names.should eql( [ :one ] )
        d.node_count.should eql( 1 )
        d.clear.should eql( nil )  # returns nothing
        d.node_count.should eql( 0 )
        d.names.should eql( [] )
      end
    end

    context 'describing a graph - ' do
      it 'works (and looks a little like ..)' do
        d = plant[ ]
        _exp = <<-HERE.unindent.chop
          flower -> plant
          bedillia -> flower
        HERE
        d.describe_digraph( :with_spaces ).should eql _exp
      end
    end

    context 'node inspection - SYLLOGISMS' do
      it "nerk" do
        d = big_one[ ]
        t = d.fetch :tux
        t.direct_association_targets_include( :penguin ).should eql( true )
        t.direct_association_targets_include( :animal ).should eql( false )
        d.indirect_association_targets_include( :tux, :tux ).should eql( false )
        d.indirect_association_targets_include( :tux, :penguin ).
          should eql( false )
        d.indirect_association_targets_include( :tux, :animal ).should eql(true)
        d.indirect_association_targets_include( :tux, :symbol ).should eql(true)
        d.indirect_association_targets_include( :tux, :mineral).should eql(false)
      end
    end

    context "THE DIFFERENCE ENGINE" do

      context "(you can distill graphs down to a flat list of associations)" do

        it "zero" do

          _describe( :zero ).should eql '# (empty)'
        end

        it "one" do

          _describe( :one ).should eql 'one'
        end

        it "b_a" do

          _describe( :b_a ).should eql 'b->a'
        end

        it "f_m_l" do

          _describe( :f_m_l ).should eql <<-O.unindent.chop
            f->a
            l->a
            m->l
            p->l
          O
        end

        it "orph" do

          _describe( :orph ).should eql "c\nb->a"
        end

        def _describe sym

          send( sym ).describe_digraph
        end
      end

      context "you can invert a graph" do

        it "zero" do

          _invert( :zero ).should eql '# (empty)'
        end

        it "one" do

          _invert( :one ).should eql 'one'
        end

        it "b_a" do

          _invert( :b_a ).should eql 'a->b'
        end

        it "f_m_l" do

          _invert( :f_m_l ).should eql <<-O.unindent.chop
            a->f
            a->l
            l->m
            l->p
          O
        end

        it "orph" do
          _invert( :orph ).should eql "c\na->b"
        end

        def _invert sym

          send( sym ).invert.describe_digraph
        end
      end

      define_singleton_method :digraph do | meth, arr |

        define_method meth, ( Callback_.memoize do

          Basic_::Digraph[ * arr ]
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
          d2.node_count.should eql( 2 )
          d2.describe_digraph.should eql 'row->text'
        end

        it "subtract the minimum covering set - you are left with none" do
          d2 = real.minus( [:text, :data] )
          d2.node_count.should eql( 0 )
        end

        it "just the two leaf nodes - the target node subset" do
          d2 = real.minus [ :empty, :row_count ]
          d2.node_count.should eql( 4 )
          d2.describe_digraph.split( "\n" ).join( ' ' ).
            should eql "row->text info->text data"
        end
      end
    end
  end
end
