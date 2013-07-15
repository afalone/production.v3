#require "rmagick"

def unzip_format_file(fname)
  puts "zip"
  dirname = File.join("/tmp", File.basename(fname))
  Dir.mkdir dirname
  `unzip #{fname} -d #{dirname}`
  fname = Dir[File.join(dirname, "*.fb2")].first
  puts fname
  return dirname, fname
end

def make_testpages_from_xml(fname, max_pages, position, code)
  images = []
  File.open(fname) do |f|
    doc = Nokogiri::XML(f, nil, 'utf-8')
    doc.remove_namespaces!
    sections = []
    doc.xpath('//body/section').each { |section| sections << section }
    titles = []
    puts sections.size
    sections.each_with_index do |section, idx|
      ttl = section.xpath('//title')
      titles[idx] = ttl.first.content unless ttl.blank?
      puts "idx #{idx}"
      im = generate_pages(code, section.content, titles[idx] || '', position, max_pages)
      position += im.size
      im.each{|i| images << i }
      break if images.size >= max_pages
    end
  end
  images
end

def generate_test_pages(max_pages, filename, code)
  #return if self.book.testpages.length >= max_pages
      begin
        position = 1
        fname = filename
        dirname = nil
        puts "#{fname}"
        if `file '#{fname}'` =~ /Zip archive data/
          dirname, fname = unzip_format_file(fname)
        end
        file_type = `file #{fname}`
        if file_type =~ /XML/ or file_type =~ / text, with very long lines/
          images = make_testpages_from_xml(fname, max_pages, position, code)
        else
          puts file_type
        end
      ensure
        FileUtils.rm_r dirname, :verbose=>true if dirname
      end
  images
end


  MAX_PAGE_STRINGS = 200

  def build_images_from_paragraph(gc, paragraph, params = {:height=>370, :width=>270, :used => 0}, last_img = nil) #returns last_height, last_img, arr of imgs(without last_img)
    images = []
    img = last_img || Magick::Image.new(300, 400)
    words = paragraph.mb_chars.split(/\s+/)
    used = params[:used]
    strings = []
    until words.empty?
      cnt = 1
      while cnt <= words.size and gc.get_multiline_type_metrics(img, "#{words[0, cnt].join(' ')} ").width < params[:width]
        cnt += 1
      end
      cnt -= 1 unless gc.get_multiline_type_metrics(img, "#{words[0, cnt].join(' ')} ").width < params[:width]
      cnt += 1 if cnt == 0
      strings << "#{words[0, cnt].join(' ')} "
      cnt.to_i.times {  words.shift }
    end
    #in strings para strings
    until strings.empty?
      cnt = 1
      while gc.get_multiline_type_metrics(img, strings[0, cnt].join("\n")).height < (params[:height] - used) and cnt <= strings.size
        cnt += 1
      end
      cnt -= 1 unless gc.get_multiline_type_metrics(img, strings[0, cnt].join("\n")).height < (params[:height] - used)
      puts "#{cnt} lines"
      if cnt == 0
        used = 0
        images << img
        img = Magick::Image.new(300, 400)
      else
        h = gc.get_type_metrics(img, strings[0]).height
        gc.annotate(img, params[:width], params[:height], 15, h + used + 15, strings[0, cnt].join("\n"))
        used += gc.get_multiline_type_metrics(img, strings[0, cnt].join("\n")).height
      end
      if used >= params[:height]
        images << img
        img = Magick::Image.new(300, 400)
        used = 0
      end
      cnt.times { strings.shift }
    end
    return used, img, images
  end


  def generate_pages(book_code, section_text, title_text, last_pos, max_pages)
    return [] if last_pos > max_pages
    files_list = []
    need_pages = max_pages - last_pos + 1
    font_type = "/usr/share/fonts/truetype/msttcorefonts/tahoma.ttf"
    font_style = Magick::NormalStyle
    gc = Magick::Draw.new do
      self.encoding = "utf-8"
      self.font = font_type #_family
      self.font_style = font_style
      self.pointsize = 12
    end
    title_gc = Magick::Draw.new do
      self.encoding = "utf-8"
      self.font = font_type #_family
      self.font_style = font_style
      self.font_weight = Magick::BoldWeight
      self.pointsize = 14
    end

    used = 0
    last_img = nil
    images = []
    title_paras = title_text.split("\n")
    title_paras.each do |title_para|
      break if images.size >= need_pages
      break if title_para.blank?
      used, last_img, img_arr = build_images_from_paragraph(title_gc, title_para, {:height=>370, :width=>270, :used =>used}, last_img)
      used += 8 #after paragraph gap
      puts "title used #{used}"
      img_arr.each{|i| images << i }
    end
    paras = section_text.split("\n")
    paras.each do |para|
      break if images.size >= need_pages
      used, last_img, img_arr = build_images_from_paragraph(gc, para, {:height=>370, :width=>270, :used =>used}, last_img)
      used += 8 #after paragraph gap
      puts "used #{used}"
      img_arr.each{|i| images << i }
    end
    images << last_img if last_img and images.size < need_pages
    i = last_pos
    images = images[0, need_pages]
    puts "pages count #{images.size}"
    images.each do |img|
      img.write("/tmp/#{book_code}_test#{sprintf("%04d", i)}.jpg")
      files_list << "/tmp/#{book_code}_test#{sprintf("%04d", i)}.jpg"
      i += 1
    end
    #files_list.each{|n| FileUtils.rm_f n }
    files_list.each{|n| puts "#{n} #{File.stat(n).size}" }
    files_list
  end

namespace :homebrew do
  desc "generate fb2-preview for bestbook"
  task :mk_preview_for, [:book_code] => :environment do |t, args|
    puts args[:book_code]
    book = BestBook.locate_book(args[:book_code])
    exit 1 unless book
    outp = Output.find_by_name('pdf_best')
    pth = outp.calc_upload_path(book)
    puts pth
    exit 1 if Dir[File.join(pth, '*.zip')].empty?
    fl = Dir[File.join(pth, '*.zip')].first
    puts fl
    flist = generate_test_pages(5, fl, book.uniq_code)
    flist.each{|n| FileUtils.cp n, pth }
    flist.each{|n| FileUtils.rm n, :verbose => true}
  end

  desc "gen testpages for prepared"
  task :mk_preview_prepared => :environment do
    BestBook.where("state = 'prepared'").each do |book|
      puts `rake homebrew:mk_preview_for[#{book.uniq_code}]`
    end
  end

  desc "clean archives from kf"
  task :clean_kf_rars => :environment do
    puts KnigafundBook.where("status = 'published' and updated_at < ?", 2.days.ago).count
    count = 0
    KnigafundBook.where("status = 'published' and updated_at < ?", 2.days.ago).find_each(:batch_size => 10) do |kb|
      kd = File.join("/mnt/kfstore2/knigafund", kb.hash_directory, kb.name)
      kd = File.join("/mnt/kfstore", kb.hash_directory, kb.code) unless File.exist?(kd)
      if File.exist?(File.join(kd, "#{kb.code}.rar"))
        puts "#{kb.id} #{kb.code} cleaning"
        count += 1
        FileUtils.rm (File.join(kd, "#{kb.code}.rar"))
      end
    end
    puts "#{count} cleaned"
  end
end