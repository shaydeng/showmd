
## 说明 ##

　　`Elasticsearch SQL` 的介绍与学习内容

## 内容 ##

### 标识符与关键字 ###

　　每个语言语法都有自己特有的，关于标识符定义与命名等规则，或使用注意事项等。

 + `Elasticsearch SQL` 引擎每次只能接收一个查询命令。
    - 当前版本，不能同时发送多个命令，也不存在并发可能

 + `Token` （单词或文字），可以是关键字（如 `SELECT`）、标识符（带引号或不带引号）、文本或特殊字符（通常是分隔符）。

    - 单词之间通常使用空白（如空格、制表符）分隔

#### 关键字 ####

　　所谓 `关键字`，意思是由 `SQL 语言`本身定义使用的 `单词`（或标记），例如查询语句：

```sql
 SELECT * FROM table
``` 

 + `SELECT`、`*`、`FROM` 都是 `SQL` 所定义的关键字
 + `table` 则称为 `标识符`，通常用来标识某种 `实体`，例如 `表`、`字段` 等等
 + 无论是关键字，还是标识符，都需要遵循相同的文法结构，但两者之间有个比较大的区别：

    - 关键字不区分大小写，换言之：`FROM` 与 `fRoM` 会被看作同一个关键字（不区分）
    - 标识符则区分大小写，也就是 `MyTable` 与 `myTable` 是两回事（两个不同的标识符）

 + 为了区分关键字与标识符，通常的建议是：**`关键字`** 使用大写。如上面的示例所示

#### 标识符 ####

　　除了在上面 `关键字` 所涉及的内容之外，在使用标识符时要留意，标识符有两种表示形态：**不带双引号** 与 **带双引号**

　　下面是两个示例：

```sql
 SELECT ip_address FROM "hosts-*"
```
```sql
 SELECT "from" FROM "<logstash-{now/d}>"
```

 + `ip_address` 是一个正常的标识符，不需要带引号，而 `hosts-*` 带有特殊字符，通常会要求带上引号来界定
 + `from` 需要带引号，是因为与 `SQL` 的关键字 `FROM` 产生冲突（引起歧义），所以必须带引号以示区别

#### 数据类型 ####

| Elasticsearch type | Elasticsearch SQL type | SQL type | SQL precision |
|-|-|-|-|
| null | null | NULL | 0 |
| boolean | boolean | BOOLEAN | 1 |
| byte | byte | TINYINT | 3 |
|short | short | SMALLINT | 5 |
|integer | integer | INTEGER | 10 |
|long | long | BIGINT | 19 |
|double | double | DOUBLE | 15 |
|float | float | REAL | 7 |
|half_float | half_float | FLOAT | 3 |
|scaled_float | scaled_float | DOUBLE | 15 |
|keyword | keyword | VARCHAR | 32,766 |
|text | text | VARCHAR | 2,147,483,647 |
|binary | binary | VARBINARY | 2,147,483,647 |
|date | datetime | TIMESTAMP | 29 |
|ip | ip | VARCHAR | 39 |
|object | object | STRUCT | 0 |
|nested | nested | STRUCT | 0 |

　　还有一些类型，不存在于 `Elastisearch` 存储当中，但可以在查询过程中使用的类型：（如查询时将数据转成这些类型，或结果转成这些类型）

|SQL type | SQL precision |
|-|-|
| date | 29 |
| time | 18 | 
| interval_year | 7 | 
| interval_month| 7 | 
| interval_day | 23 | 
| interval_hour | 23 | 
| interval_minute | 23 | 
|interval_second | 23 |
|interval_year_to_month | 7 |
|interval_day_to_hour | 23 |
|interval_day_to_minute | 23 |
|interval_day_to_second | 23 |
|interval_hour_to_minute | 23 |
|interval_hour_to_second | 23 |
|interval_minute_to_second | 23 |
|geo_point | 52 |
|geo_shape | 2,147,483,647 |
|shape  | 2,147,483,647 |

#### 字面量（常量） ####

