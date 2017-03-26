module Skylab ; end # etc

module Skylab::Human

  module Summarization

    def ellipsis
      '..'
    end

    # precondition: `out` "strlen" is less than maxlen (when maxlen not nil)
    STEP = ->(out, struct, maxlen) do
      hot = (0..out.length-1).map { |i| i if ::String != out[i].class }.compact
      currlen = out.join('').length
      strs = hot.select { |i| ::String == struct[i].class }
      if 0 < strs.length
        mutate = -> do
          strs.each { |i| hot[hot.index(i)] = nil ; out[i] = struct[i] }
          hot.compact!
        end
        nextlen = currlen + strs.map { |i| struct[i].length }.reduce(&:+)
        case maxlen ? (nextlen <=> maxlen) : -1
        when -1 ; mutate.call ; currlen = nextlen
        when  0 ; mutate.call ; return
        when  1 ;               return
        end
      end
      catch :stop do
        hot.any? or throw :stop
        _maxlen = maxlen ? (maxlen - currlen) : nil
        nexts = hot.map do |i|
          n = Array.new(struct[i].length)
          STEP[n, struct[i], _maxlen]
          n.any? or throw :stop # this node's minlength was over maxlen
          n
        end
        _mutate = -> { nexts.each_with_index { |n, i| out[hot[i]] = n } }
        _nextlen = nexts.join('').length
        case _maxlen ? (_nextlen <=> _maxlen) : -1
        when -1 ; _mutate.call
        when  0 ; _mutate.call ; return
        when  1 ;              ; return
        end
      end
    end
    def summarize maxlen, struct # order might change!
      ::String === struct and return truncate(maxlen, struct)
      -1 == maxlen and maxlen = nil
      out = Array.new(struct.length)
      STEP[out, struct, maxlen] if 0 != maxlen
      out.join
    end
    def truncate maxlen, str
      -1 == maxlen || maxlen.nil? and return str
      case 0 <=> ( str.length - maxlen )
      when 1, 0 ; str
      else      ; "#{str[0, [0, maxlen - ellipsis.length].max]}#{ellipsis[0, maxlen]}"
      end
    end
  end
end
