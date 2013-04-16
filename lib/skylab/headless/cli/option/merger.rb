module Skylab::Headless

  class CLI::Option::Merger

    # for doing wild experiments (so far seen in treemap and test/all)
    # of merging multiple options with the same normalized switches
    # but different callback blocks and description string arrays
    # into one megafucker.

    -> do  # `initialize`

      define_method :initialize do |desc, err=nil|

        i_a = %i| short_fulls long_fulls |
        h = ::Hash[ i_a.map { |i| [ i, { } ] } ]
        a = [ ] ; orig_info_a = [ ]
        er = -> msg do
          ( err || -> m { raise m } ).call msg
        end
        redact = nil  # an apropos portmanteau of `reduce` and `detect`
        merge = nil   # when it is time to make the money
        @add = -> opt, *info do
          touch = nil
          exist_idx = redact[ opt, -> i, str do
            touch ||= true
            h.fetch( i )[ str ]
          end ]
          if ! touch
            break( er[ "must have at least one short or long - #{
              }#{ desc[ *info ] }" ] )
          end
          if exist_idx
            merge[ exist_idx, opt, info ]
          else
            idx = a.length
            a[ idx ] = opt
            orig_info_a[ idx ] = info
            redact[ opt, -> i, str do
              h.fetch( i )[ str ] = idx
              nil  # this means keep going
            end ]
            true
          end
        end
        redact = -> opt, f do
          res = nil
          i_a.each do |i|
            opt.send( i ).each do |str|  # pass 1
              res = f[ i, str ] and break
            end
            res and break
          end
          res
        end
        merge = -> exist_idx, src, info_a do
          tgt = a.fetch exist_idx
          if tgt.is_option
            tgt = Headless::CLI::Option::Aggregation.new(
              tgt, desc, err, orig_info_a.fetch( exist_idx ) )
            a[ exist_idx ] = tgt
          end
          tgt.add src, * info_a
        end
        @write = -> op do
          a.each_with_index do |x, idx|
            if x.is_option
              op.define( * x.args, & x.block )
            else
              x.write op
            end
          end
          nil
        end
      end
    end.call

    def add opt, *info
      @add.call opt, *info
    end

    def write op
      @write.call op
    end
  end
end
