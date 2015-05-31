#!/usr/local/bin/ruby
# encoding: CP932
#
# 2015.05.30:KAWAI Toshikazu
#

require 'csv'
require 'stringio'

INI_FILE = 'csv_divide.ini'

class INI
  attr_reader :input_prefix, :col, :out_file_prefix
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
        end
      }
    }
=begin
    raise "INI file ERROR keys not defined" if @keys == nil
    raise "INI file ERROR file not defined" if @file_prefix == nil and (@org == nil or @ref == nil)
    raise "INI FILE ERROR prefix and (org_file, ref_file) both degined" if @file_prefix and (@org or @ref)
    if @org == nil and @ref == nil
      set_org_ref
    end
    if @out == nil
      @out = 'diff_' + File.basename(@org, ".*") + '_' + File.basename(@ref, ".*") + '.csv'
    end
  end
  
  private
  def set_org_ref
    org_mtime = ref_mtime = Time.new(0)     
    Dir.glob(@file_prefix + '*').each {|file|
      mtime = File.stat(file).mtime
      if mtime > org_mtime
        org_mtime = mtime
        @org = file
        if mtime > ref_mtime
          org_mtime = ref_mtime
          ref_mtime = mtime
          @org = @ref
          @ref = file
        end
      end
    }
=end

  end
    
end

inis = []
File.open(INI_FILE, 'r') {|f|
  ini_strings = f.read
  ini_strings.split(/-{20,}/).each {|ini_string|
    inis << INI.new(ini_string)
  }
}
p inis

exit

org = {}
org_keys = Set.new
ref = {}
ref_keys = Set.new

File.open(ini.out, 'w') {|of|

  File.open(ini.org, 'r') {|f|
    f.each {|line|
      k = key(line, ini.keys)
      of.puts "same key #{k} found in org file. new record is used" if org_keys.include? k
      org_keys << k
      org[key(line, ini.keys)] = line
    }
  }

  File.open(ini.ref, 'r') {|f|
    f.each {|line|
      k = key(line, ini.keys)
      of.puts "same key #{k} found in ref file. new record is used" if ref_keys.include? k
      ref_keys << k
      ref[key(line, ini.keys)] = line
    }
  }
  
  of.puts "from #{ini.org} to #{ini.ref}"
  (org_keys - ref_keys).each {|k|
    of.print "-," + org[k]
  }

  (ref_keys - org_keys).each {|k|
    of.print "+," + ref[k]
  }
}