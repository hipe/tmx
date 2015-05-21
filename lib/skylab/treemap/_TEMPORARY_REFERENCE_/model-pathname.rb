module Skylab::Treemap

  class Models::Pathname < ::Pathname # (was [#028])

    def is_missing_required_force
      @is_missing_required_force[ self ]
    end

    def relative_path_from *a     # if you want to have these
      ::Pathname.new( self ).relative_path_from( *a ) # shiny constructors..
    end                           # then for now we want obtrusive errors

 private

    def initialize path_x, is_missing_required_force
      super path_x
      @is_missing_required_force = is_missing_required_force
    end
  end
end