#
# Generate directory for the php rest api
#
module API_Generator

    #
    # Create File Structure and class for each table
    #
    # @param [Database] .GenerateAPIdb the Database structure
    #
    def API_Generator.GenerateAPI(db)
        Dir.mkdir(db.name)
        Dir.mkdir(db.name + "/model")
        Dir.mkdir(db.name + "/api")
        
        db.getTables.keys.each do |table|
            unless table == nil
                Dir.mkdir(db.name + "/api/" + table)
                GenerateTableClass(table, db, db.name + "/model/")
            end
        end
    end

    #
    # Generate a PHP class file for a given table
    # The class contain all CRUD function
    #
    # @param [String] .GenerateTableClasstable table name
    # @param [Database] db dabase structure
    # @param [String] path where to save the resulted file
    #
    def API_Generator.GenerateTableClass(table, db, path)
        fileContent = "<?php \nclass #{table.capitalize} { \n\tprivate $conn; \n\tpublic function __construct($db){ \n\t\t$this->conn = $db; \n\t}"
        fileContent.concat("\n\tconst #{table.upcase}_PER_Page = 100;")
        fileContent.concat(GenerateSelectFonction(table, db.getPrimaryCols(table)))
        fileContent.concat(GenerateSelectAllFonction(name))
        fileContent.concat(GenerateInsertFonction(table, db.getCols(table)))
        fileContent.concat(GenerateUpdateFonction(table, db.getCols(table)))
        fileContent.concat(GenerateDeleteFonction(table, db.getPrimaryCols(table)))
        
        file = File.new(path + table + ".php", "w+")
        file.syswrite(fileContent)
        file.close
    end

    def API_Generator.GenerateSelectFonction(table, pCols)
        table = table.capitalize
        params = ""
        whereParams = ""
        pCols.keys.each do |col|
            params.concat("$#{col},")
            whereParams.concat("`#{col}`=:#{col} AND ")
        end
        function = "\n\tpublic function get#{table}(#{params.chop}) \n\t{"
        function.concat("\n\t\t$query = \"SELECT * FROM `#{table}` WHERE #{whereParams.delete_suffix(" AND ")} LIMIT :first, :last\";")
        function.concat("\n\t\t$stmt = $this->conn->prepare($query);")

        pCols.keys.each do |col|
            function.concat("\n\t\t$stmt->bindValue(\":#{col}\", $#{col}, #{pCols[col]["type"]});")
        end

        function.concat("\n\t\t$stmt->bindValue(\":first\", $PageFirst#{table}, PDO::PARAM_INT);")
        function.concat("\n\t\t$stmt->bindValue(\":last\", #{table}::#{table.upcase}_PER_Page, PDO::PARAM_INT);")
        function.concat("\n\t\t$stmt->execute();")
        function.concat("\n\t\treturn $stmt->fetch(PDO::FETCH_ASSOC);")
        function.concat("\n\t}")

        return function
    end

    def API_Generator.GenerateSelectAllFonction(table)
        table = table.capitalize
        function = "\n\tpublic function get#{table}s($page) \n\t{"
        function.concat("\n\t\t$PageFirst#{table} = ($page - 1) * #{table}::#{table.upcase}_PER_Page;")
        function.concat("\n\t\t$query = \"SELECT * FROM `#{table}` LIMIT :first, :last\";")
        function.concat("\n\t\t$stmt = $this->conn->prepare($query);")
        function.concat("\n\t\t$stmt->bindValue(\":first\", $PageFirst#{table}, PDO::PARAM_INT);")
        function.concat("\n\t\t$stmt->bindValue(\":last\", #{table}::#{table.upcase}_PER_Page, PDO::PARAM_INT);")
        function.concat("\n\t\t$stmt->execute();")
        function.concat("\n\t\treturn $stmt->fetchAll(PDO::FETCH_ASSOC);")
        function.concat("\n\t}")

        return function
    end
    
    def API_Generator.GenerateInsertFonction(table, cols)
        table = table.capitalize
        params = ""
        values = ""
        cols.keys.each do |col|
            params.concat("$#{col},")
            values.concat(":#{col},")
        end

        function = "\n\tpublic function insert#{table}(#{params.chop}) \n\t{"
        function.concat("\n\t\t$query = \"INSERT INTO `#{table}` VALUES(#{values.chop})\";")
        function.concat("\n\t\t$stmt = $this->conn->prepare($query);")
        
        cols.keys.each do |col|
            function.concat("\n\t\t$stmt->bindValue(\":#{col}\", $#{col}, #{cols[col]["type"]});")
        end

        function.concat("\n\t\t$stmt->execute();")
        function.concat("\n\t}")

        return function
    end
    
    def API_Generator.GenerateUpdateFonction(table, cols)
        table = table.capitalize
        params = ""
        whereParams = ""
        setParams = ""
        cols.keys.each do |col|
            params.concat("$#{col},")
            if cols[col]["primary"]
                whereParams.concat("`#{col}`=:#{col} AND ")
            else
                setParams.concat("`#{col}`=:#{col},")
            end
        end

        function = "\n\tpublic function update#{table}(#{params.chop}) \n\t{"
        function.concat("\n\t\t$query = \"UPDATE `#{table}` SET #{setParams.chop} WHERE #{whereParams.delete_suffix(" AND ")}\";")
        function.concat("\n\t\t$stmt = $this->conn->prepare($query);")
        
        cols.keys.each do |col|
            function.concat("\n\t\t$stmt->bindValue(\":#{col}\", $#{col}, #{cols[col]["type"]});")
        end

        function.concat("\n\t\t$stmt->execute();")
        function.concat("\n\t}")

        return function
    end

    def API_Generator.GenerateDeleteFonction(table, pCols)
        table = table.capitalize
        params = ""
        whereParams = ""
        pCols.keys.each do |col|
            params.concat("$#{col},")
            whereParams.concat("`#{col}`=:#{col} AND ")
        end

        function = "\n\tpublic function delete#{table}(#{params.chop}) \n\t{"
        function.concat("\n\t\t$query = \"DELETE FROM `#{table}` WHERE #{whereParams.delete_suffix(" AND ")}\";")
        function.concat("\n\t\t$stmt = $this->conn->prepare($query);")
        
        pCols.keys.each do |col|
            function.concat("\n\t\t$stmt->bindValue(\":#{col}\", $#{col}, #{pCols[col]["type"]});")
        end

        function.concat("\n\t\t$stmt->execute();")
        function.concat("\n\t}")

        return function
    end

end