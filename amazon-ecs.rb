require 'optparse'
require 'yaml'
require 'amazon/ecs'
require 'pstore'

opt = OptionParser.new
OPTS = Hash.new
OPTS[:filename] = nil
OPTS[:indexfile] = "index.db"
OPTS[:configfile] = "conf.yaml"
opt.on('-f VAL', '--filename VAL'){|v| OPTS[:filename] = v}
opt.on('-i VAL', '--indexfile VAL') {|v| OPTS[:indexfile] = v}
opt.on('-c VAL', '--configfile VAL') {|v| OPTS[:configfile] = v}
opt.parse!(ARGV)

CONF = YAML.load_file(OPTS[:configfile])

Amazon::Ecs.configure do |options|
  options[:AWS_access_key_id] = CONF[:AWS_access_key_id]
  options[:AWS_secret_key] = CONF[:AWS_secret_key]
  options[:associate_tag] = CONF[:associate_tag]
  options[:country] = CONF[:country]
end

def item_search(item_id)
  waiting_time = 1
  begin
    res = Amazon::Ecs.item_search(item_id)
  rescue
    sleep waiting_time
    waiting_time = waiting_time * 2
    waiting_time = 60 if waiting_time > 60
    retry
  end

  attributes = Array.new
  res.items.each{|item|
    attribute_hashes = Array.new
    item.get_elements('ItemAttributes').each{|attribute|
      attribute_hashes.push(attribute.get_hash)
    }
    attributes.push(attribute_hashes)
  }
  item_hash = {:time_stamp => Time.now,
               :attributes => attributes}

  printf("%s\n", item_id)
  output_item_hash(item_hash)
  
  return item_hash
end

def output_item_hash(item_hash)
  printf("Time Stamp: %s\n", item_hash[:time_stamp])
  item_hash[:attributes].each{|attribute_hashes|
    attribute_hashes.each{|attribute_hash|
      attribute_hash.each{|key, value|
        printf("%s:\t%s\n", key, value)
      }
      puts if attribute_hashes.size > 1
    }
    puts if item_hash[:attributes].size > 1
  }
end


def item_controller(item_id)
  db = PStore.new(OPTS[:indexfile])
  db.transaction do
    if db.root?(item_id)
      if Time.now - db[item_id][:time_stamp] < CONF[:expire_time].to_f
        return
      else
        printf("[update] ")
      end
    else
      printf("[add] ")
    end
    db[item_id] = item_search(item_id)
  end
end

if File.pipe?(STDIN) then
  STDIN.each{|line|
    item_controller(line.strip)
  }

elsif OPTS[:filename] == nil
  item_controller(ARGV[0])
  
elsif
  File.open(OPTS[:filename]){|file|
    while line = file.gets
      item_controller(line.strip)
    end
  }
end

# items.each{|item_id, attributes|
#   p item_id
#   attributes.each{|attribute_hashes|
#     attribute_hashes.each{|attribute_hash|
#       attribute_hash.each{|key, value|
#         printf("%s:\t%s\n", key, value)
#       }
#       puts
#     }
#     puts
#   }
#   db = PStore.new(OPTS[:indexfile])
#   db.transaction do
#     db[item_id] = attributes
#   end
#   puts
# }
