Factory.define(:book) do |b|
  b.name { [%w(DDCC ISBN)[rand(2)], (rand(9)+1).to_s, (rand(999)+1).to_s, %w(0 1 2 3 4 5 6 7 8 9 X)[rand(11)]].join('-') }
end

Factory.sequence(:page_no) do |n|
  n
end
Factory.define(:page) do |p|
  p.page_no { Factory.next(:page_no) }
  p.association :book, :factory=>:book
end

Factory.sequence(:input_name) do |n|
  n.to_s
end
Factory.define :input do |b|
  b.name "dflt"
  b.source_path File.join(Rails.root, "test", "data", 'dflt')
  b.is_active true
#  nm = Factory.next(:input_name)
#  b.name { "tst_#{nm}" }
#  b.source_path { File.join(Rails.root, "test", "data", nm) }
end

Factory.define(:production) do |p|
  p.association :book, :factory=>:book
  p.association :input, :factory=>:input
end