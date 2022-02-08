#
# Functions to parse TXT files from phpMyAdmin
#
module SQL_TXT_FileParser 

    #
    # Given the path to a TXT files from phpMyAdmin re turn a Database object filled with data from the TXT
    #
    # @param [String] .Parsepath TXT files from phpMyAdmin
    #
    # @return [Database] Database object filled with data from the TXT
    #
    def SQL_TXT_FileParser.Parse(path)
        file = File.open(path);

        db = Database.new
        currentTable = nil
        lineSkipCounter = 0

        file.each_line do |line|
            if lineSkipCounter > 0
                lineSkipCounter -= 1
                next
            end

            if(line.start_with?("==="))
                db.name = line.split.last
                next
            end
           
            if(line.start_with?("=="))
                if(currentTable == line.split.last) then next end
                
                currentTable = line.split.last
                db.addTable(currentTable)
                lineSkipCounter = 4
                next
            end

            unless line.chomp.empty?
                db.addCol(currentTable, line.split("|")[1][/([A-z])\w+/], GetColType(line.split("|")[2]), line.start_with?("|//**"))
            end
        end

        return db
    end
    
    #
    # Return the correct type for PDO string sanatization
    #
    # @param [String] .GetColTypetypeString String containing the SQL column type
    #
    # @return [String] PDO sanatization type
    #
    def SQL_TXT_FileParser.GetColType(typeString)
        if(typeString.include?("int"))
            return "PDO::PARAM_INT"
        end

        return "PDO::PARAM_STR"
    end

    #
    # A class to store SQL Database stucture
    #
    class Database

        attr_accessor :name

        def initialize()
            @tables = Hash.new
        end

        def addTable(tableName)
            @tables[tableName] = Hash.new
        end
        def getTables
            return @tables
        end
        
        def addCol(table, col, type, isPrimary)
            @tables[table][col] = {"type" => type, "primary" => isPrimary}
        end
        def getCols(table)
            return @tables[table]
        end
        def getPrimaryCols(table)
            pCol = Hash.new

            @tables[table].each_key do |col|
                if @tables[table][col]["primary"]
                    pCol[col] = @tables[table][col]
                end
            end

            return pCol
        end
    end
end