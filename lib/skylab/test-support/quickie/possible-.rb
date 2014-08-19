module Skylab::TestSupport

  module Quickie

    module Possible_

      class Graph

        def self.[] mod
          ADAPTER_MOD_H_.fetch( mod.class )[][ mod ]
        end

        ADAPTER_MOD_H_ = {
          ::Module => -> { Module_Adapter_Methods__ }
        }.freeze

        def initialize a, h  # mutates nodes with linkbacks
          @a, @h = a, h
          calculate_linkbacks
        end

        def to_text
          a = [ ]
          render_text_lines_to a.method( :<< )
          a * "\n"
        end

        def render_text_lines_to p
          cache_a = [ ] ; maybe_single_h = { } ; seen_h = { }
          @a.each do |i|
            n = @h.fetch i
            if (( a = n.to_a ))
              a.each do |n_|
                seen_h[ i_ = n_.node_i ] = true
                if (( idx = maybe_single_h[ i_ ] ))
                  cache_a[ idx ] = nil
                end
                cache_a << "#{ i } -> #{ i_ }"
              end
            elsif ! seen_h[ i ]
              maybe_single_h[ n.node_i ] = cache_a.length
              cache_a << n.node_i.to_s
            end
          end
          cache_a.compact!
          cache_a.each( & p )
          nil
        end

        def new_graph_signature client_x, input_x=nil
          Signature__.new client_x, input_x
        end

        def reconcile y, from_i, to_i, sig_a
          Reconciliation__.new( y, self, from_i, to_i, sig_a ).execute
        end

        def reconcile_with_path_or_failure y, from_i, to_i, sig_a
          Reconciliation__.new( y, self, from_i, to_i, sig_a ).
            execute_with_story_or_failure
        end

        def fetch_eventpoint i
          @h.fetch i
        end

        def get_possible_eventpoints
          @a.map( & @h.method( :fetch ) )
        end

      private

        def calculate_linkbacks  # algo is repeated at [#ba-021] (`invert`)
          to_a_h = { } ; a_ = [ ]
          @a.each do |i|
            n = @h.fetch i
            if (( a = n.from_a ))                # if node `n` has from nodes
              a.each do |n_|                     # then for each from node
                to_a_h.fetch( n_.node_i ) do |i_|  # memo that there is a `to`
                  a_ << i_                       # from the from node to `n`
                  to_a_h[ i_ ] = [ ]
                end << n
              end
            end
          end
          a_.each do |i|
            @h.fetch( i ).linkback_notify to_a_h.fetch( i )
          end
          nil
        end
      end

      module Graph::Module_Adapter_Methods__

        def self.[] mod
          mod.extend self
          nil
        end

        def eventpoint &blk
          graph_is_closed and raise "sanity - graph is closed."
          Eventpoint__.new blk  # re-opening would be trivial
        end

        attr_reader :graph_is_closed

        def possible_graph
          if graph_is_closed
            @possible_graph
          else
            @graph_is_closed = true
            a = [ ] ; h = { }
            constants.each do |i|
              ep = const_get i, false
              ep.name_notify i
              a << i
              h[ i ] = ep
            end
            @possible_graph = Graph.new a, h
          end
        end
      end

      class Eventpoint__ < ::Module

        def initialize blk
          @node_i = nil ; @to_a = nil
          if blk
            Shell__.new( a = [] ).instance_exec( & blk )
            @from_a = a.freeze
          end
        end
        class Shell__
          def initialize a
            @a = a
          end
          def from x
            @a << x
            nil
          end
        end

        attr_reader :from_a

        attr_reader :node_i ; alias_method :node_id, :node_i  # some contexts

        def name_notify node_i
          @node_i and fail "hack failed - do this better"
          @node_i = node_i
          nil
        end

        attr_reader :to_a

        def linkback_notify a
          @to_a and fail "sanity - write once"
          @to_a = a
          nil
        end

        def transitions_to? ep
          i = ep.node_i
          if @to_a
            @to_a.index do |x|
              x.node_i == i
            end
          end
        end

        def eventpoint_notify_method_name
          @enmn ||= :"#{ @node_i.downcase }_eventpoint_notify"
        end
      end

      Say_ = -> do  # #protected-not-private
        Possible_::Articulators__
      end

      Multi_add_ = -> i, x do  # #protected-not-private
        @h.fetch( i ) do |_|
          @a << i
          @h[ i ] = [ ]
        end.push x
        nil
      end

      Errmsg_ = -> agent, predicate, any_conj=nil do  # #protected-not-private
        Grid_Frame__[ agent, predicate, any_conj ].articulate_self
      end
      #
      # ( above and below share signature, make it easy to swap )
      #
      Add_grid_frame__ = -> agent, predicate, any_conj=nil do
        ( @grid ||= Grid__.new ) << Grid_Frame__[ agent, predicate, any_conj ]
        nil
      end

      Articulate_grid__ = -> do # assume @grid
        @grid.articulate_each_frame_to @y.method( :<< )
        nil
      end

      module Grid_Methods_  # #protected-not-private

        define_method :add_frame, & Add_grid_frame__
        private :add_frame

        define_method :errmsg, & Errmsg_
        private :errmsg

        def perform_execution_result
          if ! @grid then true else
            articulate
            false
          end
        end

        define_method :articulate, & Articulate_grid__
        private :articulate
      end

      class Grid__
        def initialize
          @a = [ ]
        end
        def length
          @a.length
        end
        def fetch_frame idx
          @a.fetch idx
        end
        def << frame
          @a << frame
          nil
        end
        def each &blk
          @a.each( &blk )
        end
        def map &blk
          @a.map( &blk )
        end
        def articulate_each_frame_to p
          @a.each do |frame|
            p[ frame.articulate_self ]
          end
          nil
        end
      end

      class Grid_Frame__

        class << self ; alias_method :[], :new end

        def initialize agent, predicate, any_conj=nil
          @agent, @predicate, @any_conj = agent, predicate, any_conj
        end

        def articulate_self
          word_a = [ ]
          (( s = @any_conj && @any_conj.articulate_self )) and word_a << s
          (( s = ( @agent | @predicate ).inflect )) and word_a << s
          word_a * ' ' if word_a.length.nonzero?
        end

        Internen__ = -> mod_x do
          QuicLib_::Name_const_basename[ mod_x.to_s ].
            gsub( /_+\z/, EMPTY_S_ ).downcase
        end

        def get_exponent
          @exponent ||=
            :"#{ Internen__[ @agent.class ]}_#{ Internen__[ @predicate.class ] }"
        end
      end

      class Reconciliation__

        def initialize y, graph, from_i, to_i, sig_a
          @grid = nil
          @y, @graph, @from_i, @to_i, @sig_a = y, graph, from_i, to_i, sig_a
        end

        def execute
          execute_with_story_or_failure.fetch 0
        end

        def execute_with_story_or_failure
          begin
            ok, x = Possible_::Pathfinder__.
              new( @y, @graph, @from_i, @to_i, @sig_a ).
                execute_with_path_or_failure
            ok or break
            ok, x = Possible_::Dependency_Checker__.
              new( @y, @graph, x, @sig_a ).execute_with_path_or_failure
          end while nil
          [ ok, x ]
        end
      end

      At_ = -> * i_a do  # #protected-not-private
        i_a.map( & method( :send ) )
      end

      class Signature__

        def initialize client_x, input_x
          @a = [ ] ; @client_x = client_x ; @fuzzd = nil
          @h = { } ; @input_x = input_x
        end

        def each_pair &blk
          ea = ::Enumerator.new do |y|
            @a.each do |i|
              y.yield i, @h.fetch( i )
            end
            nil
          end
          blk ? ea.each( & blk ) : ea
        end

        def client
          @client_x
        end

        def fuzzified
          @fuzzd ||= bld_fuzzified
        end
      private
        def bld_fuzzified
          @input_x.map do |token_s|
            /\A#{ ::Regexp.escape token_s }/
          end
        end
      public

        def nilify_input_element_at_index idx
          @input_x[ idx ] = nil
          @fuzzd and @fuzzd[ idx ] = nil
        end

        def input
          @input_x
        end

        def nudge from_i, to_i
          move pred::From_Soft__, from_i, to_i
        end

        def carry from_i, to_i
          move pred::From_Hard__, from_i, to_i
        end

        def react i
          depend pred::Depend_Soft, i
        end

        def rely i
          depend pred::Depend_Hard, i
        end

        def subscribed_to? ep
          @subscribed_to_cache_h ||= begin
            h = { }
            @a.each do |node_i|
              @h.fetch( node_i ).each do |pred|
                case pred.predicate_i
                when :from, :depend
                  h[ pred.node_i ] = true
                end
              end
            end
            h
          end
          @subscribed_to_cache_h[ ep.node_i ]
        end

      private

        def pred
          Signature__::Predicates
        end

        def depend clas, i
          dep = clas.new self, i
          add i, dep
          nil
        end

        def move clas, from_i, to_i
          from = clas.new self, from_i do |frm|
            pred::To__[ self, frm, to_i ]
          end
          add from_i, from
          add to_i, from.to_pred
          nil
        end

        define_method :add, & Multi_add_

      end

      class Signature__::Predicate
        class << self
          alias_method :orig_new, :new
        end

        def self.new pred_i, * i_a
          ::Class.new( self ).class_exec do
            class << self
              alias_method :new, :orig_new
              alias_method :[], :new
            end
            const_set :PREDICATE_I_, pred_i
            attr_reader :sig, * i_a
            ivar_h = ::Hash[ i_a.map { |i| [ i, :"@#{ i }" ] } ].freeze
            len = i_a.length
            define_method :initialize do |sig, *rest|
              len == rest.length or raise ::ArgumentError, "wrong number #{
                }of arguments (#{ rest.length + 1 } for #{ len + 1 })"
              @sig = sig
              len.times do |idx|
                instance_variable_set ivar_h.
                  fetch( i_a.fetch idx ), rest.fetch( idx )
              end
              nil
            end
            self
          end
        end

        def predicate_i
          self.class::PREDICATE_I_
        end

        def client
          @sig.client
        end
      end

      SOFT_STRENGTH_ = 1
      HARD_STRENGTH_ = SOFT_STRENGTH_ << 1

      module Signature__::Predicates

        Depend_Soft = Signature__::Predicate.new :depend, :node_i

        class Depend_Soft
          def strength_i
            :react
          end
        end

        class Depend_Hard < Depend_Soft
          def strength_i
            :rely
          end
        end

        From_Soft__ = Signature__::Predicate.new :from, :from_i, :to_pred

        To__ = Signature__::Predicate.new :to, :from_pred, :to_i

        class From_Soft__  # this little tricklette lets us compose
          # two objects that are immutable but associated with each other.
          alias_method :_, :initialize
          def initialize sig, from_i
            @sig, @from_i = sig, from_i
            @to_pred = yield self
            nil
          end

          alias_method :node_i, :from_i  # in some contexts

          def strength
            SOFT_STRENGTH_
          end

          def to_i
            @to_pred.to_i
          end
        end

        class From_Hard__ < From_Soft__
          def strength
            HARD_STRENGTH_
          end
        end
      end
    end
  end
end
