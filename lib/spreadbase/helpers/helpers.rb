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

  # Currently generic helper class
  #
  module Helpers

    # Prints the 2d-array in a nice, fixed-space table
    #
    # _params_:
    #
    # +rows+::                  2d-array of values.
    #                           Empty arrays generate empty strings.
    #                           Entries can be of different sizes; nils are used as filling values to normalize the rows to the same length.
    #
    # _options_:
    #
    # +row_prefix+::            Prefix this string to each row.
    # +with_header+::           First row will be separated from the remaining ones.
    #
    # +formatting_block+::      If passed, values will be formatted by the block; otherwise, #inspect will be called.
    #
    def pretty_print_rows( rows, options={}, &formatting_block )
      row_prefix   = options[ :row_prefix   ] || ''
      with_headers = options[ :with_headers ]

      output = ""

      formatting_block = lambda { | value | value.to_s } if ! block_given?

      if rows.size > 0
        max_column_sizes = [ 0 ] * rows.map( &:size ).max

        # Compute maximum widths

        rows.each do | values |
          values.each_with_index do | value, i |
            formatted_value       = block_given? ? yield( value ) : value.inspect
            formatted_value_width = formatted_value.chars.to_a.size

            max_column_sizes[ i ] = formatted_value_width if formatted_value_width > max_column_sizes[ i ]
          end
        end

        # Print!

        output << row_prefix << '+-' + max_column_sizes.map { | size | '-' * size }.join( '-+-' ) + '-+' << "\n"

        print_pattern = '| ' + max_column_sizes.map { | size | "%-#{ size }s" }.join( ' | ' ) + ' |'

        rows.each_with_index do | row, row_index |
          # Ensure that we always have a number of values equal to the max width
          #
          formatted_row_values = ( 0 ... max_column_sizes.size ).map do | column_index |
            value = row[ column_index ]

            block_given? ? yield( value ) : value.inspect
          end

          output << row_prefix << print_pattern % formatted_row_values << "\n"

          if with_headers && row_index == 0
            output << row_prefix << '+-' + max_column_sizes.map { | size | '-' * size }.join( '-+-' ) + '-+' << "\n"
          end
        end

        output << row_prefix << '+-' + max_column_sizes.map { | size | '-' * size }.join( '-+-' ) + '-+' << "\n"
      end

      output
    end

  end

end