module Skylab::Face

  # a variety of 5.x facets are grouped here, including many that depend
  # on each other.

  module CLI::Set
    def self.touch ; nil end      #kick-the-loading-warninglessly-and-trackably
  end

  # ~ 5.9x - command parameters as mutable ~

  # (you may need mutable node sheets you generate "dynamically" and
  # manipulate programmatically)

  class Node_Sheet_  # #re-open for facet 3

    undef_method :set_command_parameters_proc
    def set_command_parameters_proc f  # spec'd
      has_command_parameters_proc and fail "sanity - clobber cpf?"
      @has_command_parameters_proc = true
      @command_parameters_function_value = f
      nil
    end

    def command_parameters_function_value
      @has_command_parameters_proc or fail "check `has_..` first"
      @command_parameters_function_value
    end
  end

  # ~ 5.11x - the `set` API ~

  class Namespace  # #re-open for facet.
    class << self
      undef_method :set
      def set *a
        @story.absorb_xtra a
        nil
      end
    end
  end

  class NS_Sheet_  # #re-open for facet.
  private
    undef_method :lift_prenatals
    def lift_prenatals
      @has_prenatals = false
      a, h = @box._raw_constituency ; existing = [] ; p_h = { }
      a.each do |i|
        if (( sht = h.fetch i )).is_prenatal
          p_h[ i ] = sht
          h[ i ] = nil  # TASTE THE PAIN
        else
          existing << i
        end
      end
      add = -> i, cs do
        if (( pn = p_h.delete i ))
          cs.subsume pn
          h.fetch( i ).nil? or fail "sanity"
          @box.change i, cs
          true
        end
      end
      flush = -> do
        p_h.length.nonzero? and raise "incomplete node declaration(s): #{
          }the following had properties defined but were never defined #{
          }as a command - (#{ p_h.keys * ', ' })"
      end
      [ existing, add, flush ]
    end
  end

  class Command  # #re-open
  private
    def process_deferred_set  # assume trueish `@sheet.set_a`
      @sheet.set_a.each do |k, v|  # do *NOT* mutate the set_a here!!
        instance_variable_set :"@#{ k }_value", v
      end
      nil
    end
  end

  class Node_Sheet_

    # `absorb_xtra` - #called-by instance of child class : e.g NS_Sheet_
    # we do it this way and not with using the attr_writer b.c using `foo=`
    # is too conceptually limiting - its conventional interface is a) not the
    # same as ours and b) ambiguous for how to procede with errors and c)
    # semantically confusing if e.g we are concat'ing and not setting.
    # we use methods and not a function hash (for tacit validation of `k`)
    # for extensibility.
    # #result-is not important. mutating xtra_a is not important.

    Fly_ = Services::Basic::List::Scanner::For::Array.new( Val_a_ = [ 0 ] )

    undef_method :absorb_xtra
    def absorb_xtra xtra_a  # assumes nonzero length
      if 1 == xtra_a.length and xtra_a[ 0 ].respond_to? :each_pair
        h = xtra_a[ 0 ] ; keys = h.keys
        if keys.length.nonzero?
          begin
            Fly_.reset
            Val_a_[ 0 ] = h.fetch( k = keys.shift )
            send :"parse_xtra_#{ k }", Fly_
            Fly_.eos? or raise "not expecting any arguments for `#{ k }`"
          end while keys.length.nonzero?
        end
      else
        absorb_xtra_scn Services::Basic::List::Scanner::For::Array.
          new( xtra_a )
      end
      nil
    end

    def absorb_xtra_scn scn  # assumes at least 1 - #called-by parent node
      begin
        k = scn.fetchs  # like fetch and gets
        send :"parse_xtra_#{ k }", scn
      end until scn.eos?
      nil
    end
    protected :absorb_xtra_scn  # #protected-not-private

    def subsume prenatal  # #called-by parent sheets *and* mecahnics
      a = prenatal.instance_variables
      a.each do |ivar|
        if instance_variable_defined? ivar
          if :@name != ivar
            fail "hack failed - collision with #{ ivar }"
          end
        else
          instance_variable_set ivar, prenatal.instance_variable_get( ivar )
        end
      end
      nil
    end

  private
    undef_method :defer_set
    def defer_set i, x
      ( @set_a ||= [ ] ) << [ i, x ]
      nil
    end
  end

  # ~ 5.12x - desc ~

  class NS_Sheet_
  private
    def parse_xtra_desc scn
      ( @desc_proc_a ||= [ ] ) << scn.fetchs
      nil
    end
  end

  # ~ 5.13x - skip ~

  class NS_Sheet_  # #re-open
    def do_include
      ! do_skip
    end
    attr_reader :do_skip
  private
    def parse_xtra_skip scn
      @do_skip = scn.fetchs
      nil
    end
  end

  # ~ 5.14x - invisible

  class Command
    undef_method :is_visible  # even though it is not a magic toucher
    def is_visible
      ! invisible_value
    end
    attr_reader :invisible_value
    alias_method :is_invisible, :invisible_value
    private :invisible_value
  end
  class Node_Sheet_
    undef_method :defers_invisibility
    attr_reader :defers_invisibility  # [#047]
  private
    def parse_xtra_invisible scn
      @defers_invisibility = true
      defer_set :invisible, true
      nil
    end
  end

  # ~ 5.15x - `node` ~

  class NS_Sheet_
  private
    def parse_xtra_node scn
      node_i, _ = scn.fetch_chunk 2
      scn.ungets  # above is a fun way to assert syntax
      s = nil
      @box.if? node_i, -> xs do
        s = xs
      end, -> do
        s = @node_open or begin
          @has_prenatals = true
          s = @box.add node_i, Node_Sheet_.new( node_i )
        end
      end
      s.absorb_xtra_scn scn  # for sure at least 1 left to do per above
      nil
    end
  end
end
