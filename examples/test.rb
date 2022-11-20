#!/usr/bin/env ruby

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org/'
  gem 'rails'
  gem 'pg'
  gem 'factory_girl_rails'
  gem "copy_pasta", path: "."
end

require 'active_record'
require 'pg'

dbname = 'testdbsinglefile'
conn = PG.connect(dbname: 'postgres')
conn.exec("DROP DATABASE #{dbname}")
conn.exec("CREATE DATABASE #{dbname}")
conn.close

ActiveRecord::Base.establish_connection(adapter: 'postgresql', database: dbname)
ActiveRecord::Base.logger = Logger.new($stdout)

ActiveRecord::Schema.define do
  create_table :book_stores, force: true do |t|
    t.string :name
    t.timestamps
  end
  
  create_table :books, force: true do |t|
    t.string :name
    t.references :book_store
    t.timestamps
  end

  create_table :categories, force: true do |t|
    t.string :name
    t.timestamps
  end

  create_table :categorizations, force: true do |t|
    t.references :book
    t.references :category
    t.boolean :primary, default: false, null: false
    t.timestamps
  end
end

class BookStore < ActiveRecord::Base
  has_many :books
end

class Book < ActiveRecord::Base
  belongs_to :book_store
  has_many :categorizations
  has_many :categories, through: :categorizations
end

class Category < ActiveRecord::Base
  has_many :categorizations
  has_many :books, through: :categorizations

  def self.primaries
    Category.joins(:categorizations).merge(Categorization.primaries)
  end
end

class Categorization < ActiveRecord::Base
  belongs_to :book
  belongs_to :category

  def self.primaries
    where(primary: true)
  end
end

FactoryGirl.define do
  factory :book_store do
    name 'Awesome Bookshop'

    trait :with_scifi do
      after(:create) do |book_store, _|
        book = Book.create!(name: 'Three Body Problem')
        book.categorizations << Categorization.create!(category: create(:science_category), book: book, primary: true)
        book_store.books << book
      end
    end
  end

  factory :book do
    name 'Thing Explainer: Complicated Stuff in Simple Words'

    trait :with_primary_category do
      after(:create) do |book, _|
        book.categorizations << Categorization.create!(category: create(:science_category), book: book, primary: true)
      end
    end

    trait :with_secondary_category do
      after(:create) do |book, _|
        book.categorizations << Categorization.create!(category: create(:fun_facts_category), book: book, primary: false)
      end
    end
  end

  factory :science_category, class: Category do
    name 'Science & Scientists'
  end

  factory :fun_facts_category, class: Category do
    name 'Trivia & Fun Facts'
  end
end

require 'minitest/autorun'
require 'copy_pasta'

class CategoryTest < Minitest::Test
  # def test_primary_categories
  #   FactoryGirl.create(:book, :with_primary_category, :with_secondary_category)

  #   assert_equal [Category.find_by_name('Science & Scientists')], Category.primaries
  # end

  def test_basic_copy
    store_1 = FactoryGirl.create(:book_store, :with_scifi)
    store_2 = FactoryGirl.create(:book_store)

    puts "====================="
    puts BookStore.all.inspect
    puts Book.all.inspect
    puts Category.all.inspect
    puts Categorization.all.inspect
    puts"======================"
    
    result = CopyPasta.build do
      source store_1
      destination store_2
      # to   to_board # nil will create a new board.
      with_tables %i[books categories categorizations]

      # on :comments, data: from_board.lists.flat_map(&:active_comments)
      # on :activities, data: from_board.lists.flat_map(&:activities)
    end

    puts "====================="
    puts BookStore.all.inspect
    puts Book.all.inspect
    puts Category.all.inspect
    puts Categorization.all.inspect
    puts"======================"
    asset_equal result, []
  end
end


# CopyPasta.build do
#   puts 'Hey i got here'
# end
