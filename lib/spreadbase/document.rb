# encoding: UTF-8

=begin
Copyright 2012 Saverio Miroddi saverio.pub2 <a-hat!> gmail.com

This file is part of SpreadBase.

SpreadBase is free software: you can redistribute it and/or modify it under the
terms of the GNU Lesser General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

SpreadBase is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along
with SpreadBase.  If not, see <http://www.gnu.org/licenses/>.
=end

module SpreadBase # :nodoc:

  # Represents the abstraction of a document, merging both the file and the
  # document metadata concepts.
  #
  class Document

    attr_accessor :document_path

    attr_accessor :tables

    # Currently contains only the style includining column widths
    # Format:
    #
    #   { '<name>' => '<width>' }
    #
    attr_accessor :column_width_styles # :nodoc:

    # _params_:
    #
    # +document_path+::               (nil) Document path; if not passed, an empty document is created.
    #
    # _options_:
    #
    # +force_18_strings_encoding+::   ('UTF-8') on ruby 1.8, when converting to UTF-8, assume the strings are using the specified format.
    # +floats_as_bigdecimal+::        (false) decode floats as BigDecimal instead of Float
    #
    def initialize( document_path=nil, options={} )
      @document_path = document_path
      @options       = options.clone

      if @document_path && File.exists?( document_path )
        document_archive = IO.read( document_path )
        decoded_document = Codecs::OpenDocument12.new.decode_archive( document_archive, options )

        @column_width_styles = decoded_document.column_width_styles
        @tables              = decoded_document.tables
      else
        @column_width_styles = []
        @tables              = []
      end
    end

    # Saves the document to the disk; before saving, it's required:
    # - to have at least one table
    # - to have set the documenth path, either during the initialization, or using the #document_path accessor.
    #
    # _options_:
    #
    # +prettify+::                   Prettifies the content.xml file before saving.
    #
    def save( options={} )
      options = @options.merge( options )

      raise "At least one table must be present" if @tables.empty?
      raise "Document path not specified"        if @document_path.nil?

      document_archive = Codecs::OpenDocument12.new.encode_to_archive( self, options )

      File.open( @document_path, 'wb' ) { | file | file << document_archive }
    end

    # _options_:
    #
    # +with_headers+::        Print the tables with headers.
    #
    def to_s( options={} )
      options.merge!( :row_prefix => '  ' )

      tables.inject( '' ) do | output, table |
        output << "#{ table.name }:" << "\n" << "\n"

        output << table.to_s( options ) << "\n"
      end
    end

  end

end