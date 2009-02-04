require File.dirname(__FILE__) << "/searchable_record_spec_helper"
require "util"

include SearchableRecord

describe Util do
  it "should parse positive integers" do
    Util.parse_positive_int("1").should == 1
    Util.parse_positive_int("1sdfgsdf").should == 1
    Util.parse_positive_int(nil).should be_nil
    Util.parse_positive_int("0").should be_nil
    Util.parse_positive_int("-1").should be_nil
    Util.parse_positive_int("sdfgdfg").should be_nil
  end

  it "should prune and duplicate hashes" do
    str = "don't remove me"

    Util.pruned_dup({ :excess => "foobar", :preserve => str },  [ :preserve ]).should == { :preserve => str }
    Util.pruned_dup({ :excess => "foobar", "preserve" => str }, [ :preserve ]).should == { :preserve => str }

    # A contrived example of calling #to_a for the second argument.
    Util.pruned_dup({:e => "foobar", [ :p, str ] => str }, { :p => str }).should == { [:p, str ] => str }

    Util.pruned_dup({ :excess => "foobar" }, [ :preserve ]).should == { }
    Util.pruned_dup({ }, [ ]).should == { }
    Util.pruned_dup({ }, [ :preserve ]).should == { }

    lambda { Util.pruned_dup(nil, [ :foo ]) }.should raise_error(NoMethodError)
  end
end
