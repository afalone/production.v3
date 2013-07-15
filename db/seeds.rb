class ActiveRecord::Base
  def self.create_or_update_by(sym, *args)
    meth = "find_or_create_by_#{sym}".to_sym
    ar = self.send meth, *args
    ar.update_attributes *args
  end
end

kf_kfstore2_pathes = [
        '00', '01', '02', '03', '04', '05', '06', '07', '08', '09', '0a', '0b', '0c', '0d', '0e', '0f',
        '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '1a', '1b', '1c', '1d', '1e', '1f',
        '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '2a', '2b', '2c', '2d', '2e', '2f',
        '30', '31', '32', '33', '34', '35', '36', '37', '38', '39', '3a', '3b', '3c', '3d', '3e', '3f',
        '40', '41', '42', '43', '44', '45', '46', '47', '48', '49', '4a', '4b', '4c', '4d', '4e', '4f',
        '50', '51', '52', '53', '54', '55', '56', '57', '58', '59', '5a', '5b',       '5d', '5e', '5f',
        '60', '61', '62', '63', '64', '65', '66', '67', '68', '69', '6a', '6b', '6c', '6d', '6e', '6f',
        '70', '71', '72', '73', '74', '75', '76', '77', '78', '79', '7a', '7b', '7c', '7d', '7e', '7f'
]

kf_kfstore_pathes = [
        '5c',
        '80', '81', '82', '83', '84', '85', '86', '87', '88', '89', '8a', '8b', '8c', '8d', '8e', '8f',
        '90', '91', '92', '93', '94', '95', '96', '97', '98', '99', '9a', '9b', '9c', '9d', '9e', '9f',
        'a0', 'a1', 'a2', 'a3', 'a4', 'a5', 'a6', 'a7', 'a8', 'a9', 'aa', 'ab', 'ac', 'ad', 'ae', 'af',
        'b0', 'b1', 'b2', 'b3', 'b4', 'b5', 'b6', 'b7', 'b8', 'b9', 'ba', 'bb', 'bc', 'bd', 'be', 'bf',
        'c0', 'c1', 'c2', 'c3', 'c4', 'c5', 'c6', 'c7', 'c8', 'c9', 'ca', 'cb', 'cc', 'cd', 'ce', 'cf',
        'd0', 'd1', 'd2', 'd3', 'd4', 'd5', 'd6', 'd7', 'd8', 'd9', 'da', 'db', 'dc', 'dd', 'de', 'df',
        'e0', 'e1', 'e2', 'e3', 'e4', 'e5', 'e6', 'e7', 'e8', 'e9', 'ea', 'eb', 'ec', 'ed', 'ee', 'ef',
        'f0', 'f1', 'f2', 'f3', 'f4', 'f5', 'f6', 'f7', 'f8', 'f9', 'fa', 'fb', 'fc', 'fd', 'fe', 'ff'
]

best_kfstore2_pathes = kf_kfstore2_pathes

best_kfstore_pathes = kf_kfstore_pathes + ['bestkniga']

Output.create_or_update_by(:name, :name => 'kf', :cover_upload_basedir => '/mnt/kfstore/covers_tmp',
                           :require_testpages => false, :server_host => "10.0.0.4", :server_user => "upload",
                           :server_password => "up22load", :upload_basedir => "/mnt/store",
                           :extract_command => '/usr/local/bin/unrar'
)

Preset.create_or_update_by(:name, :name => "knigafund", :require_quote_printing => true,
                           :view_before_printing_timeout => 15000, :view_printing_timeout => 60000,
                           :view_after_printing_timeout => 500, :view_kill_process_if_timeout => true,
                           :quote_before_printing_timeout => 15000, :quote_printing_timeout => 60000,
                           :quote_after_printing_timeout => 500, :output_id => Output.find_by_name('kf').id,
                           :require_view_printing => true)

Input.create_or_update_by(:name, :name => "kf", :preset_id => Preset.find_by_name('knigafund').id,
                          :class_prefix => '', :output_id => Output.find_by_name('kf').id,
                          :source_path => File.join(BATCH_BASE_PATH, "swf"))

#Input.create_or_update_by(:name, :name => "tat", :default_preset_name => 'knigafund',
#                          :default_output_name => 'tat_kf', :class_prefix => '',
#                          :source_path => "#{File.join(BATCH_BASE_PATH, "tat")}")

#Output.create_or_update_by(:name, :name => 'tat', :cover_upload_basedir => '/mnt/kfstore/covers_tmp',
#                           :require_testpages => false#migrate params
#)

