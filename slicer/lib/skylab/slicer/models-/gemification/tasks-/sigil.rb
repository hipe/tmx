module Skylab::Slicer

  class Models_::Gemification

    class Tasks_::Sigil < Task_[]

      depends_on :Sidesystem_Directory

      def execute

        @basename = ::File.basename @Sidesystem_Directory.path

        sigil = Basename_to_sigil[ @basename ]

        if sigil
          @sigil = sigil
          ACHIEVED_
        else
          self._COVER_ME
        end
      end

      attr_reader(
        :basename,
        :Sidesystem_Directory,
        :sigil,
      )

      Basename_to_sigil = -> do

        rx = /_|(?=[0-9])/

        common = -> basename do
          a = basename.split rx, 2
          if 1 == a.length
            a.first[ 0, 2 ]
          else
            a.map { | part | part[ 0, 1 ] }.join EMPTY_S_
          end
        end

        special_rx = /\A(?:sl.|tmx)/  # there's that one thing somewhere but meh

        -> basename do

          md = special_rx.match basename
          if md
            md[ 0 ]
          else
            common[ basename ]
          end
        end
      end.call
    end
  end
end
