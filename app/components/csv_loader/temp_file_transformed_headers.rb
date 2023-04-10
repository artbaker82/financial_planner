require 'tempfile'
require_relative 'header_mappings'
# hopefully don't need to do this when Smartercsv v2 comes out
class ConvertedHeadersFile
  include HeaderMappings

  attr_reader :temp, :temp_path

  def initialize(path)
    @path = path
    @file = File.open(path, 'r:bom|utf-8')
    @temp = Tempfile.new('temp')
    @mapping = get_mapping
    @converted_headers = get_converted_headers
    build_temp_file_with_converted_headers
    @temp.rewind
  end

  def temp_path
    @temp.path
  end

  def unlink_and_close_temp
    @temp.close
    @temp.unlink 
  end

  def build_temp_file_with_converted_headers
    @temp.puts(@converted_headers.join(','))
    @temp.write(@file.read) #don't worry about other headers because we have not called rewind on the og file.
  end

  def get_converted_headers
    headers = @file.gets.chomp.split(',')
    converted_headers = headers.map { |header| @mapping[header] || header }
  end

  def get_mapping
    mappings = HeaderMappings.constants
    # get union of all mappings
    mappings.each_with_object({}) do |mapping, joined_mapping|
      mapping = HeaderMappings.const_get(mapping)
      joined_mapping.merge!(mapping)
    end

  end
end
