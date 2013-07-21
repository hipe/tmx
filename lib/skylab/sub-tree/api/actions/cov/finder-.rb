module Skylab::SubTree

  SubTree::Services::Shellwords.class  # #kick

  class API::Actions::Cov

    class Finder_  # [#sl-118]

      MetaHell::Funcy[ self ]

      MetaHell::FUN.fields[ self, :yielder, :error_p, :info_p,
        :find_in_pn, :be_verbose ]

      def execute
        ok = true ; cmd = build_command
        @be_verbose and @info_p[ cmd ]
        SubTree::Services::Open3.popen3 cmd do |_, sout, serr|
          e = serr.read
          if '' != e then
            ok = false
            @error_p[ e ]
          else
            sout.each_line do |line|
              @yielder << ::Pathname.new( line.chomp )
            end
          end
        end
        ok
      end

    private

      def build_command
        "find #{ @find_in_pn.to_s.shellescape } -type dir \\( #{
          TEST_DIR_NAME_A_.
            map { |x| "-name #{ x.to_s.shellescape }" } * ' -o '
        } \\)"
      end
    end
  end
end
