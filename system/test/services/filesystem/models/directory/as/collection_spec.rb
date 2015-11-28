require_relative '../../../../../test-support'

module Skylab::System::TestSupport

  describe "[sy] - services - filesystem - models - dir - as - collection" do

    TS_[ self ]
    define_singleton_method :dangerous_memoize_, TestSupport_::DANGEROUS_MEMOIZE

    it "works" do

      _subject = services_.filesystem.directory_as_collection do | o |

        o.directory_is_assumed_to_exist = true
        o.directory_path = TestSupport_::Fixtures.files_path
        o.flyweight_class = _Whatever_Flyweight_Class
        o.kernel = :_no_kernel_
      end

      st = _subject.to_entity_stream
      _x = st.gets
      ::File.basename( _x._the_path ).should eql 'one-line.txt'  # etc.
    end

    dangerous_memoize_ :_Whatever_Flyweight_Class do

      class SFMDaC_Flyweight

        def self.new_flyweight _no_kernel  # no block
          new
        end

        def reinitialize_via_path_for_directory_as_collection path
          @_the_path = path
          NIL_  # YES
        end

        attr_reader :_the_path

        self
      end
    end
  end
end
