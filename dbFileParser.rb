module SQL_TXT_FileParser

    def SQL_TXT_FileParser.Parse(path)
        file = File.open(path);

        db = DataBase.new
        currentTable = nil

        file.each_line do |line|
            if(line.start_with?("==="))
                db.name = line.split.last
                next
            end
            if(line.start_with?("=="))
                if(currentTable == line.split.last)
                    next
                end
                currentTable = line.split.last
                db.addTable(currentTable)
                next
            end
            unless line.chomp.empty? or line.start_with?("|--") or line.start_with?("|Colonne|")
                db.addCol(currentTable, line.split("|")[1][/([A-z])\w+/], GetColType(line.split("|")[2]), line.start_with?("|//**"))
            end
        end

        return db
    end
    
    def SQL_TXT_FileParser.GetColType(typeString)
        if(typeString.include?("int"))
            return "PDO::PARAM_INT"
        end

        return "PDO::PARAM_STR"
    end

    class DataBase

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

        def to_s
            p @tables
        end
    end
end