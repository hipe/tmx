module Skylab::SubTree

  class API::Actions::Cov

    class Lister_

      # the lister manages which auxiliary "listing" operations are
      # mutually exclusive with other operations, and which are merely
      # auxiliary inline with normal operation. anywhere you see "resolve"
      # below is the way that the lister communicates back up to the caller,
      # by simply returning a symbolic method-ish name when relevant, to
      # indicate that there may be more rendering that needs to be done.

      MetaHell::FUN.fields[ self, :emit_p, :hubs, :did_error_p, :list_as ]

      def execute_and_resolve
        begin
          r = normalize or break
          r = flush_and_resolve
        end while nil
        r
      end

      class Box_ < Basic::Box
        def render
          case length
          when 0 ;
          when 1 ; render_a.fetch 0
          else   ; "(#{ render_a * ', ' })"
          end
        end
        def render_a
          values.map { |i| "'#{ i }'" }
        end
      end

      def normalize
        mutex = Box_.new ; union = Box_.new ; unrec = Box_.new
        @list_as.reduce nil do |m, i|
          case i
          when :list, :test_tree_shallow  ; mutex.touch i
          when :code                      ; union.touch :code_tree
          when :test                      ; union.touch :test_tree
          when :ct, :tc                   ; union.touch :code_tree
                                          ; union.touch :test_tree
          else                            ; unrec.touch i
          end
          nil
        end
        unrec.length.nonzero? and
          bork "unrecognized list/tree option(s) - #{ unrec.render }"
        if mutex.length.nonzero?
          union.length.nonzero? and bork "#{ mutex.render_a * ' and ' } #{
            }cannot be used with #{ union.render_a * ' and ' }"
          1 < mutex.length and bork "#{
            }#{ mutex.render_a * ' and ' } are mutually exclusive"
        end
        if is_ok
          @mutex_value = @union = nil
          if mutex.length.nonzero?
            @mutex_value = mutex.values.first
          elsif union.length.nonzero?
            @union = union
          end
        end
        is_ok
      end

      def get_mutex_list_as
        @mutex_value if @mutex_value
      end

      def flush_and_resolve
        num = 0 ; r = nil
        hub_a = @hubs.to_a
        hub_a.each do |hub|
          @emit_p[ :hub_point, hub ]
          hub._local_test_pathname_a.each do |ltpn|
            num += 1
            @emit_p[ :test_file, hub: hub, short_pathname: ltpn ]
          end
          if @did_error_p[]
            r = false
          else
            @emit_p[ :number_of_test_files, num ]
          end
        end
        if false == r then false
        elsif @mutex_value then nil else
          :tree
        end
      end

      attr_reader :did_bork

      def do_list_tree i
        has_union_exponent i
      end

    private

      def bork msg
        @emit_p[ :error, msg ]
        @did_bork = true
        false
      end

      def is_ok
        ! did_bork
      end

      def has_union_exponent i
        @union and @union.has? i
      end
    end
  end
end
