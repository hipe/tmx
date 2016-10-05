class Skylab::Task
  # ->
    class Eventpoint < ::Module  # :[#004].

      class Graph

        def self.[] mod
          Adapter_module_for___[ mod ][ mod ]
        end

        Adapter_module_for___ = -> do
          h = {
            ::Module => -> { Module_Adapter_Methods___ }
          }
          -> x do
            h.fetch( x.class ).call
          end
        end.call

        def initialize a, h  # mutates nodes with linkbacks
          @a = a
          @h = h
          calculate_linkbacks
        end

        def to_text
          a = [ ]
          render_text_lines_to a.method( :<< )
          a * NEWLINE_
        end

        def render_text_lines_to p
          cache_a = [ ] ; maybe_single_h = { } ; seen_h = { }
          @a.each do |i|
            n = @h.fetch i
            if (( a = n.to_a ))
              a.each do |n_|
                seen_h[ i_ = n_.node_symbol ] = true
                if (( idx = maybe_single_h[ i_ ] ))
                  cache_a[ idx ] = nil
                end
                cache_a << "#{ i } -> #{ i_ }"
              end
            elsif ! seen_h[ i ]
              maybe_single_h[ n.node_symbol ] = cache_a.length
              cache_a << n.node_symbol.id2name
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
          o = build_reconciliation y, from_i, to_i, sig_a
          wv = o.work_
          if wv
            wv
          else
            o._express_via_expression_grid
          end
        end

        def build_reconciliation y, from_i, to_i, sig_a
          Reconciliation___.new y, self, from_i, to_i, sig_a
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
                to_a_h.fetch( n_.node_symbol ) do |i_|  # memo that there is a `to`
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

      module Graph::Module_Adapter_Methods___

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

      Eventpoint__ = self
      class Eventpoint__

        def initialize blk

          @node_symbol = nil
          @to_a = nil

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

        attr_reader :node_symbol
        alias_method :node_id, :node_symbol  # some contexts

        def name_notify node_i
          @node_symbol and fail "hack failed - do this better"
          @node_symbol = node_i
          nil
        end

        attr_reader :to_a

        def linkback_notify a
          @to_a and fail "sanity - write once"
          @to_a = a
          nil
        end

        def transitions_to? ep
          i = ep.node_symbol
          if @to_a
            @to_a.index do |x|
              x.node_symbol == i
            end
          end
        end

        def eventpoint_notify_method_name
          @enmn ||= :"#{ @node_symbol.downcase }_eventpoint_notify"
        end
      end

      Multi_add_ = -> i, x do
        @h.fetch( i ) do |_|
          @a << i
          @h[ i ] = [ ]
        end.push x
        nil
      end

      Same_method_ = -> * x_a, & x_p do

        o = new( * x_a, & x_p )
        wv = o.work_
        if wv
          wv
        else
          o._express_via_expression_grid
          UNABLE_
        end
      end

      module Worker_Methods_

        def add_statementish_ agent, predicate, any_conj=nil

          eg = @expression_grid
          if ! eg
            eg = Grid__.new
            @expression_grid = eg
          end

          eg << Grid_Frame__[ agent, predicate, any_conj ]

          NIL_
        end

        def _express_via_expression_grid
          @expression_grid.articulate_each_frame_to @y.method( :<< )
          UNABLE_
        end

        def express_ const, * args
          Here_::Expressions___.const_get( const, false )[ * args ]
        end

        def errmsg_ agent, predicate, any_conj=nil
          Grid_Frame__[ agent, predicate, any_conj ].articulate_self
        end

        attr_reader(
          :expression_grid,
        )
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
          word_a * SPACE_ if word_a.length.nonzero?
        end

        Internen__ = -> mod_x do

          Common_::Name.via_module( mod_x ).as_const.to_s.
            gsub( /_+\z/, EMPTY_S_ ).downcase
        end

        def get_exponent
          @exponent ||=
            :"#{ Internen__[ @agent.class ]}_#{ Internen__[ @predicate.class ] }"
        end
      end

      class Reconciliation___

        include Worker_Methods_

        def initialize y, graph, from_i, to_i, sig_a

          @after_symbol = to_i
          @expression_grid = nil
          @before_symbol = from_i
          @graph = graph
          @sig_a = sig_a
          @y = y
        end

        def work_
          wv = ___find_path
          wv && __check_dependencies( wv.value_x )
        end

        def ___find_path

          _ = Here_::FindPath___.new(
            @y, @graph, @before_symbol, @after_symbol, @sig_a )

          _common _
        end

        def __check_dependencies x

          _common Here_::Check_dependencies___.new( @y, @graph, x, @sig_a )
        end

        def _common o
          wv = o.work_
          if wv
            wv
          else
            @expression_grid = o.expression_grid
            UNABLE_
          end
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
                  h[ pred.node_symbol ] = true
                end
              end
            end
            h
          end
          @subscribed_to_cache_h[ ep.node_symbol ]
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

        Depend_Soft = Signature__::Predicate.new :depend, :node_symbol

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

        From_Soft__ = Signature__::Predicate.new :from, :before_symbol, :to_pred

        To__ = Signature__::Predicate.new :to, :from_pred, :after_symbol

        class From_Soft__  # this little tricklette lets us compose
          # two objects that are immutable but associated with each other.

          alias_method :_, :initialize

          def initialize sig, from_i
            @before_symbol = from_i
            @sig = sig
            @to_pred = yield self
          end

          alias_method :node_symbol, :before_symbol  # in some contexts

          def after_symbol
            @to_pred.after_symbol
          end

          def strength
            SOFT_STRENGTH_
          end
        end

        class From_Hard__ < From_Soft__
          def strength
            HARD_STRENGTH_
          end
        end
      end

      Here_ = self
    end
  # -
end
