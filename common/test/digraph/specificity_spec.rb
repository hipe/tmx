require_relative 'test-support'

module Skylab::Common::TestSupport::Digraph::Specificity

  ::Skylab::Common::TestSupport::Digraph[ Specificity_TestSupport = self ]

  include Constants

  extend TestSupport_::Quickie

  describe "[co] digraph specificity" do

    extend Specificity_TestSupport


    # Given the below event stream graph relating the three streams of
    # [B]usiness, [P]leasure and [H]acking where (not shown) the arrows
    # point up (hacking is business, hacking is pleasure),
    #
    #          B   P
    #           \ /
    #            H
    #
    # we go through all of the permutations of listening to one
    # or two of the streams (when we combine symmetrically equivalent
    # arrangements there are four of them, yeah?), and within each of
    # those listening arrangement we go through a variety of emitting
    # on streams (hopefully all significant permutations there).


    context "simple multi-inheritence triangle graph" do

      order = %i| h p b |.freeze  # hacking, pleasure, business
                                  # (and the above order is cosmetic only)
      length = order.length.freeze

      define_method :length do length end

      define_singleton_method :whence do |&blk|  # scope `length`
        memoized_frame = Home_.memoize do
          a = ::Array.new length
          z = blk[ a ]  # use `call` not `instance_eval` for sane arch.
          [ a, z ]
        end

        # NOTE each new text context (each test) within the scope of
        # the context that says `whence` will use the *SAME* `z` and `a`.
        # this is intentional to test for the absense of side-effects
        # *while* having the granularity of individual tests (errors were
        # unreadable before when it was chunked larger). to test two things
        # at once like this comes at a cost of proper unit testing practice
        # with the benefit of reduced codespace and compexity and improved
        # test simplicity..

        define_method :z do
          @a, z = memoized_frame[ ]
          define_singleton_method :z do z end
          z
        end
      end

      def does *a
        if a.length < length
          a[ length - 1 ] = nil
        end
        @a.should eql( a )
        @a.clear
        @a[ length - 1 ] = nil
        nil
      end

      def call_digraph_listeners stream_symbol
        z.call_digraph_listeners stream_symbol, true
      end

      touch = -> a, i, e do
        a[ order.index( i ) ] = ( e.is_event if e )
      end


      context "1. listening to only the non-taxonomic stream - works" do

      #        B   P
      #         \ /
      #         [H]

        whence do |a|
          z = Home_::TestSupport::Fixtures::ZigZag.new
          z.with_specificity do
            z.on_hacking do |e|
              touch[ a, :h, e ]
            end
          end
          z
        end

        it 'b1' do
          call_digraph_listeners :business
          does nil, nil
        end

        it 'p1' do
          call_digraph_listeners :pleasure
          does nil, nil
        end

        it 'h1' do
          call_digraph_listeners :hacking
          does true, nil
        end

        it 'p2' do
          call_digraph_listeners :pleasure
          does nil, nil
        end

        it 'h2' do
          call_digraph_listeners :hacking
          does true, nil
        end

        it 'h3' do
          call_digraph_listeners :hacking
          does true, nil
        end

      end

      context "2. listening to only a taxonomic stream - catches all" do

      #        B  [P]
      #         \ /
      #          H

        whence do |a|
          z = Home_::TestSupport::Fixtures::ZigZag.new
          z.with_specificity do
            z.on_pleasure do |e|
              touch[ a, :p, e ]
            end
          end
          z
        end

        it 'b1' do
          call_digraph_listeners :business
          does nil, nil
        end

        it 'p1' do
          call_digraph_listeners :pleasure
          does nil, true
        end

        it 'h1' do
          call_digraph_listeners :hacking
          does nil, true
        end

        it 'p2' do
          call_digraph_listeners :pleasure
          does nil, true
        end
      end

      context "3. listen to specific stream & taxonomic parent - NO DUPES" do

      #        B  [P]
      #         \ /
      #         [H]

        whence do |a|
          z = Home_::TestSupport::Fixtures::ZigZag.new
          z.with_specificity do
            z.on_hacking do |e|
              touch[ a, :h, e ]
            end
            z.on_pleasure do |e|
              touch[ a, :p, e ]
            end
          end
          z
        end

        it 'h1' do
          call_digraph_listeners :hacking
          does true, nil
        end

        it 'h2' do
          call_digraph_listeners :hacking
          does true, nil
        end

        it 'p1' do
          call_digraph_listeners :pleasure
          does nil, true
        end

        it 'p2' do
          call_digraph_listeners :pleasure
          does nil, true
        end

        it 'b1' do
          call_digraph_listeners :business
          does nil, nil
        end

        it 'b2' do
          call_digraph_listeners :business
          does nil, nil
        end
      end

      context "4. listening to *both* taxonomic parents!! - LEFTMOST WINS" do

      #       [B] [P]
      #         \ /
      #          H

        whence do |a|
          z = Home_::TestSupport::Fixtures::ZigZag.new
          z.with_specificity do
            z.on_business do |e|
              touch[ a, :b, e ]
            end
            z.on_pleasure do |e|
              touch[ a, :p, e ]
            end
          end
          z
        end

        it 'b1' do
          call_digraph_listeners :business
          does nil, nil, true
        end

        it 'p1' do
          call_digraph_listeners :pleasure
          does nil, true, nil
        end

        it 'h1 MONEY' do
          call_digraph_listeners :hacking
          does nil, nil, true
        end
      end
    end
  end
end
