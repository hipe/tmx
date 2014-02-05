#!/usr/bin/env ruby -w

v = $VERBOSE ; $VERBOSE = nil ; require 'open4' ; $VERBOSE = v # open4 is loud
require 'strscan'

puts "starting ruby."


def flush_buffer! err_buff, require_newline = true
  scn = ::StringScanner.new(err_buff)
  num_chars_read = 0
  until scn.eos?
    got = scn.scan( require_newline ? /\A.+?\r?\n/ : /.*/ ) or break
    num_chars_read += got.length
    print "\nE: #{got.inspect}"
  end
  num_chars_read > 0 and err_buff.slice!(0, num_chars_read)
  num_chars_read > 0 ? num_chars_read : nil
end

MAXLEN__ = 80

status = ::Open4.open4('sh') do |pid, sin, sout, serr|
  sin.puts('source tmp.sh'); sin.close
  obuff = ''
  eopen = true
  my_ebuff = ''
  while obuff || eopen
    if obuff && obuff = sout.gets # block on reading stdout
      print "\nO: #{obuff.inspect}"
    end
    begin
      while eopen
        if /^.+?\r?\n/ =~ my_ebuff.concat(serr.read_nonblock(MAXLEN__))
          flush_buffer!(my_ebuff)
        end
      end
    rescue ::Errno::EAGAIN, ::Errno::EWOULDBLOCK => e
    rescue ::EOFError => e
      eopen = false
      my_ebuff.lengh.zero? || flush_buffer!(my_ebuff, false)
    end
  end
end

puts "\npid ##{ status.pid } exited with status #{ status.exitstatus }"
puts "done with ruby."
