#!/usr/local/bin/ruby
#
# encoding: CP932
#
# 2015.05.30:KAWAI Toshikazu
#

require 'csv'
require 'stringio'

INI_FILE = 'csv_divide.ini'

class INI
  attr_reader :input_prefix, :col, :out_file_prefix, :header
  def initialize(ini_string = '')
    @out_file_prefix = {}
    StringIO.open(ini_string, 'r') {|f|
      f.each {|line|
        line.strip!
        next if line.size == 0 or line[0] == '#'
        case line
        when /^input_prefix:(.+)/
          @input_prefix = $1
#          p "input_prefix:#{@input_prefix}"
        when /^divide_column:(.+)/
          @col = $1.to_i - 1
#          p "col:#{@col}"
        when /^divided_file:([^:]+):(.+)/
          @out_file_prefix[$1] = $2
#          p @out_file_prefix
        when /^header:(.+)/
          if $1 =~ /yes/i
            @header = true
          else
            @header = false
          end
        end
      }
    }

  end
    
end

def divide(input_file, ini)
  out_files = {}
  ini.out_file_prefix.values.uniq.each {|prefix|
#    out_files[prefix] = File.open((prefix + input_file), 'w')
    out_files[prefix] = prefix + input_file
  }
  File.open(input_file, 'r') {|f|
    header_line = nil
    f.each {|line|
      if ini.header and header_line == nil
        header_line = line
        next
      end
      keyword = line.parse_csv[ini.col] || ''
      keyword.strip!
      if keyword.size > 0
        match = false
        ini.out_file_prefix.keys.each {|key|
          if /^#{key}/ =~ keyword
#            out_files[ini.out_file_prefix[key]] = File.open((ini.out_file_prefix[key] + input_file), 'w') if out_files[ini.out_file_prefix[key]] == :not_open
            unless out_files[ini.out_file_prefix[key]].respond_to? :print
              out_files[ini.out_file_prefix[key]] = File.open(out_files[ini.out_file_prefix[key]], 'w')
              out_files[ini.out_file_prefix[key]].print header_line if ini.header
            end
            out_files[ini.out_file_prefix[key]].print line
            match = true
          end
        }
        unless match
#          out_files[OTHER_KEY] = File.open((ini.out_file_prefix[OTHER_KEY] + input_file), 'w') if out_files[ini.out_file_prefix[OTHER_KEY]] == :not_open
          unless out_files[ini.out_file_prefix[OTHER_KEY]].respond_to? :print
            out_files[ini.out_file_prefix[OTHER_KEY]] = File.open(out_files[ini.out_file_prefix[OTHER_KEY]], 'w')
            out_files[ini.out_file_prefix[OTHER_KEY]].print header_line if ini.header
          end
          out_files[ini.out_file_prefix[OTHER_KEY]].print line
        end
      end
    }
  }
  out_files.values.each {|f| f.close if f.respond_to? :close}
end

OTHER_KEY = '#####other#####'

inis = []
File.open(INI_FILE, 'r') {|f|
  ini_strings = f.read
  ini_strings.split(/-{20,}/).each {|ini_string|
#    p ini_string
    inis << INI.new(ini_string)
  }
}

inis.each {|ini|

  Dir.glob(ini.input_prefix + '*').each {|file|
    divide(file, ini)
  }
}

