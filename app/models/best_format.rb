class BestFormat < ActiveRecord::Base
  establish_connection :best
  set_table_name :formats

  belongs_to :book, :class_name => "BestBook", :foreign_key => :book_id
end
