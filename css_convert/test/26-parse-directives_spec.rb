require_relative 'test-support'

describe "[cssc] when parsing directives" do

  Skylab::CSS_Convert::TestSupport[ self ]
  use :want_event

  it "should parse platonic ideal" do

    tree = parse_directives_in_file_ fixture_path_ '001-platonic-ideal.txt'

    expect( tree.first ).to eql(:merge_statement)

    itf, sif, su, ls = tree.children(
      :in_the_folder, :styles_in_files, :styles_under, :merge_list)

    expect( itf[:path] ).to eql "test/fixture-files/css"
    expect( sif[:left] ).to eql "documentation.css"
    expect( sif[:right] ).to eql "pygments.css"
    expect( su[:left] ).to eql ".highlight"
    expect( su[:right] ).to eql ".pre"
    expect( ls.size ).to eql 4

    _act = ls[ 0..3 ].map do |x|
      [ x[ :left ], x[ :right ] ]
    end

    _exp = [
      %w( .keyword .k ),
      %w( .default .nc ),
      %w( .keyword .p ),
      [ '.keyword', nil ],
    ]

    expect( _act ).to eql _exp
  end

  it "should parse with a minimal set of directives" do

    tree = parse_directives_in_file_ fixture_path_ '002-minitessimal.txt'

    tree[ :in_the_folder ].nil? || fail

    tree[ :styles_under ].nil? || fail

    expect( ["red.css", "blue.css"] ).to eql(
      tree[:styles_in_files].children(:left, :right))
    md = tree[:merge_list]
    expect( md.length ).to eql 1
    expect( md.first.first ).to eql :catchall_pairing
  end
end
