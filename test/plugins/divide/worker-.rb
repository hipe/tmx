class Skylab::Test::Plugins::Divide

  MetaHell = ::Skylab::MetaHell

  class Worker_

    def self.[] *a
      new( *a ).execute
    end

    def initialize host, argv
      out, err = host[ :paystream, :infostream ]
      integer = kw = nil ; dflt = 3

      validate = partition = render = nil
      @execute = -> do
        validate[] or break
        if ! integer
          err.puts "(defaulting to #{ dflt } subdivisions)"
          integer = dflt
        end
        big_a = get_big_a host
        len = big_a.length
        if integer > len
          err.puts "(integer is larger than (#{ len }). subdividing in to 1)"
          integer = 1
        end
        if :random == kw
          big_a.shuffle!
        end
        part_a = partition[ len ]
        offset = -1
        part_b = integer.times.map do |i|
          segnum = part_a.fetch i
          segnum.times.map do
            offset += 1
            big_a.fetch( offset ).data.normalized_local_name
          end
        end
        render[ part_b ]
      end
      render = -> part_b do
        pname = host.full_program_name
        part_b.each do |rack|
          out.puts "#{ pname } #{ rack * ' ' }"
        end
        false
      end
      partition = -> len do
        small_int = len / integer
        part_a = integer.times.map { small_int }
        sum = part_a.reduce :+
        idx = 0
        while sum < len
          part_a[ idx ] += 1
          sum += 1
          idx += 1
          if idx == integer
            idx = 0
          end
        end
        part_a
      end
      validate = -> do
        ok = true
        if ! argv then [ nil, nil ] else
          integer, kw = MetaHell::FUN._parse_series[ argv,
            [ -> x { /\A\d+\z/ =~ x },
              -> x { /\A[a-z]+\z/i =~ x } ],
            -> e do
              if ok # only once
                err.puts "expecting arguments [ <integer> ] [ random ]"
              end
              ok = false
              err.puts e.message_function.call
            end,
          ]
          if ok
            if kw
              i = 'random'.index kw
              if i && i.zero?
                kw = :random
              else
                err.puts "for now, only 'random' is supported, #{
                  }not #{ kw.inspect }"
                ok = false
              end
            end
            if integer
              integer = integer.to_i
            end
          end
          if ! ok
            err.puts "please correct the above and try again."
            break false
          end
        end
        ok
      end
    end

    def execute ; @execute.call end

    def get_big_a host
      ::Enumerator.new do |y|
        host.hot_subtree.children.each do |tree|
          if tree.children.count.nonzero?
            y << tree
          end
        end
        nil
      end.to_a
    end
    private :get_big_a
  end
end
