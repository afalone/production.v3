class CreateOutputs < ActiveRecord::Migration
  def self.up
    create_table :outputs do |t|
      t.string :name, :null => false

      t.string :server_host
      t.string :server_user
      t.string :server_password
      t.string :upload_basedir
      t.boolean :require_testpages,       :default => false, :null => false
      t.string :cover_upload_basedir
      t.string :extract_command,         :default => "rar", :null => false
      t.string :md5_command

      t.timestamps
    end
  end

  def self.down
    drop_table :outputs
  end
end
