class AddRestartFieldsToProductions < ActiveRecord::Migration
  def self.up
    add_column :productions, :source_changed, :boolean, :default => false
    add_column :productions, :need_full_restart, :boolean, :default => false
    add_column :productions, :need_restart, :boolean, :default => false
    Production.update_all "source_changed = 'f'", "source_changed is null"
    Production.update_all "need_full_restart = 'f'", "need_full_restart is null"
    Production.update_all "need_restart = 'f'", "need_full_restart is null"
  end

  def self.down
    remove_column :productions, :source_changed
    remove_column :productions, :need_full_restart
    remove_column :productions, :need_restart
  end
end
