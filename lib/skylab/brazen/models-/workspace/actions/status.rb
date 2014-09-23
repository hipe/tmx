module Skylab::Brazen

  class Models_::Workspace

  class Actions::Status < Brazen_::Model_::Action

    Brazen_::Model_::Entity[ self, -> do

      o :desc, -> y do
        y << "get status of a workspace"
      end

      o :inflect, :verb, 'determine'

      o :is_promoted

      o :after, :init




      o :environment, :non_negative_integer,
        :description, -> y do
          y << "how far up do we look?"
        end,
        :property, :max_num_dirs


      o :flag, :property, :verbose


      o :default, '.',
        :description, "the location of the workspace",
        :description, -> y do
          y << "it's #{ highlight 'really' } neat"
        end,
        :required, :property, :path

    end ]

    def produce_any_result
      @prop = self.class.properties.fetch :path
      @ws = Workspace_.edited self, @kernel do |o|
        o.with_argument_box @argument_box
        o.with :channel, :status,
          :prop, @prop
      end
      @ws.error_count.zero? and work
    end

    def work
      pn = @ws.execute
      pn and when_pn
    end

    def receive_status_resource_not_found ev
      _ev = ev.dup_with :ok, ACHEIVED_
      receive_event _ev ; nil
    end

    def receive_status_start_directory_does_not_exist ev
      receive_event ev ; nil
    end

    def receive_status_start_directory_is_not_directory ev
      receive_event ev ; nil
    end

    def receive_status_found_is_not_file ev
      receive_event _ev ; nil
    end

    def when_pn
      send_OK_event_with :resource_exists,
        :pathname, @ws.pn, :is_completion, true
    end

  end
  end
end
