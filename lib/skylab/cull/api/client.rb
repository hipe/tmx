module Skylab::Cull

  class API::Client

    def initialize
      @config_file_search_start_pathname = -> do
        ::Pathname.pwd
      end
      @config_file_search_num_dirs = 3
      @model_controller_h = { }
    end

    attr_reader :config_file_search_start_pathname
    attr_reader :config_file_search_num_dirs

    def build_action slug_str, param_h
      kls = API::Actions.const_fetch slug_str
      kls.new self, param_h
    end

    -> do  # `model`, `cache!`
      rx = /s$/
      klass = nil
      define_method :model do |*x_a|
        @model_controller_h.fetch x_a do
          k = klass[ x_a ]
          @model_controller_h[ x_a ] = k.new self
        end
      end

      alias_method :[], :model  # NOTE *SUPER* experimental

      define_method :cache! do |*x_a, &b|
        if @model_controller_h.key? x_a
          fail "already cached - #{ x_a }"
        else
          klass[ x_a ].new_valid -> o do
            o.api_client = self
            b[ o ]
          end, -> o do
            @model_controller_h[ x_a ] = o
          end, -> rsn do
            raise ::ArgumentError, rsn
          end
        end
      end

      klass = -> x_a do
        a = x_a.dup
        if rx =~ a.last
          a[ -1 ] = $~.pre_match.intern
          a << :collection
        else
          a << :controller
        end
        Models.const_fetch a
      end

    end.call

    def cached? * x_a
      @model_controller_h.key? x_a
    end
  end
end