　　字面量（`Literals`），通常指数据类型，目前 `Elasticsearch SQL` 支持两种类型：**String** 和 **Number**

 + 字符串字面量（String literals）：使用单引号括起来的，固定长度的任意数量字符

    - 示例：`'Test'`、`'Giant Robot'`、`'2014 Length'`、
    - 如果字符串中出现单引号，则使用多一个单引号来转义
        + 例如：`Caption EO's Voyage` 中间出现了一个单引号，此时正确表示为：**Caption EO''s Voyage** 即再加一个单引号

 + 数值字面量（Numeric Literals）：数值通常包括十进制数和科学计数法

    - 示例

        ```
        1969    -- 整数
        3.14    -- 十进制数（小数）
        .1234   -- 小数点开始的十进制数
        4E5     -- 科学计数法
        1.2e-3  -- 科学计数法
        ```
    - 所有小数都会自动识别为 `double` 类型；整数优先识别为 `integer` 类型，无法处理再调整为 `long` 型。

 + 类型转换，当涉及到不同的类型时，需要显式提供类型的转换

    - `CAST(expression AS data_Type)`：类型转换方法，将表达式的值转为 `data_type` 指定的类型，如果转换失败会显示错误
        + 示例：

            ```sql
            CAST('123' AS INT)     -- 字符串转整数
            CAST(123 AS VARCHAR)   -- 整数转字符串
            CAST('2018-05-19T11:23:45Z' AS TIMESTAMP)  -- 字符串转日期时间类型
            ```

    - `expression::data_type`：这是 `CAST` 的简化版（语法糖），如果转换失败会返回错误
        + 示例：

            ```sql
             '123'::INT     -- 字符串转整数
             123::VARCHAR   -- 整数转字符串
             '2018-05-19T11:23:45Z'::TIMESTAMP  -- 字符串转日期时间类型
            ```

    - `CONVERT(expression, data_type)`：与 `CAST` 使用相同，不同的是支持 `ODBC` 类型

#### 单引号与双引号 ####

　　要注意区分两者的使用，**单引号是字符串的定界符**，**双引号是关键字或标识符的定界符**，不要搞乱了。

#### 特殊符号 ####

　　下面是一些常见的，用于特定用途的符号：

| 符号 |  用途 |
|-|-|
| * | 星号，常用作通配符。如在某些上下文中表示表的所有字段。也可以用作某些聚合函数的参数等 |
| , | 逗号，常用于列表或数组中元素分隔（枚举） |
| . | 点号，用于数值常量或分隔标识符限定符（目录、表、列名等） |
| () | 括号，用于特定的SQL命令、函数声明或强制优先权 |

#### 运算符 ####

　　下面是 `Elastisearch SQL` 中使用的运算符：

| 运算符 | 关联位置 | 说明 |
|-|-|-|
| . | 左边 | 限定分隔符，如 user.name，name 被限定属于 user |
| :: | 左边 | 类型转换 |
| +- | 右边 | 一元加减（数字文字符号） |
| */% | 左边 | 乘、除、模运算 |
| +- | 左边 | 加法、减法 |
| BETWEEN IN LIKE | | 范围包含、字符串匹配 |
| < > <= >= = <=> <> != | | 关系运算符 |
| NOT | 右边 | 逻辑非 |
| AND | 左边 | 逻辑与 |
| OR  | 左边 | 逻辑或 |

　　注意：
 + `<=>` 运算符，又称 `太空船运算符`。与 `=` 相似的比较运算，相等返回 `1`，不等返回 `0`。但与 `=` 又有区别，此运算符能与 `NULL` 进行比较，而 `=` 是无法处理与 `NULL` 比较的。

> ('a' <=> NULL) 相当于 ('a' IS NULL)，但 ('a' = NULL) 就没意义

 + `<>` 与 `!=` 等效。（ `<>` 是 `ANSI-92 SQL` 标准定义，而 `!=` 则是等效操作，有些数据库系统并不支持此操作）

#### 注释 ####

　　`Elasticsearch SQL` 支持两种注释符号，下面用示例说明：

```sql
  -- 我是行注释，使用双减号

  /* <-- 这是开始，类似 Java 或 C 的多行注释，

     中间可以有多行

     结束使用 --> */
```

### SQL 命令 ###

　　目前 `Elasticsearch SQL` 支持下面几个命令：

 + DESCRIBE TABLE ：获取表信息（索引结构信息）

 + SELECT ： 数据查询

 + SHOW COLUMNS ：显示表字段（索引字段映射信息）

 + SHOW FUNCTIONS ：显示所支持的函数

 + SHOW TABLES ：显示表（索引）

#### DESCRIBE TABLE ####

