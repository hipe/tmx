require 'open3'

module Skylab::System

  class Sessions__::Open2  # :[#025].

    # ancient thing that's too simple to throw out, but not yet reconciled

  # read both stdout and stderr of a system command without blocking
  # (this is superseded by [#sy-006] IO select,
  # and was probably its inspiration without knowing it)
  #

    Models_ = ::Module.new
    class Models_::Handler
      [:out, :err].each do |out|
        define_method(out) { |&b| instance_variable_set("@_#{out}", b) }
        attr_accessor "_#{out}"
      end
    end

    NUM_BYTES = 4096

    def initialize cmd_s_a, any_sout, any_serr, & x_p

      @cmd_s_a = cmd_s_a
      @serr = any_serr
      @sout = any_sout
      @x_p = x_p
    end

    def execute

      _STDOUT = ::STDOUT ; _STDERR = ::STDERR
      on = Models_::Handler.new
      @sout and on.out { |s| @sout.write(s) }
      @serr and on.err { |s| @serr.write(s) }

      p = @x_p
      if p
        if 1 == p.arity
          p[ on ]
        else
          on.instance_exec( & p )
        end
      end

      if @sout.nil? and @serr.nil? and p.nil?
        require 'stringio'
        omnibuffer = ::StringIO.new
        on.out { |s| omnibuffer.write(s) }
        on.err { |s| omnibuffer.write(s) }
      else
        on._out.nil? and on.out { |s| _STDOUT.write(s) ; _STDERR.flush }
        on._err.nil? and on.err { |s| _STDERR.write(s) ; _STDERR.flush }
      end

      bytes = 0
      time = ::Time.now
      ::Open3.popen3( * @cmd_s_a ) do |sin, _sout, _serr|
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
      [bytes, ::Time.now - time]
    end
  end
end
