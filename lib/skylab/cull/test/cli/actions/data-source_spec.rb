require_relative 'test-support'

module Skylab::Cull::TestSupport::CLI::Actions::DataSource

  ::Skylab::Cull::TestSupport::CLI::Actions[ DataSource_TS_ = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  describe "#{ Cull }::CLI::Actions::DataSource" do

    extend DataSource_TS_

    as :no, /\Awtvr data-source list: no config file in the 3 dirs #{
      }starting from \.\z/, :nonstyled

    it "`list` in a directory with no nearby config - explains it" do

      from_inside_empty_directory do |_|

       invoke %w(ds li)

       expect :no

      end
    end

    as :empty_jsonesque, /\A\[ \]\z/, :nonstyled, :out

    it "`list` in a directory that is freshly initted - empty json list" do

      from_inside_a_directory_with :freshly_initted do

        invoke %w(ds li)

        expect :empty_jsonesque

      end
    end

    # as :wiz

    as :too_few, /\Awrong number of arguments \(0 for 2\)\z/i, :nonstyled

    # (don't fully test usage / invite at a detailed level here, it is
    # outside the scope of this node and will become a liability spec.
    # this is what the very short symbol names means.)

    as :usg, /\Ausage: wtvr data-source add\b/i, :styled

    as :invt, /\ATry wtvr data-source (?:-h add|add -h) for help/i, :styled

    it "`add` with no args" do
      from_inside_fixture_directory :freshly_initted do
        invoke %w(ds add)
      end
      expect :too_few, :usg, :invt
    end

    as :too_many, /\Awrong number of arguments \(3 for 2\)\z/i, :nonstyled

    it "`add` with too many args" do
      from_inside_fixture_directory :freshly_initted do
        invoke %w(ds add one two three)
      end
      expect :too_many, :usg, :invt
    end

    as :invalid_option, /\Ainvalid option: --foo\z/i, :styled

    it "`add` with strange opts" do
      from_inside_fixture_directory :freshly_initted do
        invoke %w(ds add one two --foo wiz --bar baz)
      end
      expect :invalid_option, :invt
    end

    as :invalid_aggregate, /\Awtvr data-source add: name was #{
      }invalid\. tags\[0\] contains #{
      }invalid character, must be lowercase alphanumeric for now #{
      }\(had "one,two"\)\.\z/, :nonstyled

    it "`add` with invalid arg and invalid opt" do
      from_inside_fixture_directory :freshly_initted do
        invoke %w(ds add Safarina! foo -t one,two)
      end
      expect :invalid_aggregate
    end

    as :wont_clobber, /\Awtvr data-source add: data source already #{
      }exists, won't clobber - foo\z/, :nonstyled

    it "`add` with pre-existing name" do
      from_inside_fixture_directory :add_foo_bar do
        invoke %w(ds add foo bar)
      end
      expect :wont_clobber
    end

    as :confirmation, /\Awtvr data-source add: inserted into list - "foo"\z/,
      :nonstyled

    as :updating,
      %r{\Aupdating \./\.cullconfig \.\. done \(\d\d\d? bytes\)\.\z},
      :nonstyled

    it "`add` valid to empty collection" do
      from_inside_a_directory_with :freshly_initted do
        invoke %w(ds add foo bar -t some-tag)
      end
      expect :confirmation, :updating
    end

    it "`add` valid (prepend) to collection with 1 item" do
      from_inside_a_directory_with :with_fuzz_biff do
        invoke %w(ds add foo bar)
      end
      expect :confirmation, :updating
      contents = sandboxed_tmpdir.join( '.cullconfig' ).read
      idx_b4 = contents.index( '[data-source "foo"]' ) or fail( 'where?' )
      idx_af = contents.index( '[data-source "fuz"]' ) or fail( 'where?' )
      ( idx_b4 < idx_af ).should eql( true )
    end
  end
end
