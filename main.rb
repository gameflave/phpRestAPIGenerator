$LOAD_PATH << '.'
require 'dbFileParser'
require 'apiGenerator'

db = SQL_TXT_FileParser.Parse(ARGV[0])
API_Generator.GenerateAPI(db)