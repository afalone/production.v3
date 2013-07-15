class KnigafundPage < ExternalPage
  establish_connection :kf
  set_table_name :pages

  belongs_to :book, :class_name => 'KnigafundBook', :foreign_key => :book_id
end
