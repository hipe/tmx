module Skylab::Slicer

  class Models_::Gemification

    class Tasks_::Sigil < Task_[]

      # two aspects of sigils are in flux at writing:
      #
      #   1) sigils (see the eponymous model file in [tmx]) are no longer
      #      relied upon as much as they once were by the gem. (specifically:
      #      we used to use them to comprise a component of the VERSION's
      #      pre-release name, but we no longer do.)
      #
      #   2) we no longer allocate sigils at the time this subject task
      #      is run. (now, we must "re-allocate" the "sigilization"
      #      "by hand" (by running a single script) every time the
      #      constituency of the members of the ecosystem changes (for
      #      example adding a sidesystem, removing a sidesystem, or
      #      changing a sidesystem's name).
      #
      # (this changed to what is described above at #history-A.)
      # however, A) we still feel that sigils are an important part of
      # a sidesystem gem generally and B) we might want to to use them
      # elsewise when we generate a gemspec file, for example, in the
      # dummy placeholder URL for the website for the sidesystem..)

      depends_on(
        :For_TMX_Map_File,
      )

      def execute

        # for our own resilience and because it's too easy not to, we are
        # circumventing whatever other machinery is there for doing this

        rsx = @For_TMX_Map_File.resources_
        path = @For_TMX_Map_File.path
        _json = ::File.read path
        require 'json'
        sct = ::JSON.parse _json, symbolize_names: true  # could fail, we don't
        sigil = sct[ :sigil ]
        if sigil
          @sigil = sigil ; ACHIEVED_
        else
          @_listener_.call :error, :expression do |y|
            y << "for now, we want every sidesystem to know its own sigil."
            y << "#{ path } should have a 'sigil' in it."
            y << "with a monolithic repo (or all of the sidesystems), you could"
            y << "try running: #{ rsx.this_one_script }"
          end
          UNABLE_
        end
      end

      attr_reader(
        :sigil,
      )

      # ==
      # ==
    end
  end
end
# :#history-A: we used to build the sigil here. now we just read it.
