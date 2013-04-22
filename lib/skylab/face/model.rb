module Skylab::Face

  module Model

    # is it a good idea to extend the plugin library?  let's just see..

    def self.enhance model_class, & def_blk

      story = nil
      Face::Services::Headless::Plugin._enhance model_class, -> do
        Story.new model_class
      end, -> s { story = s },
      begin
        cnd = Conduit_.new
        cnd.instance_variable_set :@face_h, ::Hash[ Conduit_::A.zip( [
          -> do
            story.do_memoize = true
          end
        ] ) ]
        cnd
      end, def_blk
    end

    class Conduit_ < Services::Headless::Plugin::Conduit_
      ( A = %i|
        do_memoize
      | ).each do |i|
        define_method i do |*a|  # no blocks by desing
          @face_h.fetch( i ).call( *a )
        end
      end

      # One_Shot_ .. yes we could but we won't yet
    end

    class Story < Services::Headless::Plugin::Story
      attr_accessor :do_memoize
    end
  end
end
