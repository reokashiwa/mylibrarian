# -*- coding: utf-8 -*-

require 'optparse'
require 'pstore'
require 'highline/import'

opt = OptionParser.new
OPTS = Hash.new
OPTS[:indexfile] = "index.db"
OPTS[:mode] = :show
opt.on('-f VAL', '--filename VAL'){|v| OPTS[:filename] = v}
opt.on('-i VAL', '--indexfile VAL') {|v| OPTS[:indexfile] = v}
opt.on('-d', '--delete') {OPTS[:mode] = :delete}
opt.on('-r', '--readable') {OPTS[:mode] = :readable}
opt.parse!(ARGV)

def human_readable_output(item_id)
  db = PStore.new(OPTS[:indexfile])
  db.transaction do
    if db.root?(item_id)
      db[item_id][:attributes].each{|attribute_hashes|
        attribute_hashes.each{|attribute_hash|
          next if attribute_hash['ProductGroup'] == 'eBooks'
          printf("%s", attribute_hash['Author'])
          if attribute_hash.has_key?('Creator')
            printf("，%s", attribute_hash['Creator'])
          end
          printf("「%s」\n", attribute_hash['Title'])
        }
      }
    else
      printf("[No Records]:%s\n", item_id)
    end
  end
end

case OPTS[:mode]
when :readable

  if File.pipe?(STDIN) then
    STDIN.each{|line|
      human_readable_output(line.strip)
    }
  elsif OPTS[:filename] == nil
    human_readable_output(ARGV[0])
    
  elsif
    File.open(OPTS[:filename]){|file|
      while line = file.gets
        human_readable_output(line.strip)
      end
    }
  end

when :show
  db = PStore.new(OPTS[:indexfile])
  db.transaction do
    db.roots.each{|item_id|
      p item_id
      printf("Time Stamp: %s\n", db[item_id][:time_stamp])
      db[item_id][:attributes].each{|attribute_hashes|
        attribute_hashes.each{|attribute_hash|
          attribute_hash.each{|key, value|
            printf("%s:\t%s\n", key, value)
          }
          puts if attribute_hashes.size > 1
        }
        puts if db[item_id][:attributes].size > 1
      }
    }
  end

when :delete
  db = PStore.new(OPTS[:indexfile])
  db.transaction do

    targets = Array.new
    db.roots.each{|name|
      targets.push(name) if name =~ Regexp.new(ARGV[0])
    }

    targets.each{|target|
      if db.root?(target)
        p target
        printf("%s\n", db[target])
        #p 'yes' if HighLine.agree('Do it? [Y/n]')
        db.delete(target) if HighLine.agree('Do it? [Y/n]')
      else
        printf("name %s does not exist.\n", target)
      end
    }
  end
else
end