P2fline.create_or_update_by(:name, :name=>'line_2', :can_quote=>false, :can_view=>true)
P2fline.create_or_update_by(:name, :name=>'line_8', :can_quote=>true, :can_view=>true)
P2fline.create_or_update_by(:name, :name=>'line_6', :can_quote=>true, :can_view=>true)

Output.create_or_update_by(:name, :name =>"viewonly_kf", :cover_upload_basedir => '/mnt/kfstore/covers_tmp',
                           :require_testpages => false, :server_host => "10.0.0.4", :server_user => "upload",
                           :server_password => "up22load", :upload_basedir => "/mnt/store", :extract_command => '/usr/local/bin/unrar')

Preset.create_or_update_by(:name, :name => "viewonly_kf", :require_quote_printing => false,
                           :view_before_printing_timeout => 15000, :view_printing_timeout => 60000,
                           :view_after_printing_timeout => 500, :view_kill_process_if_timeout => true,
                           :require_view_printing => true, :output_id => Output.find_by_name('viewonly_kf').id)

Input.create_or_update_by(:name, :name => "viewonly_kf", :preset_id => Preset.find_by_name('viewonly_kf').id,
                          :output_id => Output.find_by_name('viewonly_kf').id, :class_prefix => 'Viewonly',
                          :source_path => "#{File.join(BATCH_BASE_PATH, "view-only")}")



Output.create_or_update_by(:name, :name =>"pdf_kf", :cover_upload_basedir => '/mnt/kfstore/covers_tmp',
                           :require_testpages => false, :server_host => "10.0.0.4", :server_user => "upload",
                           :server_password => "up22load", :upload_basedir => "/mnt/store", :extract_command => '/usr/local/bin/unrar')

Preset.create_or_update_by(:name, :name => "pdf", :require_quote_printing => false,
                           :require_view_printing => false, :output_id => Output.find_by_name('pdf_kf').id)

Input.create_or_update_by(:name, :name => "pdf_kf", :preset_id => Preset.find_by_name('pdf').id,
                          :output_id => Output.find_by_name('pdf_kf').id, :class_prefix => 'Pdf',
                          :source_path => "#{File.join(BATCH_BASE_PATH, "pdf-kf")}")

Output.create_or_update_by(:name, :name =>"pdc_kf", :cover_upload_basedir => '/mnt/kfstore/covers_tmp',
                           :require_testpages => false, :server_host => "10.0.0.4", :server_user => "upload",
                           :server_password => "up22load", :upload_basedir => "/mnt/store", :extract_command => '/usr/local/bin/unrar')

Preset.create_or_update_by(:name, :name => "pdc_kf", :require_quote_printing => false,
                           :require_view_printing => false, :output_id => Output.find_by_name('pdc_kf').id,
                           :license_text => "Эта книга принадлежит электронной библиотеке Knigafund.ru. Для ее чтения пожалуйста приобретите Вашу копию."
)

Input.create_or_update_by(:name, :name => "pdc_kf", :preset_id => Preset.find_by_name('pdc_kf').id,
                          :output_id => Output.find_by_name('pdc_kf').id, :class_prefix => 'Pdc',
                          :source_path => "#{File.join(BATCH_BASE_PATH, "pdc-kf")}")

#rgb::pdf with stamps
Output.create_or_update_by(:name, :name =>"rgb_pdf_kf", :cover_upload_basedir => '/mnt/kfstore/covers_tmp',
                           :require_testpages => false, :server_host => "10.0.0.4", :server_user => "upload",
                           :server_password => "up22load", :upload_basedir => "/mnt/store", :extract_command => '/usr/local/bin/unrar')

Preset.create_or_update_by(:name, :name => "rgb_pdf_kf", :require_quote_printing => false,
                           :require_view_printing => false, :output_id => Output.find_by_name('rgb_pdf_kf').id)

Input.create_or_update_by(:name, :name => "rgb_pdf_kf", :preset_id => Preset.find_by_name('rgb_pdf_kf').id,
                          :output_id => Output.find_by_name('rgb_pdf_kf').id, :class_prefix => 'RgbPdf',
                          :source_path => "#{File.join(BATCH_BASE_PATH, "rgb-pdf-kf")}")

#best
Output.create_or_update_by(:name, :name =>"pdc_best", :cover_upload_basedir => '/mnt/kfstore/covers_tmp',
                           :require_testpages => true, :server_host => "10.0.0.4", :server_user => "upload",
                           :server_password => "up22load", :upload_basedir => "/mnt/store", :extract_command => '/usr/local/bin/unrar')

