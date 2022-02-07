module API_Generator

    def API_Generator.GenerateAPI(db)
        Dir.mkdir(db.getName)
        Dir.mkdir(db.getName + "/model")
        Dir.mkdir(db.getName + "/api")
        
        db.getTables.keys.each do |key|
            unless key == nil
                Dir.mkdir(db.getName + "/api/" + key)
                GenerateTableClass(key, db, db.getName + "/model/")
            end
        end
    end

    def API_Generator.GenerateTableClass(name, db, path)
        fileContent = "<?php \nclass #{name.capitalize} { \n\tprivate $conn; \n\tpublic function __construct($db){ \n\t\t$this->conn = $db; \n\t}"
        fileContent.concat("\n\tconst #{name.upcase}_PER_Page = 100;")
        fileContent.concat(GenerateSelectFonction(name, db.getPrimaryCols(name)))
        fileContent.concat(GenerateSelectAllFonction(name))
        fileContent.concat(GenerateInsertFonction(name, db.getCols(name)))
        fileContent.concat(GenerateUpdateFonction(name, db.getCols(name)))
        fileContent.concat(GenerateDeleteFonction(name, db.getPrimaryCols(name)))
        
        file = File.new(path + name + ".php", "w+")
        file.syswrite(fileContent)
        file.close
    end

    def API_Generator.GenerateSelectFonction(name, pCols)
        name = name.capitalize
        name = name.capitalize
        params = ""
        whereParams = ""
        pCols.keys.each do |col|
            params.concat("$#{col},")
            whereParams.concat("`#{col}`=:#{col} AND ")
        end
        function = "\n\tpublic function get#{name}(#{params.chop}) \n\t{"
        function.concat("\n\t\t$query = \"SELECT * FROM `#{name}` WHERE #{whereParams.delete_suffix(" AND ")} LIMIT :first, :last\";")
        function.concat("\n\t\t$stmt = $this->conn->prepare($query);")

        pCols.keys.each do |col|
            function.concat("\n\t\t$stmt->bindValue(\":#{col}\", $#{col}, #{pCols[col]["type"]});")
        end

        function.concat("\n\t\t$stmt->bindValue(\":first\", $PageFirst#{name}, PDO::PARAM_INT);")
        function.concat("\n\t\t$stmt->bindValue(\":last\", #{name}::#{name.upcase}_PER_Page, PDO::PARAM_INT);")
        function.concat("\n\t\t$stmt->execute();")
        function.concat("\n\t\treturn $stmt->fetch(PDO::FETCH_ASSOC);")
        function.concat("\n\t}")

        return function
    end

    def API_Generator.GenerateSelectAllFonction(name)
        name = name.capitalize
        function = "\n\tpublic function get#{name}s($page) \n\t{"
        function.concat("\n\t\t$PageFirst#{name} = ($page - 1) * #{name}::#{name.upcase}_PER_Page;")
        function.concat("\n\t\t$query = \"SELECT * FROM `#{name}` LIMIT :first, :last\";")
        function.concat("\n\t\t$stmt = $this->conn->prepare($query);")
        function.concat("\n\t\t$stmt->bindValue(\":first\", $PageFirst#{name}, PDO::PARAM_INT);")
        function.concat("\n\t\t$stmt->bindValue(\":last\", #{name}::#{name.upcase}_PER_Page, PDO::PARAM_INT);")
        function.concat("\n\t\t$stmt->execute();")
        function.concat("\n\t\treturn $stmt->fetchAll(PDO::FETCH_ASSOC);")
        function.concat("\n\t}")

        return function
    end
    
    def API_Generator.GenerateInsertFonction(name, cols)
        name = name.capitalize
        params = ""
        values = ""
        cols.keys.each do |col|
            params.concat("$#{col},")
            values.concat(":#{col},")
        end

        function = "\n\tpublic function insert#{name}(#{params.chop}) \n\t{"
        function.concat("\n\t\t$query = \"INSERT INTO `#{name}` VALUES(#{values.chop})\";")
        function.concat("\n\t\t$stmt = $this->conn->prepare($query);")
        
        cols.keys.each do |col|
            function.concat("\n\t\t$stmt->bindValue(\":#{col}\", $#{col}, #{cols[col]["type"]});")
        end

        function.concat("\n\t\t$stmt->execute();")
        function.concat("\n\t}")

        return function
    end
    
    def API_Generator.GenerateUpdateFonction(name, cols)
        name = name.capitalize
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

        function = "\n\tpublic function update#{name}(#{params.chop}) \n\t{"
        function.concat("\n\t\t$query = \"UPDATE `#{name}` SET #{setParams.chop} WHERE #{whereParams.delete_suffix(" AND ")}\";")
        function.concat("\n\t\t$stmt = $this->conn->prepare($query);")
        
        cols.keys.each do |col|
            function.concat("\n\t\t$stmt->bindValue(\":#{col}\", $#{col}, #{cols[col]["type"]});")
        end

        function.concat("\n\t\t$stmt->execute();")
        function.concat("\n\t}")

        return function
    end

    def API_Generator.GenerateDeleteFonction(name, pCols)
        name = name.capitalize
        params = ""
        whereParams = ""
        pCols.keys.each do |col|
            params.concat("$#{col},")
            whereParams.concat("`#{col}`=:#{col} AND ")
        end

        function = "\n\tpublic function delete#{name}(#{params.chop}) \n\t{"
        function.concat("\n\t\t$query = \"DELETE FROM `#{name}` WHERE #{whereParams.delete_suffix(" AND ")}\";")
        function.concat("\n\t\t$stmt = $this->conn->prepare($query);")
        
        pCols.keys.each do |col|
            function.concat("\n\t\t$stmt->bindValue(\":#{col}\", $#{col}, #{pCols[col]["type"]});")
        end

        function.concat("\n\t\t$stmt->execute();")
        function.concat("\n\t}")

        return function
    end

end