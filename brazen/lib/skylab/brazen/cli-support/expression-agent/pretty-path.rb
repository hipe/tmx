module Skylab::Brazen

  module CLI_Support

    class Expression_Agent

      class Pretty_Path  # re-write [#sy-005]

        Callback_::Actor[ self, :properties, :path ]

        def execute
          @path_length = @path.length
          maybe_find_home_match
          maybe_find_pwd_match
          if @home_did_match
            if @pwd_did_match
              do_the_one_that_is_longer
            else
              do_home
            end
          elsif @pwd_did_match
            do_pwd
          else
            do_relative_path_from_pwd
          end
        end

      private

        def maybe_find_home_match
          @home = ::ENV[ 'HOME' ]
          @home_did_match = if @home
            path_has_this_at_head @home
          else
            false
          end
        end

        def maybe_find_pwd_match
          @pwd = ::Dir.pwd
          @pwd_did_match = path_has_this_at_head @pwd
        end

        def path_has_this_at_head s
          s_length = s.length
          @path_length >= s_length && @path[ 0, s_length ] == s &&
            ( @path_length == s_length ||
             FILE_SEPARATOR_BYTE == @path.getbyte( s_length ) )
        end

        def do_the_one_that_is_longer
          if @home.length > @pwd.length  # when lengths are equal, pwd wins
            do_home
          else
            do_pwd
          end
        end

        def do_home
          "~#{ @path[ @home.length .. -1 ] }"
        end

        def do_pwd
          ".#{ @path[ @pwd.length .. -1 ] }"
        end

        def do_relative_path_from_pwd
          subject = ::Pathname.new @path
          if subject.relative?
            subject.to_path
          else
            subject.relative_path_from( ::Pathname.new @pwd ).to_path
          end
        end
      end
    end
  end
end
