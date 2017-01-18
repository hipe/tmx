module Skylab::Basic

  class Range::Positive::Union

    def initialize
      @a = [ ]
      @unexpected_proc = nil
    end

    attr_writer :unexpected_proc

    def description_under expag

      if @a.length.nonzero?
        @a.map do | x |
          x.description_under expag
        end * LOOK_LIKE_MANPAGE__
      end
    end

    def description

      if @a.length.nonzero?
        @a.map do | x |
          x.description
        end * LOOK_LIKE_MANPAGE__
      end
    end

    LOOK_LIKE_MANPAGE__ = ','.freeze

    # `add` - result t|f

    def add cur
      res = true
      begin

        break( res = @unexpected_proc[
          "can't understand non-positive range - #{ cur.description }" ] ) if
            cur.begin < 1

        break( res = @unexpected_proc[
          "can't understand range with negative width - #{ cur.description  }"] ) if
            cur.end < cur.begin and cur.end != Range::Positive::INFINITY

        break( @a << Range::Positive::Mutable_.new( cur.begin, cur.end ) ) if
          @a.length.zero?
        prev_idx, next_idx = find_indexes cur
        prev_idx and prv = @a.fetch( prev_idx )
        next_idx and nxt = @a.fetch( next_idx )
        @did_back = @did_fwd = @did_nil = nil
        if prv
          case prv.end <=> cur.begin
          when 0, 1
            @did_fwd = true
            if cur.end > prv.end
              fuse_fw prev_idx, cur.end
            end
          end
          case prv.begin <=> cur.begin
          when 0, 1
            fuse_bk prev_idx, cur.begin
          end
        end
        if nxt && ! @did_fwd
          case cur.end <=> nxt.begin
          when 0,1
            fuse_bk next_idx, cur.begin
          end
          case cur.end <=> nxt.end
          when 0,1
            fuse_fw next_idx, cur.end
          end
        end
        if @did_back || @did_fwd
          @a.compact!  if @did_nil
        elsif prev_idx
          insert_at ( prev_idx + 1 ), cur
        else
          insert_at next_idx, cur
        end
      end while nil
      res
    end

    # `include?` NOTE -- how about we are undefined when empty!? (see `prune`)

    def include? fixnum
      i = 0 ; len = @a.length ; res = nil
      begin
        @a.fetch( i ).include?( fixnum ) and break( res = true )
        i += 1           # (yes the whole thing could be a oneliner were
      end while i < len  # it not for reasons..)
      res
    end

    # `prune` - result in a possibly simpler version of self, possibly
    # destroying self in the process

    def prune
      case @a.length
      when 0 ; Range::Positive::UNBOUNDED
      when 1 ; r = @a.fetch 0
               r.freeze
               @a.clear
               @a.freeze
               r
      else   ; self
      end
    end

  private

    def find_indexes cur
      scn = Home_::List::LineStream_via_Array[ @a ]
      while x = scn.gets
        if x.begin < cur.begin
          prev_begin_idx = scn.count - 1
        else
          next_begin_idx = scn.count - 1
          break
        end
      end
      [ prev_begin_idx, next_begin_idx ]
    end

    def append cur
      @a << Range::Positive::Mutable_.new( cur.begin, cur.end )
      nil
    end

    def insert_at idx, cur
      @a[ idx, 0 ] = [ Range::Positive::Mutable_.new( cur.begin, cur.end) ]
      nil
    end

    def fuse_fw idx, nd
      @did_fwd = true
      x = @a.fetch idx
      x.end = nd
      idx = idx + 1
      len = @a.length
      while idx < len
        y = @a.fetch idx
        break if y.begin > x.end
        x.end = y.end if y.end > x.end
        @a[ idx ] = nil
        @did_nil = true
        idx += 1
      end
      nil
    end

    def fuse_bk idx, beg
      @did_back = true
      x = @a.fetch idx
      x.begin = beg
      idx = idx - 1
      nil
    end

    def infinitize idx
      x = @a.fetch idx
      if x.end != Range::Positive::INFINITY
        x.end = Range::Positive::INFINITY
        if idx < @a.length - 1
          @a[ idx .. -1 ] = []
        end
      end
      nil
    end
  end
end
