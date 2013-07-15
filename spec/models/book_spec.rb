require 'spec_helper'

describe Book do
  it "should have subclasses in list " do
    Book.subclasses.each{|k| [Book, KfBook, RgbBook, PdcBook, ViewonlyBook].should be_include(k) }
  end

  #check valid names
  context "when name invalid" do
    specify { Book.new(:name=>'DDC-0-0001-0').should_not be_valid }
    specify { Book.new(:name=>"DDC-0-0001-0\n").should_not be_valid }
    specify { Book.new(:name=>'DDCC -0-0001-0').should_not be_valid }
    specify { Book.new(:name=>'DDCC-0-0001-Х').should_not be_valid }
  end

  context "when name valid" do
    specify { Book.new(:name=>'DDCC-0-0001-0').should be_valid }
    specify { Book.new(:name=>'ISBN-0-0001-0').should be_valid }
    specify { Book.new(:name=>'DDCC-0-0001-X').should be_valid }
  end


  describe "state_machine" do
    before do
      @book = Factory(:book)
    end
    specify { @book.should be_respond_to(:state)}

    it "should create new book in :started state" do
      Book.new.state.should == 'started'
    end
    #state machine methods checks
  end

  share_examples_for(:abbyy) do

  end

  share_examples_for(:p2fview) do

  end
end
