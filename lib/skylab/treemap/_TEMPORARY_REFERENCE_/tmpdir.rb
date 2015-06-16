module Skylab::Treemap

  class Models::Pathname::Tmpdir < Models::Pathname # (was [#031])

    extend PubSub::Emitter

    emits             created: :annotated,
                       exists: :annotated,
                      failure: :text

    event_factory Treemap::Model::Event::FACTORY

    attr_reader :is_normalized

    def normalize
      if exist?
        if directory?
          emit :exists, path: self
          res = true
        else
          error 'not a directory'
          res = false
        end
      else
        begin
          mkdir
          emit :created, path: self
          res = true
        rescue ::SystemCallError => e
          if /^([^-]+) - / =~ e.to_s
            msg = $~[1]  # wat is this i dont ..
          else
            "a system call error occured when trying to make the directory"
          end
          emit :failure, msg
          res = false
        end
      end
      @is_normalized = res
    end

  private

    def initialize path, &wire
      wire or raise ::ArgumentError, 'block required'
      @is_normalized = false
      super path, M_etaHell::MONADIC_TRUTH_  # always lack required force
      wire[ self ]
      nil
    end
  end
end
