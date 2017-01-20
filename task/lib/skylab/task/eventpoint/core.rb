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

      At_ = -> * i_a do  # #protected-not-private
        i_a.map( & method( :send ) )
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
