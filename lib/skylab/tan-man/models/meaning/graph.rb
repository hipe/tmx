module Skylab::TanMan
  class Models::DotFile::Meaning::Graph
    include Core::SubClient::InstanceMethods

    # Some notes about resolving meaning: Meanings are currently stored
    # in comment strings in the sexps, and are not in their 'resting state'
    # held as sexps like other parts of the document.  For this reason and
    # others, we do not cache a parsed sexp / graph of meanings;, but rather
    # each time a meaning is to be applied (after being resolved) to a node,
    # we create an entire semantic graph to nerk the derk. This may have
    # to change for some strange scenario where we need more performace,
    # resolving lots of meanings quickly, but for the purpose of one-meaning
    # assignment-per-request, this should be sufficient to create the
    # whole graph on each request. Even if it feels icky, it will introduce
    # far fewer headaches as we develop this.
    #
    # Implementation note: experimentally this graph is "collapsed" one-way
    # lazily - so it indexes itself zero or one times and never goes back.
    # Hence afte we index ourselves we can release the source data and not
    # get confused.


    memo_class = ::Struct.new :resolution, :trail

    define_method :resolve do |meaning, interminable_meaning|
      @indexed or index!
      memo = memo_class.new [], []
      res = reduce meaning, memo, interminable_meaning
      if res
        res.resolution
      else
        res
      end
    end

  protected

    def initialize request_client, list
      @indexed = nil
      @digraph = ::Skylab::Semantic::Digraph.new
      @index = nil
      @list = list
      super request_client
    end

    attr_reader :digraph

    attr_reader :index

    def index!
      digraph.clear
      @index = { }
      list.each do |fly|
        meaning = fly.collapse self
        @index.fetch( meaning.symbol ) { |k| @index[k] = [] }.push meaning
        if looks_terminal? meaning
          @digraph.node! meaning.symbol
        else
          @digraph.node! meaning.symbol, is: meaning.value.intern
        end
      end
      @indexed = true
      @list = nil # release source data (for now)!
      nil
    end

    attr_reader :list


    valid_name_rx = Models::DotFile::Meaning::FUN.valid_name_rx

                                                 # centralize this hack -
    define_method :looks_terminal? do |meaning|  # a meaning looks like a
      valid_name_rx !~ meaning.value             # terminal definition iff
    end                                          # its value is not a
                                                 # valid name!!!


    class InterminableMeaning < ::Struct.new :reason, :trail
      def initialize trail
        super :interminable, trail
      end
    end

    class CircularDependency < InterminableMeaning
      def initialize trail
        self[:reason] = :circular
        self[:trail] = trail
      end
    end

    define_method :reduce do |meaning, memo, interminable_meaning|
      sem = digraph[ meaning.symbol ]
      sem or raise ::KeyError.new "key not found: #{ meaning.symbol.inspect }"
      if sem.is_names.length.zero?
        if ! memo.resolution.include?( meaning )
          memo.resolution.push meaning
        end # else deadly diamond of doom (see spec)
      elsif sem.visited
        interminable_meaning[ CircularDependency.new memo.trail ]
        memo = false
        break
      else
        sem.visited = true
        memo.trail.push meaning
        sem.is_names.each do |rhs_sym|
          if index.key? rhs_sym
            index.fetch( rhs_sym ).each do |mean|
              mem = memo_class.new memo.resolution, memo.trail.dup
              if ! reduce mean, mem, interminable_meaning
                memo = false
                break
              end
            end
          else
            interminable_meaning[ InterminableMeaning.new memo.trail ]
            memo = false
            break
          end
        end
      end
      memo
    end
  end
end
