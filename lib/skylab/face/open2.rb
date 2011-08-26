require 'open3'

module Skylab; end
module Skylab::Face

  # read both stdout and stderr of a system command without blocking
  #

  module Open2
    class Handler
      [:out, :err].each do |out|
        define_method(out) { |&b| instance_variable_set("@_#{out}", b) }
        attr_accessor "_#{out}"
      end
    end
    NUM_BYTES = 4096
    def open2 cmd, sout=nil, serr=nil, &b
      on = Handler.new
      sout and on.out { |s| sout.write(s) }
      serr and on.err { |s| serr.write(s) }
      if block_given?
        if b.arity == 1
          b.call on
        else
          on.instance_eval(&b)
        end
      end
      on._out.nil? and on.out { |s| $stdout.write(s) ; $stdout.flush }
      on._err.nil? and on.err { |s| $stderr.write(s) ; $stderr.flush }
      bytes = 0
      time = Time.now
      Open3.popen3(cmd) do |sin, _sout, _serr|
        open = [ { :in => _serr, :out => :_err }, { :in => _sout, :out => :_out } ]
        loop do
          open.each_with_index do |s, idx|
            if IO.select([s[:in]], nil, nil, 0.1) # yes this could instead do .. etc
              str = nil
              done = false
              begin
                str = s[:in].readpartial NUM_BYTES
                s[:in].closed? and done = true
              rescue EOFError => e
                done = true
              end
              if str
                bytes += str.length
                on.send(s[:out]).call(str)
              end
              if done
                open[idx] = nil
                open.compact!
              end
            end
          end
          open.empty? and break
        end
      end
      [bytes, Time.now - time]
    end
  end
end
