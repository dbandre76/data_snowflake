CREATE OR REPLACE PROCEDURE test_snowpark()
    RETURNS STRING
    LANGUAGE PYTHON
    RUNTIME_VERSION = 3.11
    PACKAGES = ('snowflake-snowpark-python')
    HANDLER = 'main'
AS
$$
import snowflake.snowpark as snowpark

def main(session: snowpark.Session): 
    tableName = 'stg_customers'
    dataframe = session.table(tableName)
    dataframe.show()
    dataframe.write.save_as_table(
        "stg_customers_snowpark",
        mode="overwrite"
    )
    return "Load table executed successfully"
$$;

CREATE OR REPLACE PROCEDURE TEST_JAVE_SCRIPT()
RETURNS STRING
LANGUAGE JAVASCRIPT
AS
$$
var sql_insert = `
    INSERT INTO TMP_XML_RAW_FILES (file_name, xml_content)
    SELECT t.file_name, t.xml_content
    FROM (
      SELECT METADATA$FILENAME AS file_name, $1 AS xml_content
      FROM @XML
    ) t
    LEFT JOIN TMP_XML_RAW_FILES tmp
      ON t.file_name = tmp.file_name
    WHERE tmp.file_name IS NULL
    RETURNING file_name
`;
var stmt_insert = snowflake.createStatement({sqlText: sql_insert});
var result = stmt_insert.execute();

var files = [];
while (result.next()) {
    files.push(result.getColumnValue(1));
}

// Remover apenas os arquivos processados do stage
for (var i = 0; i < files.length; i++) {
    var remove_cmd = "REMOVE @XML/" + files[i] + ";";
    var stmt_remove = snowflake.createStatement({sqlText: remove_cmd});
    stmt_remove.execute();
}

return 'Arquivos processados: ' + files.join(', ');
$$;

CREATE OR REPLACE PROCEDURE LOAD_XML_AND_REMOVE_FILES()
RETURNS STRING
LANGUAGE JAVASCRIPT
AS
$$
var files = [];

// 1. Selecionar arquivos novos do stage
var sql_select = `
    SELECT METADATA$FILENAME AS file_name
    FROM @XML
    WHERE METADATA$FILENAME NOT IN (SELECT file_name FROM TMP_XML_RAW_FILES)
`;
var stmt_select = snowflake.createStatement({sqlText: sql_select});
var result = stmt_select.execute();

while (result.next()) {
    files.push(result.getColumnValue(1));
}

// 2. Fazer o insert incremental (apenas arquivos novos)
if (files.length > 0) {
    var sql_insert = `
        INSERT INTO TMP_XML_RAW_FILES (file_name, xml_content)
        SELECT METADATA$FILENAME, $1
        FROM @XML (FILE_FORMAT => (TYPE => 'CSV', FIELD_DELIMITER => NONE))
        WHERE METADATA$FILENAME IN (${files.map(f => "'" + f + "'").join(",")})
    `;
    var stmt_insert = snowflake.createStatement({sqlText: sql_insert});
    stmt_insert.execute();
}

// 3. Remover apenas os arquivos processados do stage
for (var i = 0; i < files.length; i++) {
    var remove_cmd = "REMOVE @XML/" + files[i] + ";";
    var stmt_remove = snowflake.createStatement({sqlText: remove_cmd});
    stmt_remove.execute();
}

return 'Arquivos processados: ' + files.join(', ');
$$;

CREATE OR REPLACE PROCEDURE REMOVE_ALL_XML_FILES()
RETURNS STRING
LANGUAGE SQL
AS
$$
    REMOVE @XML/multicloud/xml/**/*.xml;
    RETURN 'Todos os arquivos XML removidos!';
$$;