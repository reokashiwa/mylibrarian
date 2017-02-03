mylibrarian
====

Mylibrarian is integration tools from several web services related to books such as Amazon Web Service, Honya Club, Manga Oh, and so on.

## Description

* [amazon-ecs.rb][https://github.com/reokashiwa/mylibrarian/blob/master/amazon-ecs.rb] - according to ISBN, ASIN, this script get attributes of the item and store to a local database file (pstore).
* [pstore.rb][https://github.com/reokashiwa/mylibrarian/blob/master/pstore.rb] - Read a local database file and manage (delete, output, and so on) data.

## Demo

## VS. 

## Requirement

* amazon/ecs
* highline/import

## Usage

* 'amazon-ecs.rb' [-f|--filename <filename of item IDs>] [-i|--indexfile <filename of database>] [-c|--configfile <filename of configuration>]
* 'pstore.rb' [-f|--filename <filename of item IDs>] [-i|--indexfile <filename of database>]
* 'pstore.rb'[-d|--delete <item_id to delete>]
* 'pstore.rb'[-r|--readable <item_id to output to STDOUT>]

## Install

## Contribution

## Licence

## Author

[reokashiwazaki](https://github.com/reokashiwazaki)

