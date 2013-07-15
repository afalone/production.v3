require "spec_helper"

describe PdfPrintStart do
  before do
    @prod = Factory(:production, :state => 'pdc_ready')
    ResqueSpec.reset!
  end

  context "on perform" do
    it "should enqueue" do
      PdfPrintStart.perform
      PdfBookPrint.should have_queued(@prod.id)
    end
  end
end