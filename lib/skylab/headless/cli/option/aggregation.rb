module Skylab::Headless

  class CLI::Option::Aggregation

    # for the option parser merger / aggregation hack.

    def is_option
      false  # used to determine when to make this
    end

    def initialize first, desc, err, info_a
      @desc, @err = desc, err
      @info_a = info_a
      @set_a = two_sets first
      @a = [ ]
      _add first, info_a
    end

    A_ = %i| short_fulls long_fulls |

    def two_sets opt
      A_.map do |i|
        ea = opt.send i
        Headless::Library_::Set[ * (
          ea ? ea.to_a : [ ]
        ) ]
      end
    end
    private :two_sets

    def err
      @err || -> m { fail m }
    end

    def add opt, * info_a  # result is pair
      stay = true ; res = nil
      a = two_sets opt
      A_.length.times do |idx|
        l = @set_a.fetch idx
        r = a.fetch idx
        if l != r
          res = err[ "option parser merge hack failure - #{
            }the #{ @desc[ * info_a ] } introduces a set of #{
            }#{ A_.fetch idx } (#{ r.to_a * ', ' }) that differs from #{
            }the original set set out by the #{ @desc[ * @info_a ] } #{
            }(#{ l.to_a * ', ' })" ]
          break( stay = false )
        end
      end
      if stay
        _add opt, info_a
      end
      [ stay, res ]
    end

    def _add opt, info_a
      @a << [ opt, info_a ]
      nil
    end
    private :_add

    # `write` - write out an aggregate list of description strings in the form
    # of:
    #   "plugin 1 line 1"
    #   "plugin 1 line 2 (plugin 1)"
    #   "plugin 2 line 1 (plugin 2)"
    #   "plugin 3 [..]"
    #
    # that is, put the plugin's name ("slug") in parentheis at its final
    # line of description.
    #
    # Also write an aggregate option callback block that simply muxes
    # out the call to each block.

    def write op
      desc_a = [ ]
      block_a = [ ]
      @a.each do |opt, info_a|
        dsc_a = opt.sexp.children( :desc ).map( & :last )
        if 1 < dsc_a.length                    # zero or more unannotated lines
          dsc_a[ 0 .. -2 ].each { |x| desc_a << x }
        end
        if dsc_a.length.nonzero?               # zero or one annotated line
          slug = @desc[ * info_a ]
          slug &&= " (#{ slug })"              # kind of eew here
          desc_a << "#{ dsc_a.fetch( -1 ) }#{ slug }"
        end
        if opt.block
          block_a << opt.block
        end
      end
      sw_a = @set_a.reduce [] do |m, set|
        m.concat set.to_a
        m
      end
      op.define( * sw_a, * desc_a ) do |*a|
        block_a.each do |blk|
          blk.call( *a )
        end
      end
      nil
    end
  end
end
