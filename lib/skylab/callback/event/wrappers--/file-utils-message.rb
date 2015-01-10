module Skylab::Callback

    class Event

      class Wrappers__::File_utils_message

        Callback_::Actor.call self, :properties,
          :msg

        # WARNING - major hack alert
        #
        # for "security" or just aesthetics, some controllers want to
        # render messages about paths (files, directories) without rendering
        # the (absolute?) paths themselves. instead they may want to decorate
        # the paths in some way or strip them entirely from the message.
        #
        # in the interest of less code we attempt to leverage file-utils
        # whenever we can, and as part of this we attempt to re-use the
        # output message from file-utils itself. but this in conjunction
        # with the previous point leads to this hack, which is non-robust;
        # arguably because of an issue with file-utils:
        #
        # cumbersome, non-recommended or ugly as it may be, filenames may
        # contain leading dashes and/or spaces. when file-utils outputs
        # messages with paths like these, it does so without shell-escaping
        # them, making it 1) misleading becuase these messages are presented
        # as if they are valid shell input buffers when in fact they may
        # not be 2) it is then impossible (yes impossible) to tell what is
        # supposed to be the options part of the invocation from the argument
        # part (the path(s)).
        #
        # sadly our antidote to this hackiness is more hackiness with
        # the below regex, making it almost not worth it to use file-utils
        # in the first place.
        #
        # so CAVEAT bear in mind that with perhaps all commands implemented
        # by fileutils the behavor of this hack is always unreliable.
        # the output of chown has ambiguos syntax whether or not you are
        # using sane pathnames (given its behavior around nils).
        # as for the other commands, to parse their output is always
        # a guess at best: "mkdir -p foo" might actually be the output for
        # making two directires, the first of which is called "-p". you
        # really never know.
        #
        # when we fail to parse the output of file-utils entirely, this actor
        # produces false. but note that it may appear to have succeeded
        # when in fact it got tripped up by this issue.

        def execute
          @md = PATH_HACK_RX__.match @msg
          if @md
            work
          else
            UNABLE_
          end
        end

        # in the below regex the various commands are coded for in the
        # order that they appear in the subject file currently.

        PATH_HACK_RX__ = %r(\A

          (?<predicate>
            cd (?: [ ] -)? |
            mkdir (?: [ ] -p )? (?: [ ] -m [ ] \d+ )? |
            rmdir (?: [ ] -p )? |
            ln (?: [ ] -ls?f )? |
            cp (?: [ ] -r?p )? |
            mv (?: [ ] -f )? |
            rm (?: [ ] -r?f )? |
            install -c (?: [ ]-p )? (?: [ ]-m [ ] \d+ )? |
            chmod \d+ |
            # chown is omitted because its syntax is not reliably parsable
            touch (?: [ ]-c )? (?: [ ]-t [ ] [^ ]+ )? )

          (?:
            [ ]
            (?<argument>
              .+ )
          )?\z)x

        def work

          predicate, any_path = @md.captures

          _message_head = if any_path
            "#{ predicate }#{ SPACE_ }"
          else
            predicate
          end

          Event_.inline_with :file_utils_event,
              :path, any_path,
              :message_head, _message_head,
              :ok, nil do |y, o|

            y << "#{ o.message_head }#{ o.path }"
          end
        end
      end
    end
end
