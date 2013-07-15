require "spec_helper"

describe PdfBookPrint do
  before do
    @prod = Factory(:production, :state => 'pdc_ready')
    ResqueSpec.reset!
  end

  context "on perform" do
    it "should process pdf" do
      @prod.should_receive(:process_pdf)
      PdfBookPrint.perform(@prod.id)
    end
    it "should enqueue finish" do
      PdfBookPrint.perform(@prod.id)
      PdfFinish.should have_queued(@prod.id)
    end
    it "should not raise" do
      lambda { PdfBookPrint.perform(@prod.id) }.should_not raise_exception
    end
  end
end