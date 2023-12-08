# server.rb
require "sinatra"
require "sinatra/namespace"
require "mongoid"

# db setup
Mongoid.load! "mongoid.config"

# models
class Book
  include Mongoid::Document

  field :title, type: String
  field :author, type: String
  field :isbn, type: String

  validates :title, presence: true
  validates :author, presence: true
  validates :isbn, presence: true

  index({ title: "text" })
  index({ isbn: 1 }, { unique: true, name: "isbn_index" })

  scope :title, ->(title) { where(title: /^#{title}/i) }
  scope :isbn, ->(isbn) { where(isbn: isbn) }
  scope :author, ->(author) { where(author: author) }
end

# Endpoints
# get "/"

namespace "/api/v1" do
  before do
    content_type "application/json"
  end

  get "/books" do
    books = Book.all

    [:title, :isbn, :author].each do |filter|
      books = books.send(filter, params[filter]) if params[filter]
    end

    books.to_json
  end
end
