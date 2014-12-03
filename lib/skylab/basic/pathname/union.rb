module Skylab::Basic

  # progressive construction:
  # you can build up the union progressively, one path at at time:
  #
  #     u = Subject_[].new
  #     u.length  # => 0
  #     u << ::Pathname.new( '/foo/bar' )  # (internally converted to string)
  #     u.length  # => 1
  #     u << '/foo'
  #     u << '/biff/baz'
  #     u.length  # => 3

  # `normalize` eliminates logical redundancies in the union
  # like so:
  #
  #     u = Subject_[ '/foo/bar', '/foo', '/biff/baz' ]
  #     u.length  # => 3
  #     e = u.normalize
  #     e.message_proc[] # => 'eliminating redundant entry /foo/bar which is covered by /foo'
  #     u.length  # => 2

  # `match` will result in the first path in the union that 'matches'
  # like so:
  #
  #     u = Subject_[ '/foo/bar', '/foo', '/biff/baz' ]
  #     x = u.match '/no'
  #     x # => nil
  #     x = u.match '/biff/baz'
  #     x.to_s # => '/biff/baz'

  # if you use the result of `match` be aware it may be counter-intuitive.
  # the constituent paths that make up the union can "act like" files or
  # folders (leaves or branches) based on how the argument string "treats"
  # them - maybe better to think of them just as nodes in a tree!
  #
  # result of `match` is the node that matched:
  #
  #     u = Subject_[ '/foo/bar', '/foo', '/biff/baz' ]
  #     x = u.match '/biff/baz/other'
  #     x.to_s # => '/biff/baz'
  #

  class Pathname::Union

    def self.[] *a
      o = new
      a.each { |x| o << x }
      o
    end

    def initialize
      @a = [ ]
    end

    def length
      @a.length
    end

    def << x
      @a << "#{ x }".freeze
      nil
    end

    def normalize ev=nil
      @a.sort!
      scn = Basic_::List.line_stream @a
      prev = scn.gets ; elim = nil
      if prev
        while curr = scn.gets
          if _match prev, curr
            ( elim ||= Eliminated_.new ) << Elim_[ prev, curr ]
            @a[ scn.count - 1 ] = nil
          else
            prev = curr
          end
        end
      end
      res = nil
      if elim
        @a.compact!
        res = ev ? ev[ elim ] : elim
      end
      res
    end

    def match x
      x = x.to_s
      @a.detect do |y|
        _match y, x
      end
    end

    def _match shorter, longer
      if 0 == longer.index( shorter )
        if longer.length == shorter.length then true else
          '/' == longer[ shorter.length ]
        end
      end
    end
    private :_match
  end

  class Pathname::Union::Eliminated_

    def initialize
      @a = []
    end

    attr_reader :a

    def << x
      @a << x
    end

    def message_proc
      @message_proc ||= bld_msg_p
    end

    def bld_msg_p
      arr = @a
      -> do

        agg = Basic_::Lib_::Scn_lib[].articulators.aggregating(

          :template, "{{ longer }} covered by {{ shorter }}",

          :longer, :aggregate, -> y, a do

            y << "eliminating redundant entr#{ 1 == a.length ? 'y' : 'ies' } #{
             }#{ a * ' and ' } which #{ 1 == a.length ? 'is' : 'are' }"

          end, :on_first_mention, -> y, x do
            y << "eliminating redundant entry #{ x } which is"
          end,  # #todo maybe

          :shorter, :aggregate, -> y, a do
            a = a.uniq
            y << a * ' and '
          end )

        _upstream_producer = Callback_.scan.via_nonsparse_array( arr ).map_by do |st|
          st.each_pair.reduce [] { |m, a| m.concat a ; m }
        end

        scn = agg.map_reduce_under _upstream_producer
        a = []
        if s = scn.gets
          a.push s
        end
        if s = scn.gets
          a.push PERIOD_
          begin
            a.push SPACE_, s, PERIOD_
            s = scn.gets
          end while s
        end
        a * EMPTY_S_
      end
    end

    EMPTY_S_ = ''.freeze ; PERIOD_ = '.'.freeze ; SPACE_ = ' '.freeze
  end

  Pathname::Union::Elim_ = ::Struct.new :shorter, :longer

  # for fun, `message_proc` may play with `aggregated articulation`
  # like so:
  #
  #     u = Subject_[ '/foo/bar', '/foo/baz/bing', '/foo', '/a', '/a/b', '/a/b/c' ]
  #     u.normalize.message_proc[]  # => "eliminating redundant entries /a/b and /a/b/c which are covered by /a. eliminating redundant entries /foo/bar and /foo/baz/bing which are covered by /foo"
end
