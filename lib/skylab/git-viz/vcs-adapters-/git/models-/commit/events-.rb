module Skylab::GitViz

  module VCS_Adapters_::Git

    class Models_::Commit

      module Events_

        class << self

          def any_potential_event_for err_line, t

            md = FATAL_BAD_REVISION___.match err_line

            if md

              [ [ :error, :bad_revision ], -> do

                Bad_Revision___.new_with(
                  :revision_identifier, md[ 1 ],
                  :exitstatus, t.value.exitstatus )

              end ]
            end
          end
        end  # >>

        FATAL_BAD_REVISION___ = /\Afatal: bad revision '(.+)'\n\z/

        Bad_Revision___ = Callback_::Event.prototype_with :bad_revision,

            :ok, false,
            :revision_identifier, nil,
            :exitstatus, nil do | y, o |

          y << "unrecognized revision #{ ick o.revision_identifier }"
        end

      end
    end
  end
end
