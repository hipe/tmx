module Skylab::TestSupport

  Data = ::Module.new

  module Data::Universal_Fixtures

    class << self

      def [] sym
        dir_pathname.join( lookup_box.fetch sym ).to_path
      end

      def members
        lookup_box.get_names
      end

    private

      def lookup_box
        Lookup_box__[]
      end

      def lookup sym
        Lookup_box__[].fetch sym
      end
    end

    Lookup_box__ = Callback_.memoize do

      bx = Callback_::Box.new

      ::Dir.glob( "#{ dir_pathname.to_path }/*" ).each do | path |

        bn = ::File.basename path
        ext = ::File.extname bn
        _stem = bn[ 0 .. - ( 1 + ext.length ) ]

        bx.add _stem.gsub( DASH_, UNDERSCORE_ ).intern, bn

      end

      bx
    end
  end
end
