require 'mongoid'
require 'smarter_csv'

# Mongoid.load!(File.join(File.dirname(__FILE__), 'config', 'mongoid.yml')) # need to change path

class CsvLoader
  attr_reader :path_to_data, :header_mapping, :source

  def initialize(path_to_data, header_mapping, source)
    @path_to_data = path_to_data
    @header_mapping = header_mapping
    @source = source
  end

  def load
    SmarterCSV.process(@path_to_data, { :chunk_size => 100 }) do |h|
      # load it into mongo
      h[:source] = @source
    end
  end

end