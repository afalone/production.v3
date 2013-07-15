class P2fline < ActiveRecord::Base
  belongs_to :production

  def clean_processes
    raise "nyi"
  end
end
