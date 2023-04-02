require 'mongoid'
require 'smarter_csv'
require 'money'

class CsvLoader
  attr_reader :path_to_data, :header_mapping, :source

  def initialize(path_to_data, header_mapping, source)
    @path_to_data = path_to_data 
    @header_mapping = header_mapping
    @source = source
  end

  def load
    SmarterCSV.process(@path_to_data, { :chunk_size => 100, convert_values_to_numeric: false }) do |chunk|
      chunk.each do |h|
        h[:source] = @source
      end
      # chunk = chunk.reject { |k, v| k == :transaction_date && (v.nil? || v.empty?) }  
      Expense.create!(perform_money_conversion(chunk))
    end
  end

  private

  def perform_money_conversion(chunk)
    # look out for $ in the string in the future
    chunk.map do |hash|
      amount = hash[:amount].gsub('-', '') # because the csv from chase gives values like "-30.11"
      hash[:amount] = Money.from_amount(amount.to_f, 'USD').cents
      hash
    end

  end

end