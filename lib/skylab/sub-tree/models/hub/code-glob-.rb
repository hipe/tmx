module Skylab::CovTree

  class Models::Hub

    class Code_glob_

      MetaHell::Funcy[ self ]

      MetaHell::FUN.fields[ self, :app_hub_pn, :test_dir_pn, :sub_path_a ]

      def execute
        Stop_at_pathname_[ @test_dir_pn ] and fail "sanity - hub '.' or / ?"
        glob = get_code_file_glob
        path_a = ::Dir[ glob ]
        tricky_filter path_a
        path_a
      end

    private

      def get_code_file_glob
        "#{ get_cursor_pn }/**/*#{ EXTNAME_ }"
      end

      def get_cursor_pn
        cursor_pn = @app_hub_pn
        if @sub_path_a
          cursor_pn = cursor_pn.join( @sub_path_a.join SEP_ )
        end
        cursor_pn
      end

      def tricky_filter code_path_a
        # filter out all the non-test looking files under the test dir (but
        # this is only necessary when there no sub-path because the test
        # file itself is a sub-path)
        if ! @sub_path_a
          sep = ::Regexp.escape SEP_
          tdpn = @test_dir_pn.to_s

          # ::Pathname won't prepend a local looking path with a dot (by
          # design), but the first token of our paths may or may not be
          # a '.'

          if DOT_ == @app_hub_pn.to_s && DOTSEP_ != tdpn[ 0, 2 ]
            tdpn = ".#{ SEP_ }#{ tdpn }"  # ::Pn won't do this for you, by design
          end
          tdpn = ::Regexp.escape tdpn
          rx = %r< \A #{ tdpn } #{ sep } >x

          code_path_a.keep_if( & rx.method( :!~ ) )
        end
        nil
      end

      DOTSEP_ = "#{ DOT_ }#{ SEP_ }"

    end
  end
end