　　本命令的功能是显示索引的字段映射（类型），等价于 `SHOW COLUMNS` 命令（可看作这个命令的别名）

 + 命令范式

    ```sql
    DESCRIBE <table identifier | like pattern>

    -- 可以将 DESCRIBE 缩写成 DESC
    DESC <table identifier | like pattern>
    ```
    - **table identifier**：就是索引名称，可以是一个索引，也可以是多个使用双引号界定的名称（之间使用逗号分隔）
        + 示例：`emp`（单个索引）；`"user,ap_info,config*"`（用双引号界定的一组索引）
    
    - **like pattern**：即 `like + 带通配符字符串` 的匹配形式
        + 示例：`like 'emp%'`（相当于前缀匹配）；`like 'emp!%'`

 + 使用示例

    ```sql
     -- 最简单的形式
     DESCRIBE emp;

     -- 显示一组
     DESC "emp,ap_infos,sysconfig"

     -- 使用 like 匹配
     DESC like "emp%"
    ```

 + 下面一个结果示例，理解命令的最终显示

    ```
        column       |     type      |    mapping
    --------------------+---------------+---------------
    birth_date          |TIMESTAMP      |datetime
    dep                 |STRUCT         |nested
    dep.dep_id          |VARCHAR        |keyword
    dep.dep_name        |VARCHAR        |text
    dep.dep_name.keyword|VARCHAR        |keyword
    dep.from_date       |TIMESTAMP      |datetime
    dep.to_date         |TIMESTAMP      |datetime
    emp_no              |INTEGER        |integer
    first_name          |VARCHAR        |text
    first_name.keyword  |VARCHAR        |keyword
    ```
    即字段名称， `SQL Type`，`Elastic Type`

#### SHOW COLUMNS ####

　　显示索引字段映射的命令，与上面的 `DESC` 命令一致。

 + 命令范式

    ```sql
    SHOW COLUMNS [ FROM | IN ]?
        [table identifier | 
        [LIKE pattern] ]
    ```

 + 使用示例

    ```sql
    SHOW COLUMNS IN emp
    ```  

#### SHOW TABLES ####

　　显示索引类型

 + 命令范式

    ```sql
    SHOW TABLES
        [INCLUDE FROZEN]?   
        [table identifier | 
        [LIKE pattern ]]?
    ```
    - **INCLUDE FROZEN**：可选，使用时会显示 `frozen` （冻结）索引

 + 使用示例

    ```sql
    -- 显示全部（对本用户有效）索引
    SHOW TABLES;

    -- 仅显示某个索引
    SHOW TABLES emp;

    -- 显示一组索引
    SHOW TABLES "emp,user";

    -- 使用 LIKE 进行匹配
    SHOW TABLES KIKE 'emp%'
    ```

 + 结果示例，下面是一个结果，可以了解本命令的使用

    ```
    SHOW TABLES;

        name      |     type      |     kind
    ---------------+---------------+---------------
    emp            |BASE TABLE     |INDEX
    employees      |VIEW           |ALIAS
    library        |BASE TABLE     |INDEX
    ```

#### SHOW FUNCTIONS ####

　　显示 `Elasticsearch SQL` 所支持的函数

 + 命令范式

    ```aql
    SHOW FUNCTIONS [LIKE pattern?]?
    ```

 + 使用示例

    ```sql
    -- 显示所有
    SHOW FUNCTIONS;

    SHOW FUNCTIONS LIKE 'ABS';

    -- 下划线表示0或1个字符
    SHOW FUNCTIONS LIKE 'A__';

    -- 通配符
    SHOW FUNCTIONS LIKE 'A%';
    ```

 + 一个查询结果示例

    ```
    SHOW FUNCTIONS;

        name       |     type
    -----------------+---------------
    AVG              |AGGREGATE
    COUNT            |AGGREGATE
    FIRST            |AGGREGATE
    FIRST_VALUE      |AGGREGATE
    LAST             |AGGREGATE
    LAST_VALUE       |AGGREGATE
    MAX              |AGGREGATE
    MIN              |AGGREGATE
    SUM              |AGGREGATE
    KURTOSIS         |AGGREGATE
    MAD              |AGGREGATE
    PERCENTILE       |AGGREGATE
    PERCENTILE_RANK  |AGGREGATE
    SKEWNESS         |AGGREGATE
    STDDEV_POP       |AGGREGATE
    SUM_OF_SQUARES   |AGGREGATE
    VAR_POP          |AGGREGATE
    HISTOGRAM        |GROUPING
    CASE             |CONDITIONAL
    COALESCE         |CONDITIONAL
    GREATEST         |CONDITIONAL
    ```

#### SELECT 命令 ####

