module Skylab::TestSupport

  module Regret

      class Infer_const__

        # given an anchorized locally absolute path to a ruby file, infer
        # what the constant array to it might be, e.g for "foo/bar-baz/bif.rb"
        # infers e.g [ :Foo, :BarBaz, :Bif ]. it can certainly guess the
        # casing wrong.

        Lib_::Properties_stack_frame.call self,
          :actoresque,
          :required, :field, :tail_path,
          :required, :field, :notice_p

        def execute
          -> do  # #result-block
            c_a = [] ; scn = TestSupport_::Library_::StringScanner.new @tail_path
            while (( tok = scn.scan RX_ ))  # the regex has a fwd lookahead
              scn.pos = scn.pos + 1         #  assertion so we don't capture
              c_a << Constantify_[ tok ].intern  # the '/' but skip over it
            end
            if ! (( md = FILE_RX_.match scn.rest ))
              @notice_p[ "sanity - expecting ruby file - #{ scn.rest }" ]
              break false
            end
            c_a << Constantify_[ md[ :noext ] ].intern
          end.call
        end

      private

        RX_ = %r{[^/]+(?=/)}

        FILE_RX_ = /\A (?<noext> [-_a-z0-9]+ ) #{
          }#{ ::Regexp.escape Autoloader_::EXTNAME } \z/x

        Constantify_ = LIB_.name_sanitize_for_constantize_file_proc
      end
  end
end
