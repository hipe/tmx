class Skylab::Task

  class Eventpoint  # :[#004].

    # three laws

    class << self
      def define_graph
        centrus = GraphDefinition___.new
        yield DefineGraph___.new centrus
        centrus.finish
      end
    end # >>

    # ==

    class DefineGraph___

      def initialize dfn
        @_definition = dfn
      end

      def beginning_state sym
        @_definition.__receive_beginning_state_ sym
      end

      def add_state * dfn_a
        @_definition.__receive_node_ DefineEventpoint___.new( dfn_a ).execute
        NIL
      end
    end

    # ==

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

    # ==

    class GraphDefinition___

      def initialize
        @_node_box = Common_::Box.new
        @_sources_via_destination = {}
        @__beginning_state_mutex = nil

        @beginning_state_symbol = nil
      end

      def __receive_beginning_state_ sym
        remove_instance_variable :@__beginning_state_mutex
        @beginning_state_symbol = sym ; nil
      end

      def __receive_node_ node
        name_sym = node.name_symbol
        @_node_box.add name_sym, node
        sym_a = node.can_transition_to
        if sym_a
          sym_a.each do |sym|
            ( @_sources_via_destination[ sym ] ||= [] ).push name_sym
          end
        end
      end

      def finish
        if __valid
          __flush
        end
      end

      def __valid
        __valid_references && __valid_elemental_members
      end

      def __valid_references
        h = @_node_box.h_
        xtra = nil
        @_sources_via_destination.each_key do |k|
          h.key? k or ( xtra ||= [] ).push k
        end
        if xtra
          raise KeyError, __say_unre( xtra )
        else
          ACHIEVED_
        end
      end

      def __valid_elemental_members
        _must_have :@beginning_state_symbol
      end

      def _must_have ivar
        instance_variable_get( ivar ) or raise RuntimeError, __say_req( ivar )
      end

      def __say_unre xtra
        "unresolved reference#{ 's' if 1 != xtra.length }: #{
          }#{ xtra * ', '}"
      end

      def __say_req ivar
        "graph must have '#{ ivar.id2name[ 1..-1 ] }'"
      end

      def __flush
        Graph___.define do |o|
          o.beginning_state_symbol = @beginning_state_symbol
          o.nodes_box = @_node_box.freeze
          o.sources_via_destination = @_sources_via_destination
        end
      end
    end

    # ==

    class DefineEventpoint___

      # syntax is intentially close to [#ba-044] state machine,
      # but intentionally implemented separately

      def initialize x_a
        @_scn = Common_::Scanner.via_array x_a
        @_has = false
        @_mutex = nil
      end

      def execute
        name_symbol = @_scn.gets_one
        until @_scn.no_unparsed_exists
          send PRIMARIES___.fetch @_scn.gets_one
        end
        if @_has
          _a = remove_instance_variable :@can_transition_to
        end
        Eventpoint___.new _a, name_symbol
      end

      PRIMARIES___ = {
        can_transition_to: :__process_can_transition_to,
      }

      def __process_can_transition_to

        # passing false-ish, passing the empty array, and not engaging
        # this primary at all all has the exact same effect.

        # passing only a symbol is a "macro" for passing an array of only that value

        remove_instance_variable :@_mutex
        x = @_scn.gets_one
        if x
          if x.respond_to? :id2name
            @_has = true
            x = [x]
          elsif x.length.nonzero?
            @_has = true
          end
        end
        if @_has
          @can_transition_to = x.freeze ; nil
        end
      end
    end

    # ==

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

    # ==

    class Graph___ < Common_::SimpleModel

      attr_accessor(
        :beginning_state_symbol,
        :nodes_box,
        :sources_via_destination,
      )

      def to_line_stream_for_dot_file
        _dotfile true
      end

      def to_line_stream_for_dot_file_inverted
        _dotfile false
      end

      def _dotfile fwd
        Here_::LineStream_for_Dotfile_via_Graph.call_by do |o|
          o.graph = self
          o.be_inverted = ! fwd
        end
      end
    end

    Eventpoint___ = self
    class Eventpoint___
      def initialize sym_a, sym
        if sym_a
          @can_transition_to = sym_a
        end
        @name_symbol = sym
        freeze
      end
      attr_reader(
        :can_transition_to,
        :name_symbol,
      )
    end

    # ==

    Here_ = self
    KeyError = ::Class.new ::KeyError

    # ==
  end
end
# #history: massive overhaul begun
