module Skylab::Face

  API::Action::Proc = -> prok do
    # make a proxy to wrap around a proc. make it quack like an API action.
    API::Action::Proc_::Isomorphic_.new prok
  end

  module API::Action::Proc_
  end

  class API::Action::Proc_::Isomorphic_

    -> do  # `initialize`

      h = {
        opt: [ ],
        req: [ :required ]
      }

      define_method :initialize do |prok|
        @proc = prok
        @constants = ::Module.new
        Services::Basic::Field::Box.enhance @constants do
          meta_fields( * API::Action::Param::METAFIELDS_ )
          fields( * prok.parameters.map do |orr, nn|
            [ nn, * h.fetch( orr ) ]
          end )
        end
      end
    end.call

    def normalize y, p_h
      @provided_keys_a = p_h ? p_h.keys : [ ]
      instance_exec y, p_h, & API::Action::FUN.normalize
    end

    def has_field_box
      true
    end
    private :has_field_box

    def field_box
      @constants.field_box
    end
    private :field_box

    def normalization_failure_line msg
      raise ::ArgumentError, msg
    end
    private :normalization_failure_line

    def execute
      @proc.call( * @provided_keys_a.map do |k|
        instance_variable_get field_box.fetch( k ).as_host_ivar
      end )
    end
  end
end
