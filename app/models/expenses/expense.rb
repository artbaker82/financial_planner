class Expense
  include Mongoid::Document
  field :transaction_date, type: Date
  field :post_date, type: Date
  field :description, type: String
  field :category, type: StringifiedSymbol
  field :type, type: StringifiedSymbol
  field :amount, type: Integer # store all values as cents
  field :source, type: String # (Chase, Discover)

  # validations
  validates :transaction_date, presence: true
  validates :amount, presence: true
  validates :source, presence: true
end