module Skylab::Git

  FUN = Git_::Lib_::FUN_module[].new

  class FUN::SCM_check

    define_singleton_method :[], -> y, file_a, * x_a do
      new( y, file_a, x_a ).execute
    end

    def initialize y, file_a, x_a
      @be_verbose = false
      @error_exit_status = 1
      @file_a = file_a ; @when_status_p = nil ; @y = y
      if x_a.length.nonzero?
        @x_a = x_a
        begin
          send :"#{ x_a.shift }="
        end while @x_a.length.nonzero?
      end
    end
  private
    def be_verbose=
      @be_verbose = @x_a.shift
    end
    def when_status=
      @when_status_p = @x_a.shift
    end
  public
    def execute
      require 'open3'
      @cmd_a = [ * %w( git status --porcelain ), * @file_a ]
      @be_verbose and @y << "(#{ @cmd_a * ' ' })"
      _, o, e, w = ::Open3.popen3( * @cmd_a )
      @did = false
      while (( s = e.gets ))
        y << "(err: #{ s })" ; @did = true
      end
      @a = []
      while (( s = o.gets ))
        s.chomp! ; @a << s
      end
      @es = w.value.exitstatus
      conclude
    end
  private
    def conclude
      if @es.zero? then when_status_zero else when_status_nonzero end
    end
    def when_status_nonzero
      @y << "nonzero result status from git, exiting: #{ @es }"
      @es
    end
    def when_status_zero
      if @did then when_errput else when_no_errput end
    end
    def when_errput
      @y << "unexpected errput, exiting"
      @error_exit_status
    end
    def when_no_errput
      @a.each do |s|
        status, file = s.split ' ', 2
        desc = case status
               when 'M'  ; "has a 'modified' status"
               when '??' ; "is not under version control"
               else      ; "has a status of '#{ status }'"
               end
        @y << "according to git, '#{ file }' #{ desc }"
      end
      if @a.length.zero? then when_empty_a else when_status end
    end
    def when_empty_a
      # the absence of anything means it's ok
    end
    def when_status
      if @when_status_p then @when_status_p[] else
        @y << "will not procede because of the above."
        @error_exit_status
      end
    end
  end
end
