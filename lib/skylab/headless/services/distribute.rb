module Skylab::Headless::Services

  module Distribute

    # `Lines` (goofy future-proofed name) -
    # given a list of arguments that is a flat list of pairs, each pair
    # representing 1) one stream open for reading (or really any `gets`-
    # compatible line producer) and 2) a (already chomped) line consumer
    # in a *blocking* manner read from each stream one line at a time,
    # eliminating streams from the list as they result in a false-ish `gets`
    # until none is left, at which point result is always nil
    #
    # (this can be useful in conjuction with Open3)
    #

    Lines = -> io, line, *rest do
      0 != rest.length % 2 and raise ::ArgumentError, "must have even no. args"
      rest.unshift io, line ; io = line = nil
      hot_a = ( 0 ... rest.length ).step( 2 ).reduce [] do |arr, idx|
        arr << Stream_[ rest[ idx ], rest[ idx + 1 ] ]
      end
      begin
        (( hot_a.length - 1 ).downto 0 ).each do |idx|
          stream = hot_a[idx]
          line = stream.io.gets
          if line
            line.chomp!
            stream.func[ line ]
          else
            hot_a[ idx ] = nil  # NOTE here is why we do it backwards
            hot_a.compact!
          end
        end
      end while hot_a.length.nonzero?
      nil
    end

    Stream_ = ::Struct.new :io, :func
  end
end
