require 'open3'

module Skylab::Face

  # read both stdout and stderr of a system command without blocking
  # (this is superseded by [#hl-048] Headless::IO::Upstream::Select,
  # and was probably its inspiration without knowing it)
  #

  module Open2
    extend self

    class Handler
      [:out, :err].each do |out|
        define_method(out) { |&b| instance_variable_set("@_#{out}", b) }
        attr_accessor "_#{out}"
      end
    end

    NUM_BYTES = 4096

    def open2 cmd, sout=nil, serr=nil, &b
      _STDOUT = ::STDOUT ; _STDERR = ::STDERR
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
      if sout.nil? and serr.nil? and b.nil?
        require 'stringio'
        omnibuffer = ::StringIO.new
        on.out { |s| omnibuffer.write(s) }
        on.err { |s| omnibuffer.write(s) }
      else
        on._out.nil? and on.out { |s| _STDOUT.write(s) ; _STDERR.flush }
        on._err.nil? and on.err { |s| _STDERR.write(s) ; _STDERR.flush }
      end
      bytes = 0
      time = Time.now
      ::Open3.popen3(cmd) do |sin, _sout, _serr|
        open = [ { :in => _serr, :out => :_err }, { :in => _sout, :out => :_out } ]
        loop do
          open.each_with_index do |s, idx|
            if ::IO.select([s[:in]], nil, nil, 0.1) # yes this could instead do .. etc
              str = nil
              done = false
              begin
                str = s[:in].readpartial NUM_BYTES
                s[:in].closed? and done = true
              rescue ::EOFError
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
      omnibuffer and omnibuffer.rewind and return omnibuffer.read
      [bytes, Time.now - time]
    end
  end
end