　　并没有实现完整的 `SELECT` 语句的语法，而是实现了核心的功能。

 + 命令范式

    ```sql
    SELECT select_expr [, ...]
    [ FROM table_name ]
    [ WHERE condition ]
    [ GROUP BY grouping_element [, ...] ]
    [ HAVING condition]
    [ ORDER BY expression [ ASC | DESC ] [, ...] ]
    [ LIMIT [ count ] ]
    [ PIVOT ( aggregation_expr FOR column IN ( value [ [ AS ] alias ] [, ...] ) ) ]
    ```
    - **select_expr**：能够支持表达式、字段名或通配符 `*`。
        + 表达式并不仅仅是简单的加减之类，还可以是函数。使用 `SHOW FUNCTIONS` 可以列出能使用的函数
            ```sql
              SELECT COUNT(*) AS c FROM emp
            ```

        + 支持关键字 `AS`，为表达式或字段提供一个重命名方式。一方面能提高可读性；另一方面避免出现相同的名称。

    - **FROM table_name [[AS] alias]**：这是 `FROM` 子句，指示数据源（索引或表名）。
        + **table_name**：索引名称，也可以是别名，并支持 `索引名称范式`。当 `table_name` 为一组索引、带通配符或会与关键字同名时，需要使用双引号来界定。如 `"emp,user"`、`"emp*"`等
        + **[AS] alias**：别名（或重命名），常用于简化或消除歧义。当提供一个 `alias` 时，原来的名称将会被隐藏，此时原索引的字段都必须用此别名来引用。（ `FROM User AS u` 时，则每个 `User` 的字段都要 `u` 来引用，如 `u.name`）

    - **WHERE condition**：`where` 条件子句，相当于过滤器的作用。`condition` 为逻辑表达式，最终的计算结果会得到一个 `boolean`（布尔值），只有代入表达式其计算结果为 `true` 时，才会被返回
        ```sql
          SELECT * FROM emp WHERE emp_no = 10001;
        ```

    - **GROUP BY grouping_element [, ...]**：`GROUP BY` 子句，即分组子句。
        + **grouping_element**：可以是字段名；字段的别名；`select_expr` 字段列表中的序号，甚至是表达式；
        + 下面是一些示例
            ```sql
             -- 简单的字段名
             SELECT * FROM emp GROUP BY gender

             -- 使用序号，其中 2 表示字段列的第二个字段，即 gender。（ emp_no 为第一个）
             SELECT emp_no,gender FROM emp GROUP BY 2;

             -- 别名
             SELECT emp_no,gender AS g FROM emp GROUP BY g

             -- 字段列表中出现的表达式，要注意：此时表达式应该定义一个别名，以能引用
             SELECT emp_no,gender AS g, ROUND((MIN(salary)/100)) AS s FROM emp GROUP BY s;
            ```
        + **implicit grouping**：隐式分组。有些场合，即使不显式提供 `GROUP BY` 子句，也隐含着分组操作（隐式分组），通常这种分组仅返回一行数据，下面是一些示例：（特别是涉及到统计计算，即聚合计算的场景）
            ```sql
             -- 统计记录数，（隐含）整个索引作为一组，返回一行（只有一个字段）结果
             SELECT COUNT(*) AS count FROM emp;

             -- 多个聚合函数
             SELECT MIN(salary) AS min, MAX(salary) AS max, AVG(salary) AS avg, COUNT(*) AS count FROM emp;
            ```

    - **HAVING condition**：`HAVING` 子句。此子句仅用于有 `GROUP BY` 子句或 `隐式分组` 场合，目的是对分组内容的过滤筛选。
        + 本子句与 `WHERE` 子句有着相同的行为，不同的是过滤对象不同。
            - `WHERE` 子句对每一行都有效（过滤每一行），`HAVING` 子句仅对分组有效（过滤分组）
            - `WHERE` 子句在分组之前进行过滤，只有符合条件的才进行分组，`HAVING` 子句在分组后进行过滤，返回符合条件的分组记录

        + 使用示例
            ```sql
              -- 过滤分组，只会返回 记录数在 15 ~ 20 的分组，少于或大于此数的分组统计记录将不会返回
              SELECT languages AS l, COUNT(*) AS c FROM emp GROUP BY l HAVING c BETWEEN 15 AND 20;

              -- 复杂一些，GROUP BY 的字段并没有出现在查询结果字段列表中（但在查询表 emp 中）
              SELECT MIN(salary) AS min, MAX(salary) AS max, MAX(salary) - MIN(salary) AS diff FROM emp GROUP BY languages HAVING diff - max % min > 0 AND AVG(salary) > 30000
            ```
        
        + 隐式分组情形下，即使没有 `GROUP BY` 子句，依然可以使用 `HAVING` 子句
            - 更直接一点，凡是只返回一行数据的查询（特别是聚合统计），都可以使用 `HAVING` 子句（默认整体为一个分组）
            - 使用 `HAVING` 子句的结果是，如果条件符合，会返回这行记录；条件不符合则返回 `0` 条件记录（什么也不返回）
            ```sql
              -- 聚合，统计最大值与最小值，结果只会返回一行（不存在多个最大值或最小值），使用 HAVING 子句
              SELECT MIN(salary) AS min, MAX(salary) AS max FROM emp HAVING min > 25000;
            ```

    - **ORDER BY expression [ ASC | DESC ] [, ...]**：`ORDER BY` 子句用于排序。
        + **expression** 排序表达式可以是一个字段；一个字段表达式别名；字段列表的序号；甚至是一个得分（别忘记了搜索评分）
        + **ASC | DESC** 排序方向，`ASC`顺序 是默认值，而 `DESC` 表示倒序
        + **null** 排序字段为空值时，总是被排在最后 （不受 `ASC` 和 `DESC` 的影响）
            ```sql
             -- 倒序示例
             SELECT * FROM library ORDER BY page_count DESC LIMIT 5;
            ```
        + 也可以对分组结果进行排序。
            - 对分组内记录排序没有意义，因为组内记录最终合并成一个组记录，所以组内记录顺序不影响结果
            - 可以对聚合函数结果进行排序
            - 示例

                ```sql
                 -- 分组排序
                 SELECT gender AS g, COUNT(*) AS c FROM emp GROUP BY gender ORDER BY g DESC;
                 
                 -- 聚合函数值进行排序
                 SELECT gender AS g, MIN(salary) AS salary FROM emp GROUP BY gender ORDER BY salary DESC;
                ```

            - 由于内存限制，仅能对 `10000` 条记录进行聚合排序，如果预计超过此数，建议使用 `LIMIT` 进行限制

        + 如果 `WHERE` 子句包含全文搜索（`full-text`）时，能够对评分进行排序
            - 如果有多个全文搜索条件时，则使用 `bool query` 方式进行联合查询
            - 对评分排序时，需要使用 `SCORE()` 函数。
                + 当然，`SCORE()` 不仅仅用于排序，不排序也能使用
                + 如果查询条件不包含全文搜索的条件时，使用 `SCORE()` 只会得到相同值（无意义）
                
            - 示例
                ```sql
                  -- 使用 SCORE() 函数得到评分并排序
                  SELECT SCORE(), * FROM library WHERE MATCH(name, 'dune') ORDER BY SCORE() DESC;
                ```

    - **LIMIT (count | ALL)** 子句限制返回记录数
        + `count` 可以取大于或等于 `0` 的整数值，如果是 `0` 则返回零条记录
        + `ALL` 表示返回所有记录（无限制）
        + 示例

            ```sql
              -- 返回前 5 条记录
              SELECT first_name, last_name, emp_no FROM emp LIMIT 1;
            ```

    - **PIVOT( aggs_expr FOR field IN (values) )** 子句将行值旋转成列值
        + `aggs_expr` 对某个字段进行聚合计算的表达式（注意：只能是一个字段）
        + `field` 要进行旋转的字段（这是字段的名称）
        + `values` 这是上面 `field` 的值列表，将作为旋转后的列标题。（不是 `field` 的值将被忽略）
        + 示例：

            ```sql
             -- salary 字段求和，并按 languages 字段值 "1" 和 "2" 进行旋转
             
             SELECT * FROM emp PIVOT (SUM(salary) FOR languages IN (1, 2)) LIMIT 5;
            ```
            下面是返回结果示例：其中的列 `1`和`2` 是字段 `languages` 的值
            ```
                 birth_date      |    emp_no     |  first_name   |    gender     |      hire_date      |   last_name   |       1       |       2
            ---------------------+---------------+---------------+---------------+---------------------+---------------+---------------+---------------
            null                 |10041          |Uri            |F              |1989-11-12 00:00:00.0|Lenart         |56415          |null
            null                 |10043          |Yishay         |M              |1990-10-20 00:00:00.0|Tzvieli        |34341          |null
            null                 |10044          |Mingsen        |F              |1994-05-21 00:00:00.0|Casley         |39728          |null
            1952-04-19 00:00:00.0|10009          |Sumant         |F              |1985-02-18 00:00:00.0|Peac           |66174          |null
            1953-01-07 00:00:00.0|10067          |Claudi         |M              |1987-03-04 00:00:00.0|Stavenow       |null           |52044
            ```

        + 示例2：
        
            ```
              -- salary 字段求平均，按 gender 字段值 `F` 进行旋转
              
              SELECT * FROM (SELECT languages, gender, salary FROM emp) PIVOT (AVG(salary) FOR gender IN ('F'));
            ```


## macroview-elasticsearch ##

### elasticsearch-jdbc-driver ###

### macroview-elasticsearch-client ###

