require 'mongoid'
require 'smarter_csv'
require 'money'
require_relative 'header_mappings'
require_relative 'temp_file_transformed_headers'

class CsvLoader
  include HeaderMappings
  attr_reader :path_to_data, :header_mapping, :source

  def initialize(path_to_data, source)
    @path_to_data = path_to_data 
    @source = source
    @header_mapping = get_header_mapping
    @converted_file = ConvertedHeadersFile.new(path_to_data)
  end

  def load
    config = {
      chunk_size: 100,
      convert_values_to_numeric: false,
      # key_mappings: @header_mapping wait until v 2.0 when better key mapping options are available
    }

    SmarterCSV.process(@converted_file.temp_path, config) do |chunk|
      chunk.each do |h|
        h[:source] = @source
      end
      
      Expense.create!(perform_money_conversion(chunk))
    end

    @converted_file.unlink_and_close_temp
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

  def get_header_mapping
    raise "No header mapping defined for #{@source}" unless HeaderMappings.constants.include?(@source.upcase.to_sym)
    HeaderMappings.const_get(@source.upcase)
  end

end