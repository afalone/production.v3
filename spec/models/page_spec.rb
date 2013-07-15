require 'spec_helper'

describe Page do
  before do
    @page = Factory(:page)
  end
  specify {@page.should be_respond_to(:book)}
  specify {@page.should be_respond_to(:page_no)}
  specify {@page.page_no.should be_kind_of(Numeric)}
  specify { Factory.build(:page, :book_id=>nil).should_not be_valid }
end
