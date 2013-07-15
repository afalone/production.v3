class Storage < ActiveRecord::Base
  belongs_to :output
  has_many :store_paths

  def avail?
    self.active?
  end

  def path_for_book(ext_book)
    self.store_paths.detect{|p| p.contain_book?(ext_book) }
  end
  #todo chg avail? to handle free space
#  ALLOWED_FREE_SIZE = 30.gigabytes #move to db field?
#  require "sys/filesystem"
#
#  def avail?
#    return false unless self.is_active?
#    if !File.directory?(self.prefix) or Sys::Filesystem.mount_point(self.prefix) == '/' #unmounted
#      self.update_attributes :is_active=>false, :block_reason=>"unmounted at #{Time.now}"
#      puts "non-active #{self.name}"
#      return false
#    end
#    stat = Sys::Filesystem.stat(Sys::Filesystem.mount_point(self.prefix))
#    if stat.blocks_available * stat.fragment_size < ALLOWED_FREE_SIZE
#      self.update_attributes :is_active => false, :block_reason=>"space avail only #{} at #{Time.now}"
#      puts "no space avail at #{self.name}"
#      return false
#    end
#    true
#  end

end
