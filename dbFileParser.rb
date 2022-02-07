module SQL_TXT_FileParser

    def SQL_TXT_FileParser.Parse(path)
        file = File.open(path);

        db = DataBase.new
        currentTable = nil

        file.each_line do |line|
            if(line.start_with?("==="))
                db.setName = line.split.last
                next
            end
            if(line.start_with?("=="))
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

        def initialize()
            @tables = Hash.new
        end

        def setName=(value)
            @name = value
        end
        def getName
            return @name
        end

        def addTable(name)
            @tables[name] = Hash.new
        end
        def addCol(table, name, type, isPrimary)
            @tables[table][name] = {"type" => type, "primary" => isPrimary}
        end
        
        def getTables
            return @tables
        end

        def getCols(table)
            return @tables[table]
        end
        def getPrimaryCols(table)
            pCol = Hash.new

            @tables[table].keys.each do |col|
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