Preset.create_or_update_by(:name, :name => "pdc_best", :require_quote_printing => false,
                           :require_view_printing => false, :output_id => Output.find_by_name('pdc_best').id,
                           :license_text => "Эта книга была приобретена на сайте bestkniga.ru. Для чтения необходимо установить лицензию. Если у Вас возникли проблемы с использованием книги, пожалуйста, обратитесь в службу технической поддержки support@bestkniga.ru"
)

Input.create_or_update_by(:name, :name => "pdc_best", :preset_id => Preset.find_by_name('pdc_best').id,
                          :output_id => Output.find_by_name('pdc_best').id, :class_prefix => 'PdcBest',
                          :source_path => "#{File.join(BATCH_BASE_PATH, "pdc-best")}")

Output.create_or_update_by(:name, :name =>"pdf_best", :cover_upload_basedir => '/mnt/kfstore/covers_tmp',
                           :require_testpages => true, :server_host => "10.0.0.4", :server_user => "upload",
                           :server_password => "up22load", :upload_basedir => "/mnt/store", :extract_command => '/usr/local/bin/unrar')

Preset.create_or_update_by(:name, :name => "pdf_best", :require_quote_printing => false,
                           :require_view_printing => false, :output_id => Output.find_by_name('pdf_best').id,
                           :license_text => "Эта книга была приобретена на сайте bestkniga.ru. Для чтения необходимо установить лицензию. Если у Вас возникли проблемы с использованием книги, пожалуйста, обратитесь в службу технической поддержки support@bestkniga.ru"
)

Input.create_or_update_by(:name, :name => "pdf_best", :preset_id => Preset.find_by_name('pdf_best').id,
                          :output_id => Output.find_by_name('pdf_best').id, :class_prefix => 'PdfBest',
                          :source_path => "#{File.join(BATCH_BASE_PATH, "pdf-best")}")

Output.create_or_update_by(:name, :name =>"flex_kf", :cover_upload_basedir => '/mnt/kfstore/covers_tmp',
                           :require_testpages => false, :server_host => "10.0.0.4", :server_user => "upload",
                           :server_password => "up22load", :upload_basedir => "/mnt/store", :extract_command => '/usr/local/bin/unrar')

Preset.create_or_update_by(:name, :name => "flex_kf", :require_quote_printing => false,
#                           :view_before_printing_timeout => 15000, :view_printing_timeout => 60000,
#                           :view_after_printing_timeout => 500, :view_kill_process_if_timeout => true,
                           :require_view_printing => true, :output_id => Output.find_by_name('flex_kf').id)

Input.create_or_update_by(:name, :name => "flex_kf", :preset_id => Preset.find_by_name('flex_kf').id,
                          :output_id => Output.find_by_name('flex_kf').id, :class_prefix => 'Flex',
                          :source_path => "#{File.join(BATCH_BASE_PATH, "flex")}")

Storage.create_or_update_by(:name, :name => 'kf_kfstore', :output_id=>Output.find_by_name('kf').id,
                            :prefix => '/mnt/kfstore', :active => true)

Storage.create_or_update_by(:name, :name => 'kf_kfstore2', :output_id=>Output.find_by_name('kf').id,
                            :prefix => '/mnt/kfstore2/knigafund', :active => true)

Storage.create_or_update_by(:name, :name => 'kf_pdf_kfstore', :output_id=>Output.find_by_name('pdf_kf').id,
                            :prefix => '/mnt/kfstore', :active => true)

Storage.create_or_update_by(:name, :name => 'kf_pdf_kfstore2', :output_id=>Output.find_by_name('pdf_kf').id,
                            :prefix => '/mnt/kfstore2/knigafund', :active => true)

Storage.create_or_update_by(:name, :name => 'kf_pdc_kfstore', :output_id=>Output.find_by_name('pdc_kf').id,
                            :prefix => '/mnt/kfstore', :active => true)

Storage.create_or_update_by(:name, :name => 'kf_pdc_kfstore2', :output_id=>Output.find_by_name('pdc_kf').id,
                            :prefix => '/mnt/kfstore2/knigafund', :active => true)

Storage.create_or_update_by(:name, :name => 'best_pdf_kfstore', :output_id=>Output.find_by_name('pdf_best').id,
                            :prefix => '/mnt/kfstore', :active => true)

Storage.create_or_update_by(:name, :name => 'best_pdf_kfstore2', :output_id=>Output.find_by_name('pdf_best').id,
                            :prefix => '/mnt/kfstore2/knigafund', :active => true)

Storage.create_or_update_by(:name, :name => 'viewonly_kf_kfstore', :output_id=>Output.find_by_name('viewonly_kf').id,
                            :prefix => '/mnt/kfstore', :active => true)

Storage.create_or_update_by(:name, :name => 'viewonly_kf_kfstore2', :output_id=>Output.find_by_name('viewonly_kf').id,
                            :prefix => '/mnt/kfstore2/knigafund', :active => true)

Storage.create_or_update_by(:name, :name => 'rgb_pdf_kf_kfstore', :output_id=>Output.find_by_name('rgb_pdf_kf').id,
                            :prefix => '/mnt/kfstore', :active => true)

Storage.create_or_update_by(:name, :name => 'rgb_pdf_kf_kfstore2', :output_id=>Output.find_by_name('rgb_pdf_kf').id,
                            :prefix => '/mnt/kfstore2/knigafund', :active => true)

Storage.create_or_update_by(:name, :name => 'pdc_best_kfstore', :output_id=>Output.find_by_name('pdc_best').id,
                            :prefix => '/mnt/kfstore', :active => true)

Storage.create_or_update_by(:name, :name => 'pdc_best_kfstore2', :output_id=>Output.find_by_name('pdc_best').id,
                            :prefix => '/mnt/kfstore2/knigafund', :active => true)

Storage.create_or_update_by(:name, :name => 'flex_kf_kfstore', :output_id=>Output.find_by_name('flex_kf').id,
                            :prefix => '/mnt/kfstore', :active => true)

Storage.create_or_update_by(:name, :name => 'flex_kf_kfstore2', :output_id=>Output.find_by_name('flex_kf').id,
                            :prefix => '/mnt/kfstore2/knigafund', :active => true)


kf_kfstore2_pathes.each do |h|
  Storage.find_by_name('kf_kfstore2').store_paths.create_or_update_by('hash_directory', :hash_directory=>h, :active => true)
end

kf_kfstore_pathes.each do |h|
  Storage.find_by_name('kf_kfstore').store_paths.create_or_update_by('hash_directory', :hash_directory=>h, :active => true)
end

kf_kfstore2_pathes.each do |h|
  Storage.find_by_name('rgb_pdf_kf_kfstore2').store_paths.create_or_update_by('hash_directory', :hash_directory=>h, :active => true)
end

kf_kfstore_pathes.each do |h|
  Storage.find_by_name('rgb_pdf_kf_kfstore').store_paths.create_or_update_by('hash_directory', :hash_directory=>h, :active => true)
end

kf_kfstore2_pathes.each do |h|
  Storage.find_by_name('viewonly_kf_kfstore2').store_paths.create_or_update_by('hash_directory', :hash_directory=>h, :active => true)
end

kf_kfstore_pathes.each do |h|
  Storage.find_by_name('viewonly_kf_kfstore').store_paths.create_or_update_by('hash_directory', :hash_directory=>h, :active => true)
end

kf_kfstore2_pathes.each do |h|
  Storage.find_by_name('kf_pdf_kfstore2').store_paths.create_or_update_by('hash_directory', :hash_directory=>h, :active => true)
end

kf_kfstore_pathes.each do |h|
  Storage.find_by_name('kf_pdf_kfstore').store_paths.create_or_update_by('hash_directory', :hash_directory=>h, :active => true)
end

kf_kfstore2_pathes.each do |h|
  Storage.find_by_name('kf_pdc_kfstore2').store_paths.create_or_update_by('hash_directory', :hash_directory=>h, :active => true)
end

kf_kfstore_pathes.each do |h|
  Storage.find_by_name('kf_pdc_kfstore').store_paths.create_or_update_by('hash_directory', :hash_directory=>h, :active => true)
end

best_kfstore2_pathes.each do |h|
  Storage.find_by_name('best_pdf_kfstore2').store_paths.create_or_update_by('hash_directory', :hash_directory=>h, :active => true)
end

best_kfstore_pathes.each do |h|
  Storage.find_by_name('best_pdf_kfstore').store_paths.create_or_update_by('hash_directory', :hash_directory=>h, :active => true)
end

best_kfstore2_pathes.each do |h|
  Storage.find_by_name('pdc_best_kfstore2').store_paths.create_or_update_by('hash_directory', :hash_directory=>h, :active => true)
end

best_kfstore_pathes.each do |h|
  Storage.find_by_name('pdc_best_kfstore').store_paths.create_or_update_by('hash_directory', :hash_directory=>h, :active => true)
end

kf_kfstore2_pathes.each do |h|
  Storage.find_by_name('flex_kf_kfstore2').store_paths.create_or_update_by('hash_directory', :hash_directory=>h, :active => true)
end

kf_kfstore_pathes.each do |h|
  Storage.find_by_name('flex_kf_kfstore').store_paths.create_or_update_by('hash_directory', :hash_directory=>h, :active => true)
end
