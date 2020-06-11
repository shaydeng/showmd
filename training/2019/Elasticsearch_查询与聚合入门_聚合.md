
@[toc](目录)

# 0. 前言 #

## 0.1 说明 ##

　　本文档主要包括数据的聚合内容，基础部分参见：

 + [入门](./Elasticsearch_入门.md)

 + [查询](./Elasticsearch_查询与聚合入门.md)

# 1. 基础内容 #

　　所谓 `聚合`，就是通过查询条件，查询出满足条件的所有文档，然后按照某个条件（通常是数学公式）来进行统计，最终得取一组统计结果的操作，通常又称为 `聚合统计`，换句话来说，聚合由两大部分组成： 

 + 第一步：查询条件。这通过 `查询语句` 来提供来进行

 + 第二步：使用数学公式对满足条件的文档进行计算，例如：

    - 计数
    - 求最大值与最小值
    - 求和
    - 求平均
    - 。。。。

　　所以说 `聚合` 的目的就是统计

## 聚合的概念与术语 ##

### 聚合原理 ###

　　当 `ES` 集群接收到一个 `聚合请求时`，聚合操作将并发地分发到各个分片（节点），每个分片根据各自拥有的数据进行计算并排序，最后汇总（到请求节点）协调各分片的结果，并进行整理返回给客户端。

　　除非要求返回所有文档记录，否则（明显）有个筛选的操作，并且这个筛选是在分片上各自进行，于是就产生了 `精度` 的问题，或者是说有可能产生 `误差`。


### Buckets (桶) ###

　　`Buckets（桶）`，这个概念很形象表达了其作用与目的：用来装载符合某种条件的文档。每个桶都对应一个或一组条件，但凡满足这个条件的文档，都会被放进 `桶` 内。另外，也可以理解为：

 + 文档集合。满足条件的一个文档集合。

 + 分组。对文档进行分组。（类似 `SQL` 的 `GROUP BY`）

　　例如，下面就是一些 `桶`：

 + 性别，分成 `男性桶` 与 `女性桶`

 + 价格，可能分成 `100 元桶`、`80 元桶`、`小于 80 元桶`

 + 日期，如 `2019-12-11` 属于 `十二月桶` 等等

　　还有，`桶` 内除了文档之外，我们还可以放 `桶`，叫 `桶中桶` （桶套桶，如俄罗斯套娃一样），这种形式提供具有层次化的划分方案，能够组织复杂的查询与统计工作。（没有嵌套层次约束）

### Metrics （度量） ###

　　`Metrics` 称为 `度量`，或者 `指标`。就是对 `桶` 内文档，根据某种数学公式统计的结果。（名词就是统计结果，动词就是统计计算）。类似 `SQL` 的计算函数如 `COUNT()`、`SUM()`、`MAX()` 等


### 聚合过程示例 ###

　　有了 `桶` 与 `度量` 概念后，用一个示例来说明两者是如何组织成一个 `聚合`。

　　示例：按员工所属国家，性别与年龄段来统计平均薪酬。（`条件` 是 `桶`，`平均薪酬` 就是 `量度指标`）

 + （1）通过国家（名称）来划分文档（`桶`：每个国家为一个桶）

 + （2）在每个国家桶中，按性别再划分文档（`桶`：每个国家桶再划分性别桶）

 + （3）在每个性别桶中，按年龄段再划分文档（`桶`：每个国家桶再划分性别桶，在性别桶中再划分年龄段桶）

 + （4）对年龄段桶计算平均薪酬 （`度量`，要留意，不是划分后再遍历统计，而是划分过程中已经在统计）

 + （5）返回的结果就是一个 `<国家, 性别, 年龄段>` 组合的 `平均薪酬`


　　如果要与传统的 `SQL` 来进行对比，会更清楚一些：

  **`SELECT COUNT(color) FROM table GROUP BY color`**

 + **`GROUP BY`**：就是分桶
 + **`COUNT(..)`**：就是统计（指标）


### Pipeline 管道 ###

　　`管道`是更高级的数据处理，通常是由一边到另一边的意思。也就是将上一个聚合结果作为输入，经过 `某种管道` 操作（通常也是一种聚合），然后输出。同样，`管道` 不受限制，可以一路走多条管道。

### Matrix 矩阵分析 ###

　　`Matrix` 是实验性质的聚合功能，不承诺会一直支持，说不定会在某个版本移除。


# 聚合语句内容 #

## 聚合请求结构 ##

　　跟 `查询` 一样，`聚合语句` 同样放在一个 `JSON 格式` 请求体内，发送到 `ES`。

　　下面是 `聚合请求结构范式` :

 ```ruby
 {
     "aggs":{
         "聚合名称":{
            "聚合语句":{
                <语句体>
            }
            [,"meta":{[<meta_data_body>]}]?
            [,"aggs":{ [<sub_aggs>]+ }]?
         }
         [, "聚合名称_2": {...}]*
     }
 }
 ``` 
 + **`aggs`**：固定的聚合操作名称，也可以用全称 **`aggregations`**，这是请求体中，表示此内容为一个聚合语句内容
 + **`聚合名称`**：一个聚合内容的名字，通常建议符合 `Java 标识符`的命名规则，这个名称将作为结果返回的 `JSON` 字段名称。
 + **`聚合语句`**：聚合语句内容，具体的可用聚合语句，将在后面重点讲述
 + **`aggs`**：聚合内可以嵌套聚合
 + **`聚合名称_2`**：等等，在顶层中可以进行多个聚合。

## 聚合结果结构 ##

## 聚合语句分类 ##


 + `Bucket 聚合` （分组）

 + `Metrics 聚合` （统计）

 + `Pipeline 管道`

### Bucket 聚合 ###

　　`Bucket 桶聚合`，就是利用聚合语句生成 `桶` 并返回的聚合，相当于 `GROUP BY` 操作（并返回桶中文档的数量，即 `count`）。与之前查询不同的是，这是分组返回的操作，得到的结果也是按条件组成一个集合数组。

#### Terms Aggs 字段聚合 ####

　　`Terms Aggs` 字段聚合，相当于使用某个字段进行分组的意思，相当于 `GROUP BY field`。

 + 结构范式：

    ```json
    {
        "aggs":{
            "聚合名称": {
                "terms": {
                    "field": "聚合的字段名称",
                    "size": "指定每个桶最大记录数，默认为 10，即 TOP10",
                    "shard_size": "分片分别返回的记录数，默认：shard_size=size * 1.5 +10",
                    "show_term_doc_count_error": "true/false 是否开启每个桶的计算错误上限，默认关闭",
                    "order": "聚合结果排序，默认是按 doc_count 排序",
                    "min_doc_count": "最小文档数，即桶少于这个数时，不返回，默认为 1",
                    "shard_min_doc_count": "分片最小文档数，即少于这个数时不返回，默认为 0",
                    "include": "表示包含的内容",
                    "exclude": "表示不包含的内容",
                    "collect_mode": "多层聚合模式：depth_first(深度优先)或breadth_first(广度优先)",
                    "missing": "为没有值等字段指定一个值，如 N/A，默认忽略没有值字段",
                    "execution_hint": "聚合方法：map(内存表）或 global_ordinals（全局序列，默认值）"
                }
            }
        }
    }
    ```

    - **`field`**：只能对单个字段进行聚合，如果想多字段聚合时，使用 `script` 或 `copy_to 字段`
    - **`size`**：指定分片中每个桶的最大记录数，原则上最值越大精度超高，当然性能会受影响，默认为 `10`。另外，如果 `size` 过大，也有可能返回大量 `无用数据`，此时可以与 `shard_size` 参数来调节
    - **`shard_size`**：指定分片返回的最大记录数，默认时值：`shard_size=size * 1.5 + 10`。如果要设置此值，要求值必须不少于 `size`。
    - **`order`**：桶排序，有以下几种排序方式：
      + `doc_count`：按桶的文档数量来排，这是默认的排序方法（倒序）
      + `_key`：按 `field` 的值来排，如：

        ```json
        {
            "aggs":{
                "genres":{
                    "terms":{
                        "field": "genres",
                        "order": {
                            "_key": "asc"
                        }
                    }
                }
            }
        }
        ```
      + 如果有子聚合的话，可以按子聚合的值来排序：  

        ```json
        {
            "aggs":{
                "genres":{
                    "terms":{
                        "field": "genres",
                        "order": {
                            "max_play_count": "desc"
                        }
                    },
                    "aggs":{
                        "max_play_count" : { "max" : { "field" : "play_count" } }
                    }
                }
            }
        }
        ```   
        `max_play_count` 就是子聚合的名     

    - **`min_doc_count`**：在一些聚合场景中，如果某分类数量过少没意义的话，可以 `忽略不返回`，这个 `忽略阀值` 由 `min_doc_count` 来指定，默认如果桶的数量为零的话，不返回。（如果零也要返回，可设置本参数为 `0`）

    - **`include`**：更多是一个过滤器，用于指定包含那些文档，要理解本语句自身仅是一个分组语句，并不具有查询或过滤的含义，如果需要查询或过滤，就得使用这个字段，这个字段有以下几种取值：

        + `正则表达式`：可以使用一个 `正则表达式` 来指定所包含的文档，如：

            ```json
            {
                "aggs":{
                    "genres":{
                        "terms":{
                            "field": "genres",
                            "include": ".*sport.*"
                        }
                    }
                }
            }
            ```
            `.*sport.*` 这个表达式表示，只对包含有字符串 `sport` 的文档进行分组

        + `值数组`：可以给出具体值列表（数组），很明确的字符串时使用：

            ```json
            {
                "aggs":{
                    "genres":{
                        "terms":{
                            "field": "genres",
                            "include": ["mazda", "honda"]
                        }
                    }
                }
            }
            ```
            明确指定对 `mazda`、`honda` 这两项进行聚合

    - **`exclude`**：这个跟 `include` 相反，表示 `不包含` 的意思，可用于去掉某些文档，其取值与 `include` 一样：

        + `正则表达式`
        + `值数组`

            ```json
            {
                "aggs" : {
                    "JapaneseCars" : {
                        "terms" : {
                            "field" : "make",
                            "include" : ["mazda", "honda"]
                        }
                    },
                    "ActiveCarManufacturers" : {
                        "terms" : {
                            "field" : "make",
                            "exclude" : ["rover", "jensen"]
                        }
                    }
                }
            }
            ```
            这是综合示例，`JapaneseCars` 聚合表示 `mazda` 和 `honda` 两个分组聚合，而 `ActiveCarManufacturers` 表示 `除了 rover 和 jensen` 之外的聚合

    - **`collect_mode`**：当一个聚合请求中，包含多重聚合时（如包含一个 `桶聚合` 和 一个 `度量聚合`），整个聚合我们可以想象成一棵树，对于树来说（遍历算法）有两种遍历方式：`深度优先` 和 `广度优先`。如果是 `无损` 遍历的话，两种方法都不会产生问题，但是对 `有损` （即有可能 `损失精度` ）情况下，不同的遍历方法的结果，有可能大不一样，因此本聚合也就提供了遍历方法的配置。不过，默认状态下，系统会自动衡量采用何种方法，因此一般不需要人工干预，只有在 `确实需要` 的情景下，才来指定此配置，配置有两个可选值：
       + `breadth_first`：广度优先
       + `depth_first`：深度优先 

    - **`missing`**：对于某些文档中，聚合字段没有值的情况，可能通过本字段来指定一个 `值`，如指定 `N/A` 值时，所有没有值的文档，都会归类在 `N/A` 桶中，默认忽略没有值的文档。

    - **`execution_hint`**：这是聚合过程方法的参数，有两种：

       + `map`：用内存空间换时间。也就是速度快，但需要内存空间。（如果文档数量较少，并且希望追求速度的话，就用此选项）
       + `global_ordinals`：则是利用 `硬盘` 作缓存，这是默认选项。

#### Filter Aggregation 过滤聚合 ####

　　`Filter 聚合` 着重针对单一字段单一值的聚合（指定字段指定值），本身常常不单独使用，而是为缩小聚合文档范围而设计。

　　`Filter 聚合` 本身也比较简单，结构范式如下：

 + 结构范式：

    ```json
    {
        "aggs":{
            "聚合名称":{
                "filter":{
                    "term": {
                        "字段名": "聚合值"
                    }
                }
            }
        }
    }
    ```

 + 示例：统计 `t-shirt` （T 恤）的平均价格

    ```json
    {
        "aggs" : {
            "t_shirts" : {
                "filter" : { "term": { "type": "t-shirt" } },
                "aggs" : {
                    "avg_price" : { "avg" : { "field" : "price" } }
                }
            }
        }
    }    
    ```

　　过滤器并不单独使用

#### Filters Aggregation 多条件过滤聚合 ####

　　相对于 `Filter Aggregation` 单条件聚合而言，`Filters Aggregation` 为多条件聚合，当需要多个条件聚合时，避免使用多个 `Filter Aggs` 的情景，简化操作。

　　`Filters Aggregation` 聚合也比较简单，下面是结构：

 + 结构范式：

    ```json
    {
        "aggs":{
            "聚合名称":{
                "filters":{
                    "other_bucket": "true/false, true 聚合所有不满足 filters 条件的文档，且桶名为 _other_，默认为 false 即不聚合",
                    "other_bucket_key": "当 other_bucket = true 时，本字段可用来指示桶名，默认为 _other_",
                    "filters":{
                        "桶名1": {
                            "match":{
                                "字段名": "聚合值"
                            }
                        },
                        "桶名2": {
                            "match": {
                                "字段名": "聚合值"
                            }
                        }
                    }
                }
            }
        }
    }
    ```

 + 使用示例：（给出两个聚合条件）

    - 标准 filters Aggs 示例

        ```json
        {
            "size": 0,
            "aggs" : {
                "messages" : {
                    "filters" : {
                        "filters" : {
                            "errors" :   { "match" : { "body" : "error"   }},
                            "warnings" : { "match" : { "body" : "warning" }}
                        }
                    }
                }
            }
        }
        ```
        定义了 `errors` 与 `warnings` 两个条件聚合

    - 开启不满足过滤条件的聚合（将不满足条件的文档也进行聚合）

        ```json
        {
            "size": 0,
            "aggs" : {
                "messages" : {
                    "filters" : {
                        "other_bucket": true,
                        "other_bucket_key": "debugs",
                        "filters" : {
                            "errors" :   { "match" : { "body" : "error"   }},
                            "warnings" : { "match" : { "body" : "warning" }}
                        }
                    }
                }
            }
        }
        ```
        这里开启了 `other_bucket`，并将不是 `errors` 与 `warnings` 的文档命名为 `debugs`

 + 匿名过滤器：如果觉得没必要为桶命名，可以使用省略桶名的结构形式。此时过滤器 `filters` 就是一个数组

    ```json
    {
        "aggs" : {
            "messages" : {
                "filters" : {
                    "filters" : [
                        { "match" : { "字段名" : "聚合值"   }},
                        { "match" : { "字段名" : "聚合值" }}
                    ]
                }
            }
        }
    }
    ```

#### Adjacency Matrix Aggs 邻近矩阵聚合 ####

　　`Adjacency Matrix Aggs` 邻近矩阵聚合，提供若干聚合条件，然后两两组成聚合条件，最终聚合成桶。

　　所谓 `邻近` 或 `邻接` 矩阵聚合，例如有三个聚合条件： `A`、`B`、`C`，那么 `邻近` 聚合的结果是产生 `六个条件`：

 + **`A`**：条件 `A`

 + **`A & B`**：条件 `A` 且 `B`

 + **`B`**：条件 `B`

 + **`B & C`**：条件 `B` 且 `C`

 + **`C`**：条件 `C`

 + **`A & C`**：条件 `A` 且 `C`  

　　我们用矩阵表示如下：

 ```
      |  A       B       C
    -----------------------------------    
    A |  A      A&B     A&C
    B |         B       B&C
    C |                 C
      |        
 ``` 

　　`邻接矩阵` 是一个对称矩阵，因此在聚合成桶时，仅返回上半部分的桶，例如 `A & C` 也就是满足条件 A，同时满足条件 C，但反过来时不会被聚合返回。

　　另外，由于 `N` 个过滤条件，会产生约 `(N^2)/2` 个桶，所以为了避免数量过大，需要对过滤条件进行限制，默认为 `100` 个过滤器（上限），但是我们可以在索引层面上，通过 `index.max_adjacency_matrix_filters` 参数来定义这个上限。

 + 结构范式：

    ```json
    {
        "aggs" : {
            "聚合名称" : {
                "adjacency_matrix" : {
                    "filters" : {
                        "条件名称1" : {
                            "terms" : { "字段" : ["条件1", "条件n"] }
                        },
                        "条件名称2" : { 
                            "terms" : { "字段" : ["v1", "v2"] }
                        },
                        "条件名称3" : { 
                            "terms" : { "字段" : ["v1", "v2"] }
                        }
                    }
                }
            }
        }
    }
    ```
    内部使用 `Terms Aggs` 来定义聚合条件 

 + 示例：

    ```json
    {
        "size": 0,
        "aggs" : {
            "interactions" : {
                "adjacency_matrix" : {
                    "filters" : {
                        "grpA" : { "terms" : { "accounts" : ["hillary", "sidney"] }},
                        "grpB" : { "terms" : { "accounts" : ["donald", "mitt"] }},
                        "grpC" : { "terms" : { "accounts" : ["vladimir", "nigel"] }}
                    }
                }
            }
        }
    }
    ```
    `size=0` 表示返回所有文档

#### Missing Aggretation 缺失字段聚合 ####

　　`Missing Aggs` 就是将不存在或值为 `NULL` 的字段聚合成一个桶。这是一个单桶聚合，并聚合：

 + 虽然字段定义了映射，但由于下面原因没有值（没有值就表示不存在某些文档中）

   - 提交文档时，没有提交此字段的值
   - 有值，但为空值（如字符串为 `NULL`，数组为空等）
   - 有值，但类型错误，此时索引设置了忽略错误参数

　　`Missing Aggs` 使用比较简单：

 + 结构范式：

    ```json
    {
        "aggs":{
            "聚合名称":{
                "missing": {
                    "field": "聚合的字段名称"
                }
            }
        }
    }
    ```

 + 下面检查那些记录漏了 `价格` 内容

    ```json
    {
        "aggs" : {
            "products_without_a_price" : {
                "missing" : { "field" : "price" }
            }
        }
    }
    ```

#### Range Aggregations 范围聚合 ####

　　`Range Aggs` 范围聚合是一个多桶聚合，能够对某个范围的文档进行聚合，这是一个比较常用而重要的聚合操作。

　　`范围` 又称为 `区间`，从数学意义上看，区间有以下几种形式：

 + `(-∞, x)` （只有上限）：表述为 `从 .... 到 x`，`x` 为数值上限。

 + `(x, y)` （上、下限都有）：表述为 `从 x 到 y`，`x` 为下限，`y` 为上限。

 + `(x, ∞)` （只有下限）：表述为 `从 x 到...`， `x` 为数值下限。

　　另外，`Range Aggs` 范围聚合通常用于 `数值类型` 的聚合，而对于时间范围的聚合，则使用 `Date Range Aggs` 等针对时间的聚合。

 + 结构范式：
 
    ```json
    {
        "aggs" : {
            "聚合的名称" : {
                "range" : {
                    "field" : "聚合字段名称",
                    "keyed": "true/false，true 表示用范围作为桶名，false 表示匿名桶名",
                    "ranges" : [
                        { "key": "指定桶名，可选", "from" : "范围下限1", "to" : "范围上限1" },
                        { "from" : "范围下限2", "to" : "范围上限2" },
                        { "from" : "范围下限N", "to" : "范围上限N" }
                    ],
                    "script":{
                        "lang": "script 语言类型，通常为 painless",
                        "source": " script 的内容",
                        "id": "如果 script 是来自外部，这里为其 id 名称",
                        "params":{
                            "field": "如果是外部 script，这里用来指定作用的字段名",
                            "parma1": "script 中使用的参数值等"
                        }
                    }
                }
            }
        }        
    }
    ```

    - **`field`**：这是聚合字段，通常是一个数值类型字段
    - **`keyed`**: true/false，是否为桶起个名，默认不起名。true 表示起个桶名，此名为范围名称。
    - **`ranges`**：范围表达多数组，这是聚合的核心，下面是范围表达式的用法：

        + `key`：可选，是桶的名称。默认以范围为名称，如 `80-20`、`*-20`等

        + `from`：可选，范围下限，表示 `从...` 的意思。可以省略表示无下限，也就是 `(-∞, x)` 形式，此时必须要给出上限，即 `to` 字段。
        + `to`：可选，范围上限，表示 `到...` 的意思。可省略表示无上限，也就是 `(x, ∞)` 形式，此时必须要给出下限，即 `from` 字段。
        + 下面是一些示例：

            ```json
            {
                "ranges":[
                    {"key": "A级", "to": 100},
                    {"key": "B级", "from": 100, "to": 500},
                    {"Key": "D级", "from": 500, "to": 1500},
                    {"from": 1500}
                ]
            }
            ```
            - 第一个范围只有上限
            - 第二个范围有完整的字段表示
            - 最后一个范围没有名称（名称被定义为 `"1500-*"`），并且只有下限

    - **`script`**：可选，可以使用 `script` 来操纵文档数据，下面是一些示例

        + 聚合内容由 `script` 来定义，下面是取字段 `price` 的值

            ```json
            {
                "aggs" : {
                    "price_ranges" : {
                        "range" : {
                            "script" : {
                                "lang": "painless",
                                "source": "doc['price'].value"
                            },
                            "ranges" : [
                                { "to" : 100 },
                                { "from" : 100, "to" : 200 },
                                { "from" : 200 }
                            ]
                        }
                    }
                }
            }
            ```

        + 对字段进行处理后，再进行聚合

            ```json
            {
                "aggs" : {
                    "price_ranges" : {
                        "range" : {
                            "field" : "price",
                            "script" : {
                                "source": "_value * params.conversion_rate",
                                "params" : {
                                    "conversion_rate" : 0.8
                                }
                            },
                            "ranges" : [
                                { "to" : 35 },
                                { "from" : 35, "to" : 70 },
                                { "from" : 70 }
                            ]
                        }
                    }
                }
            }
            ```

            `_value` 就是当前记录的 `price` 字段值

 + 下面是一些示例

    - 简单示例

        ```json
        {
            "aggs" : {
                "price_ranges" : {
                    "range" : {
                        "field" : "price",
                        "ranges" : [
                            { "to" : 100.0 },
                            { "from" : 100.0, "to" : 200.0 },
                            { "from" : 200.0 }
                        ]
                    }
                }
            }
        }
        ```
        这个聚合返回的结果样例：

        ```json
        {
            ...
            "aggregations": {
                "price_ranges" : {  // price_ranges 是聚合名称
                    "buckets": [
                        {
                            "key": "*-100.0",   //key 相当于桶名
                            "to": 100.0,
                            "doc_count": 2
                        },
                        {
                            "key": "100.0-200.0",
                            "from": 100.0,
                            "to": 200.0,
                            "doc_count": 2
                        },
                        {
                            "key": "200.0-*",
                            "from": 200.0,
                            "doc_count": 3
                        }
                    ]
                }
            }
        }
        ```

    - 下面示例指定桶名

        ```json
        {
            "aggs" : {
                "price_ranges" : {
                    "range" : {
                        "field" : "price",
                        "keyed" : true,     //开启显示桶名
                        "ranges" : [
                            { "key" : "cheap", "to" : 100 },
                            { "key" : "average", "from" : 100, "to" : 200 },
                            { "key" : "expensive", "from" : 200 }
                        ]
                    }
                }
            }
        }
        ```
        下面结果样例：

        ```json
        {
            ...
            "aggregations": {
                "price_ranges" : {
                    "buckets": {
                        "cheap": {         // "cheap" 就是桶名
                            "to": 100.0,
                            "doc_count": 2
                        },
                        "average": {
                            "from": 100.0,
                            "to": 200.0,
                            "doc_count": 2
                        },
                        "expensive": {
                            "from": 200.0,
                            "doc_count": 3
                        }
                    }
                }
            }
        }
        ```

    - 下面是一个添加了统计聚合的嵌套聚合（复杂）

        ```json
        {
            "aggs":{
                "price_ranges":{
                    "range":{
                        "field":"price",
                        "ranges":[
                            {"to":50},
                            {"from":50,"to":100},
                            {"from":100}
                        ]
                    },
                    "aggs":{
                        "price_stats":{
                            "stats":{            // stats 聚合
                                "field":"price"
                            }
                        }
                    }
                }
            }
        }
        ```
        上面是在 `范围聚合` 的基础上，对 `桶` 进行 `stats 聚合`，下面是结果示例：

        ```json
        {
            "aggregations":{
                "price_ranges":{
                    "buckets":[
                        {
                            "to":50,
                            "doc_count":2,
                            "price_stats":{
                                "count":2,
                                "min":20,
                                "max":47,
                                "avg":33.5,
                                "sum":67
                            }
                        },
                        {
                            "from":50,
                            "to":100,
                            "doc_count":4,
                            "price_stats":{
                                "count":4,
                                "min":60,
                                "max":98,
                                "avg":82.5,
                                "sum":330
                            }
                        },
                        {
                            "from":100,
                            "doc_count":4,
                            "price_stats":{
                                "count":4,
                                "min":134,
                                "max":367,
                                "avg":216,
                                "sum":864
                            }
                        }
                    ]
                }
            }
        }
        ```

#### Date Range Aggregation 日期时间聚合 ####

　　`Date Range Aggs` 是日期时间聚合，由于与数值的 `Range Aggs` 有区别，所以也就独立成一个聚合句子。

　　`Date Range Aggs` 是日期时间聚合的最特色在于日期时间的表示，而范围的字段表示与 `Range Aggs` 一样，由 `from` 和 `to` 构成，但要注意的是，范围总是表示为 **`[from, to)`**，即包含 `from` 而不包含 `to`。

　　关于日期时间的表示，可以参见之前教程的 `时间表达式`，下面是更加全面的内容：

    Symbol  Meaning             Presentation        Examples
    -------------------------------------------------------------------
    G       era                     text            AD; Anno Domini; A
    u       year                    year            2004; 04
    y       year-of-era             year            2004; 04
    D       day-of-year             number          189
    M/L     month-of-year           number/text     7; 07; Jul; July; J
    d       day-of-month            number          10
    Q/q     quarter-of-year         number/text     3; 03; Q3; 3rd quarter
    Y       week-based-year         year            1996; 96
    w       week-of-week-based-year number          27
    W       week-of-month           number          4
    E       day-of-week             text            Tue; Tuesday; T
    e/c     localized day-of-week   number/text     2; 02; Tue; Tuesday; T
    F       week-of-month           number          3
    a       am-pm-of-day            text            PM
    h       clock-hour-of-am-pm (1-12)  number      12
    K       hour-of-am-pm (0-11)    number          0
    k       clock-hour-of-am-pm (1-24)  number      0
    H       hour-of-day (0-23)      number          0
    m       minute-of-hour          number          30
    s       second-of-minute        number          55
    S       fraction-of-second      fraction        978
    A       milli-of-day            number          1234
    n       nano-of-second          number          987654321
    N       nano-of-day             number          1234000000
    V       time-zone ID            zone-id         America/Los_Angeles; Z; -08:30
    z       time-zone name          zone-name       Pacific Standard Time; PST
    O       localized zone-offset   offset-O        GMT+8; GMT+08:00; UTC-08:00;
    X       zone-offset Z for zero  offset-X        Z; -08; -0830; -08:30; -083015; -08:30:15;
    x       zone-offset             offset-x        +0000; -08; -0830; -08:30; -083015; -08:30:15;
    Z       zone-offset             offset-Z        +0000; -0800; -08:00;
    p       pad next                pad modifier    1
    '       escape for text         delimiter       ''
    single
    quote    literal                '               [
    
    optional 
    section 
    start       ]                   optional section end    #

    reserved
    for 
    future use {                    reserved for future use     }

 + 结构范式：

    ```json
    {
        "aggs" : {
            "聚合的名称" : {
                "date_range" : {
                    "field" : "聚合字段名称",
                    "format": "定义字段的日期时间格式",
                    "keyed": "true/false，true 表示用范围作为桶名，false 表示匿名桶名",
                    "missing": "对于没有值的文档时，可以在这里提供一个值",
                    "time_zone": "时区",
                    "ranges" : [
                        { "key": "指定桶名，可选", "from" : "范围下限1", "to" : "范围上限1" },
                        { "from" : "范围下限2", "to" : "范围上限2" },
                        { "from" : "范围下限N", "to" : "范围上限N" }
                    ]
                }
            }
        }        
    }
    ```
    - **`format`**：可选，用来定义字段的格式，默认为 `long` (数值类型) 或 带时区的 `UTC` 标准字符串（字符串类型）
    - **`missing`**：可选，为没有值的文档（聚合字段）指定一个值，以便能放入某个桶中。（值的格式要符合 `format` 指定格式）
    - **`time_zone`**：可选，指定一个时区
    - **`ranges`**：这个字段的内容与 `Range Aggs` 一样，但要注意，表达的是区间：**`[from, to)`**，即如果有 `to` 时，不包含 `to` 的时间点

 + 示例

    - 定义两个桶：(1) `< now-10M/M` 即现时减去 10 个月（取整到月）结束；(2) `>= now-10M/M` 从现时减去 10 个月（取整到月）开始，包含。

        ```json
        {
            "aggs": {
                "range": {
                    "date_range": {
                        "field": "date",
                        "format": "MM-yyyy",
                        "ranges": [
                            { "to": "now-10M/M" }, 
                            { "from": "now-10M/M" } 
                        ]
                    }
                }
            }
        }
        ```

    - 为桶定义名称

        ```json
        {
            "aggs": {
                "range": {
                    "date_range": {
                        "field": "date",
                        "format": "MM-yyy",
                        "ranges": [
                            { "from": "01-2015",  "to": "03-2015", "key": "quarter_01" },
                            { "from": "03-2015", "to": "06-2015", "key": "quarter_02" }
                        ],
                        "keyed": true
                    }
                }
            }
        }
        ```

#### Histogram Aggregation 直方图聚合 ####

　　`Histogram Aggs` 直方图聚合可以理解为：**`按某个固定间隔进行聚合`**，对于本聚合而言，通常针对 `数值类型` 的字段，如果需要用在 `日期时间` 类型字段，则要使用另一个类似的聚合：`Date histogram Aggregation`。

　　`Histogram Aggs` 直方图聚合有两个要点：

 + 也是有一个数值范围。可以想象成坐标上的直方图，要有一个显示区间。

 + 按某个固定间隔进行分类聚合。不象 `Range Aggs` 是人工给出分类区间。`Histogram Aggs` 是一个按固定间隔来自动生成区间，下面是值计算公式：

    **`bucket_key = Math.floor((value - offset) / interval) * interval + offset`**

    - `interval`：就是某个固定间隔，也就是直方图中的宽。

      + 形成的桶就是：`[0, interval)`、`[interval, 2 * interval)`、`...`
    
    - `offset`：这是范围的偏移，默认为 `0`
    - `value`：这是当前要聚合的字段的值，根据上面公式计算得到值，看看结果落在上面的那个桶
    - 如果字段的值为浮点数时，由于要转为整数，要注意精度情况（会造成文档丢失）。又或者为负数时，同样也要留意区间的计算问题。
    - 每区间总是：`[下限, 上限)` （即不包含上限值）

　　下面是聚合结构：

 + 简化范式：（最简使用）

    ```json
    {
        "aggs":{
            "聚合名称":{
                "histogram":{
                    "field": "要聚合的字段",
                    "interval": "间隔值"
                }
            }
        }
    }
    ```
    下面是一个示例：（价格，每隔 `50` 一个区间）

    ```json
    {
        "aggs" : {
            "prices" : {
                "histogram" : {
                    "field" : "price",
                    "interval" : 50
                }
            }
        }
    }   
    ``` 

 + 标准结构范式：

    ```json
    {
        "aggs":{
            "聚合名称":{
                "histogram":{
                    "field": "字段名称",
                    "interval": "间隔值",
                    "min_doc_count": "最小文档数量值，默认为 0，即不返回小于此值的桶",
                    "offset": "区间偏移值，默认为 0",
                    "extended_bounds": {
                        "min": "最小范围约束值",
                        "max": "最大范围约束值"
                    },
                    "order": "对桶进行排序",
                    "keyed": "true/false，是否显示桶名，默认不显示",
                    "missing": "对没有值的文档，提供一个值，以便能统计到某个桶"
                }
            }
        }
    }
    ```
    - **`interval`**：就是区间间隔（可理解为直方图的宽），注意值必须要大于 `0`
    - **`min_doc_count`**：最少文档记录数，如果桶的文档数少于此值，则不会返回，默认为 `0`。要留意，当此值为 '0' 时，如果开始或末尾的桶的文档数为 '0' 也不会返回。如果需要返回一个完整的区间序列时，需要结合 `extended_bounds` 一起使用
    - **`offset`**：即区间的偏移量，此值可以是一个负数，默认为 `0`。通常区间序列是这样：`[offset, interval + offset)`、`[interval + offset, 2 * interval + offset )` 等等

      + 当 `offset` 是负数时，就意味着直方图向 `x 轴` 负数那边偏移。

      + 当提供的 `offset` 过大，使得有些文档无法落在最小桶时，`ES` 会自动向后延申一个区间，以便能统计。如 `offset: 4`，产生 `[4, 54)、[54, 104)..`，此时如果有一个文档的数据值为 `3`，很明显无法落在 `[4, 54)` 中，于是会将区间向后延，变成：`[-46, 4)、[4, 54)、[54, 104)`，于是 `3` 就能统计

    - **`extended_bounds`**：在上面的介绍知道，对于直方图而言，如果开头没有文档时，会被忽略而不返回 (`min_doc_count` 对开头无效)，此时我们可以定义一个显示区间，以便使开头即使没有文档，也可以返回，这个参数就是：`extended_bounds`。我们可以将 `extended_bounds` 的 `min` 放在区间间隔的开始，即能 `强制` 聚合返回结果。但要注意，这个配置不是过滤条件，所以：
        + 当文档中存在小于 `min` 的值时，则 `min` 的值会被忽略，以文档的最小值为最小值。
        + 当文档中存在大于 `max` 的值时，则 `max` 的值会被忽略，以文档的最大值为最大值。
    
    - **`order`**：排序，使用与 `terms aggs` 一样
    - **`keyed`**：是否显示桶名
    - **`missing`**：对没有值的文档，提供一个值，以便能统计到某个桶，例如 `missing: "N/A"`，则会有一个叫 `N/A` 名称的桶，里面的文档其聚合字段的值为空

 + 示例：

    - 简单使用

        ```json
        {
            "aggs" : {
                "prices" : {
                    "histogram" : {
                        "field" : "price",
                        "interval" : 50
                    }
                }
            }
        }
        ```

    - 加上偏移

        ```json
        {
            "aggs" : {
                "prices" : {
                    "histogram" : {
                        "field" : "price",
                        "interval" : 50,
                        "offset": -5
                    }
                }
            }
        }
        ```
        此时，区间就变成：`[-5, 45)`、`[45, 95)`....

    - 加上 `extended_bounds`

        ```json
        {
            "aggs" : {
                "prices" : {
                    "histogram" : {
                        "field" : "price",
                        "interval" : 50,
                        "extended_bounds":{
                            "min": 0,
                            "max": 200
                        }
                    }
                }
            }
        }
        ```
        在这种情况下，会 `强制` 区间 `[0, 50)、[50, 100)。。。`，即使开头 `[0, 50)` 等没有任何文档，也会出现在返回结果中，这样的设置能产生一个完整的区间结果


#### Date histogram Aggregation 日期时间直方图聚合 ####

　　`Date histogram Aggs` 日期时间直方图聚合与 `Date Range Aggs` 不是同一种东西。

　　`Date histogram Aggs` 包含了 `按某个时间间隔来聚合` 的意思。是上面的 `Histogram Aggs` 在日期时间方面的聚合，两者差别在于 `Date Histogram Aggs` 仅针对日期时间，除此之外，在语法结构上大同小异。

　　要注意的是 `7.2` 版本的聚合语法与之前有所改变，由原来的 `interval` 字段变成两个负责不同日期时间的字段，新字段名：

 + **`calendar_interval`**：定义可识别的日历间隔，并且只能以 `1` 为单位，下面是其可用值

    - `minute`：或 `m` 或 `1m` 都可以。`1分钟` 是指在指定时区中第一分钟的00秒到下一分钟的00秒之间的间隔，并对中间产生的闰秒进行补偿。
    - `hour`：或 `h` 或 `1h` 都可以。`1小时` 是指在指定时区中第一小时的00分钟到下一小时的00分钟之间的间隔，并对中间产生的闰秒进行补偿。
    - `day`：或 `d` 或 `1d` 都可以， 但 `2d` 就不可以。每天通常由 `00:00:00` 开始
    - `week`：或 `w` 或 `1w` 都可以，`一周` 是指定时区内，一周的开始日期（`day_of_week:hour:minute:second`），到下一周的时间之间的间隔
    - `month`：或 `M` 或 `1M`，表示月
    - `quarter`：或 `q` 或 `1q`，表示季
    - `year`：或 `y` 或 `1y`，表示年

 + **`fixed_interval`**：固定间隔配置参数，这个固定间隔是以国际单位为基准，无论是什么日期，都不会偏离（多或少），例如 `每秒总等于 1000 毫秒`，在这种情况下，我们可以以倍数的形式来定义间隔，下面是本字段能够使用的类型：

    - `milliseconds (ms)`：表示毫秒
    - `seconds (s)`：表示秒，同时每秒为 1000 毫秒
    - `minutes (m)`：表示分钟，每分钟为 60 秒，也等于 60,000 毫秒
    - `hours (h)`：表示小时，所有小时都从 0 分 0 秒开始，每小时等于 60 分钟，也等于 3,600,000 毫秒
    - `days (d)`：表示天，所有天都是从 00:00:00 开始，并且每天等于 24 小时，也等于 86,400,000 毫秒

　　要注意，**`calendar_interval`** 与 **`fixed_interval`** 两者只能选其一，下面是结构范式：

 + 结构范式

    ```json
    {
        "aggs":{
            "聚合名称":{
                "date_histogram":{
                    "field": "字段名称",
                    "calendar_interval": "日历为单位间隔",
                    "fixed_interval": "标准单位间隔",
                    "format": "日期时间格式",
                    "time_zone": "时区",
                    "min_doc_count": "最小文档数量值，默认为 0，即不返回小于此值的桶",
                    "offset": "区间偏移值，默认为 0，这个偏移必须带时间单位",
                    "extended_bounds": {
                        "min": "最小范围约束值",
                        "max": "最大范围约束值"
                    },
                    "order": "对桶进行排序",
                    "keyed": "true/false，是否显示桶名，默认不显示",
                    "missing": "对没有值的文档，提供一个值，以便能统计到某个桶",
                    "script":{}
                }
            }
        }
    }
    ```

    - **`calendar_interval`**：以年、月、日、季、周为聚合间隔，并且要注意所有聚合数量都为 `1`，即 `1年`、`1月`、`1日`、`1季`等等，无论是少于 `1` 还是大于 `1` 都是错误。因为无论是 `月` 还是 `年` 等，都具不确定因素，例如 一个月可以有 `29天`、`30天`、`31天` 等，如果系统按某种定义，固定以 `30天` 为 `月` 时，可以使用 `fixed_interval` 来 `模拟一个月`。
    - **`fixed_interval`**：对于国际标准的时间计量单位为聚合间隔，此字段可以添加具体的数量（而不是固定为 `1`），例如 `2d` 表示 `2天`；`10m` 表示 `10分钟`等。
    - `calendar_interval` 与 `fixed_interval` 两者只能取其一，否则返回错误

 + 示例

    - 聚合示例：(按每个月一个桶进行聚合)

        ```json
        {
            "aggs": {
                "sales": {
                    "date_histogram": {
                        "field": "sold",
                        "calendar_interval": "month"
                    }
                }
            }
        }
        ```
        按月进行聚合，其中 `calendar_interval` 的值可以是 `month` 或 `1M` 都没问题

    - 按每2天一个桶进行聚合，此时，就需要用 `fixed_interval`

        ```json
        {
            "aggs" : {
                "sales_over_time" : {
                    "date_histogram" : {
                        "field" : "date",
                        "fixed_interval" : "2d",
                        "keyed": true
                    }
                }
            }
        }
        ```
        - 下面是结果示例：

            ```json
            {
                ...
                "aggregations": {
                    "sales_over_time": {
                        "buckets": {
                            "2018-01-01": {
                                "key_as_string": "2018-01-01",
                                "key": 1420070400000,
                                "doc_count": 3
                            },
                            "2018-01-03": {
                                "key_as_string": "2018-01-03",
                                "key": 1422748800000,
                                "doc_count": 2
                            },
                            "2018-01-05": {
                                "key_as_string": "2015-03-05",
                                "key": 1425168000000,
                                "doc_count": 2
                            }
                        }
                    }
                }
            }
            ```

    - 复杂一些示例

        ```json
        {
            "aggs": {
                "sales": {
                    "date_histogram": {
                        "field": "sold",
                        "fixed_interval": "30d",
                        "format": "yyyy-MM-dd",
                        "min_doc_count" : 0, 
                        "keyed": true,
                        "extended_bounds" : { 
                            "min" : "2018-01-01",
                            "max" : "2018-12-31"
                        },
                        "missing": "N/A"
                    }
                }
            }
        }
        ```
        - `"fixed_interval": "30d"`：其实是定义 `30天` 为一个自然月，然后进行聚合
        - `extended_bounds`：用来指示聚合的返回范围，即使在范围内的桶没有文档，也会被返回
        - `missing`：表示没有数据的文档会放在一个名叫 `N/A` 的桶

#### Auto-interval Date Histogram Aggregation 自动计算时间间隔聚合 ####

　　`Auto-interval Date Histogram Aggs (auto_date_histogram)` 由你提出总的 `桶数`，然后 `ES` 根据桶数来算出时间间隔，从而进行聚合。也就是说，当我需要 `10` 个桶时，我为了能 `凑` 成 `10` 个桶，而人工来算时间间隔，再用 `Date Histogram` 来聚合，很明显有时有点 `烧脑`，于是干脆让 `ES` 来帮我算，就是这个聚合的来由。

 + 结构范式：

    ```json
    {
        "aggs" : {
            "聚合名称" : {
                "auto_date_histogram" : {
                    "field" : "字段名称",
                    "buckets": "要聚合的桶的数量，默认 10",
                    "minimum_interval": "间隔是按什么单位进行，默认自动选择最佳间隔",
                    "format": "日期时间格式",
                    "time_zone": "时区",
                    "missing": "空值文档聚合桶名"
                }
            }
        }
    }
    ```
    - **`buckets`**：桶的数量，可选，默认值为 `10`，结果返回的桶数总是少于或等于此值。当进行聚合时，会根据桶数，以及日期分布情况，在时间间隔上自动选取合适的聚合时间单位，下面是一些规则:
        + 对于秒：会选取 1, 5, 10, 30 四个数字的整倍数
        + 对于分钟：会选取 1, 5, 10, 30 的整倍数
        + 对于小时：会选取 1, 3, 12 的整倍数
        + 对于天：会选取 1, 7 的整倍数
        + 对于月：会选取 1, 3 的整倍数
        + 对于年：会选取 1, 5, 10, 20, 50, 100 的整倍数

    - **`minimum_interval`**：默认情况下，总是以最佳的间隔来聚合成桶，当然，我们也可以指定按什么单位来聚合，本字段可选的值：

        + year：年，即尽量以年为单位定义间隔
        + month：月，尽量以月为单位定义间隔
        + day：日，尽量以日为单位定义间隔
        + hour：小时，尽量以小时为单位定义间隔
        + minute：分钟，尽量以分钟为单位定义间隔
        + second：秒，尽量以秒为单位定义间隔

 + 使用示例

    - 最简单用法：将 date 字段聚合成 10 个桶，间隔自动计算

        ```json
        {
            "aggs" : {
                "sales_over_time" : {
                    "auto_date_histogram" : {
                        "field" : "date"
                    }
                }
            }
        }
        ```

    - 自定义桶数量：只要 5 个桶

        ```json
        {
            "aggs" : {
                "sales_over_time" : {
                    "auto_date_histogram" : {
                        "field" : "date",
                        "buckets" : 5,
                        "format" : "yyyy-MM-dd" 
                    }
                }
            }
        }
        ```
        下面是返回结果示例：

        ```json
            {
                ...
                "aggregations": {
                    "sales_over_time": {
                        "buckets": [
                            {
                                "key_as_string": "2015-01-01",
                                "key": 1420070400000,
                                "doc_count": 3
                            },
                            {
                                "key_as_string": "2015-02-01",
                                "key": 1422748800000,
                                "doc_count": 2
                            },
                            {
                                "key_as_string": "2015-03-01",
                                "key": 1425168000000,
                                "doc_count": 2
                            }
                        ],
                        "interval": "1M"
                    }
                }
            }
        ```
        **`注意`**：在结果中，会返回聚合的间隔，如上面示例中的 `"interval": "1M"` （间隔为 1 个月）

    - 复杂一些：按 天 为间隔，要 30 个桶，没文档的聚合在 "N/A" 下，定义格式与时区

        ```json
        {
            "aggs" : {
                "sale_date" : {
                    "auto_date_histogram" : {
                        "field" : "date",
                        "buckets": 30,
                        "minimum_interval": "day",
                        "missing": "N/A",
                        "format": "yyyy-MM-dd",
                        "time_zone": "+08:00:00"
                    }
                }
            }
        }
        ```
        - `"minimum_interval": "day"`：明确表示，在自动计算间隔时，要按 `天` 来计算


#### Composite Aggregations 多桶聚合复合聚合 ####

　　在上面我们了解到 `ES` 提供丰富的桶聚合功能，那么我们可以将这些桶聚合进行组合聚合吗？。。`Composite Aggs` 聚合就提供了类似的，将多个聚合复合成一个聚合的功能。

　　如果与传统的 `SQL` 查询对照，`Composite Aggs` 相当于多字段分组 `Group by field1, field2,...,fieldN`，在 `Composite Aggs`中，通过 `sources` 字段来包含不同的原子聚合，并且原子聚合出现的顺序，通常也决定了结果文档在返回时的顺序。下面是聚合的结构范式：

 + 结构范式

    ```json
    {
        "aggs":{
            "聚合名称":{
                "composite":{
                    "sources":[
                        {"source_name": { "子聚合的聚合体" }},
                        [{...}]
                    ],
                    "size": "定义每次返回大小",
                    "after": "上一次返回的结果集中最后一次记录值"
                }
            }
        }
    }
    ```
    - `sources`：里面就是子聚合的数组，可以有一个或多个聚合
    - `source_name`：聚合的名称，要 **注意：`名称必须唯一`**，即不能有两个相同的名称出现
    - `子聚合`：下面是所支持的子聚合的内容（三个）

        + `Terms`：支持 `Terms Aggs`，即基于单个字段内容的聚合。支持单个字段聚合，也支持基于 `script` 的聚合，下面是范式：

            ```json
            {
                "aggs":{
                    "my_composite":{
                        "composite":{
                            "sources":[
                                { "source_name": { "terms" : { "field": "字段名称", "order": "asc|desc", "missing_bucket": true|false } } }
                            ]
                        }
                    }
                }
            }
            ```
            - `terms`：使用 `Terms Aggs` 来聚合字段
            - `field`：必选项，聚合的字段名称
            - `order`：可选项，表示排序方向，可选 `asc` 或 `desc`
            - `missing_bucket`：可选项，是否对空值进行聚合，`true` 表示聚合到 `null` 中

        + `Histogram`：对字段按固定数值间隔进行聚合，也支持 `script` 聚合，下面是范式：

            ```json
            {
                "aggs":{
                    "my_composite":{
                        "composite":{
                            "sources":[
                                { "source_name": { "histogram" : { "field": "字段名", "interval": "间隔值", "order": "asc|desc", "missing_bucket": true|false } } }
                            ]
                        }
                    }
                }
            }
            ```
            - `field`：必选项，聚合字段
            - `interval`：必选项，时间间隔

        + `date_histogram`：对日期时间字段按固定间隔进行聚合，要注意只支持整数倍时间单位值，不支持小数（如 `1.5h`）时间，但可以用其他替代（如 1.5h = 90m，用 90m 来代替）：

            ```json
            {
                "aggs":{
                    "my_composite":{
                        "composite":{
                            "sources":[
                                { "source_name": { "date_histogram" : { "field": "字段名", "calendar_interval": "间隔值", "order": "asc|desc", "missing_bucket": true|false, "format": "格式", "time_zone": "时区"  } } }
                            ]
                        }
                    }
                }
            }
            ```
            - `field`：必选项，聚合字段
            - `calendar_interval`：必选项，有效的日期时间单位： `year`, `quarter`, `month`, `week`, `day`, `hour`, `minute`, `second`
            - 支持 `format` 与 `time_zone` 字段来声明时间格式和时区

    - **`size`**：当聚合的桶的数量比较大时，本聚合也支持分页返回。当要进行分页时，本字段为每页的记录大小。
    - **`after`**：还记得之前讲 `查询` 时的 `Search After` 分页技术吗？这里的 `after` 就是那个 `Search After` 分页技术，也就是 `上一页，最后一个桶的 key 的内容`，同时也就是 `下一页内容开始的依据`。（后面有示例）

 + 示例

    - 单个聚合条件示例：

        ```json
        {
            "aggs" : {
                "my_buckets": {
                    "composite" : {
                        "sources" : [
                            { "product": { "terms" : { "field": "product" } } }
                        ]
                    }
                }
            }
        }
        ```

        ```json
        {
            "aggs" : {
                "my_buckets": {
                    "composite" : {
                        "sources" : [
                            {
                                "histo": {
                                    "histogram" : {
                                        "interval": 5,
                                        "script" : {
                                            "source": "doc['price'].value",
                                            "lang": "painless"
                                        }
                                    }
                                }
                            }
                        ]
                    }
                }
            }
        }
        ```

        ```json
        {
            "aggs" : {
                "my_buckets": {
                    "composite" : {
                        "sources" : [
                            {
                                "date": {
                                    "date_histogram" : {
                                        "field": "timestamp",
                                        "calendar_interval": "1d",
                                        "format": "yyyy-MM-dd" 
                                    }
                                }
                            }
                        ]
                    }
                }
            }
        }
        ```

    - 两个或以上聚合的示例：

        ```json
        {
            "aggs" : {
                "my_buckets": {
                    "composite" : {
                        "sources" : [
                            { "shop": { "terms": {"field": "shop" } } },
                            { "product": { "terms": { "field": "product" } } },
                            { "date": { "date_histogram": { "field": "timestamp", "calendar_interval": "1d" } } }
                        ]
                    }
                }
            }
        }
        ```

        - 对文档数据先用 `Terms Aggs` 进行聚合，然后再用 `Terms Aggs` 进行聚合，最后用 `date_histogram` 进行聚合。这样，**`每个桶都会有三个聚合条件`**，而桶中的文档统计数，都是同时满足这三个条件的文档数。
        - 下面是可能的返回结果示例：（通过结果来看聚合条件，理解聚合的含义） 

            ```json
            {
                "Aggregations":{
                    "my_buckets":{
                        "after_key":{
                            "shop": "番禺万达广场店",
                            "product": "T-恤",
                            "date": "2019-12-04"
                        },
                        "buckets":[
                            {
                                "key":{
                                    "shop": "花都万达广场店",
                                    "product": "T-恤",
                                    "date": "2019-12-01"
                                },
                                "doc_count": 1
                            },
                            {
                                "key":{
                                    "shop": "番禺万达广场店",
                                    "product": "T-恤",
                                    "date": "2019-12-01"
                                },
                                "doc_count": 3
                            },
                            {
                                "key":{
                                    "shop": "番禺万达广场店",
                                    "product": "T-恤",
                                    "date": "2019-12-02"
                                },
                                "doc_count": 2
                            },
                            {
                                "key":{
                                    "shop": "番禺万达广场店",
                                    "product": "T-恤",
                                    "date": "2019-12-04"
                                },
                                "doc_count": 5
                            }
                        ]
                    }
                }
            }
            ```

    - 聚合的分页示例：

        + 第一页时的聚合语句：

            ```json
            {
                "aggs" : {
                    "my_buckets": {
                        "composite" : {
                            "size": 2,
                            "sources" : [
                                { "date": { "date_histogram": { "field": "timestamp", "calendar_interval": "1d" } } },
                                { "product": { "terms": {"field": "product" } } }
                            ]
                        }
                    }
                }
            }
            ```

        + 返回的结果可能是：（看最后一个桶的结果 **`key`** 内容）

            ```json
            {
                ...
                "aggregations": {
                    "my_buckets": {
                        "after_key": { 
                            "date": 1494288000000,
                            "product": "mad max"
                        },
                        "buckets": [
                            {
                                "key": {
                                    "date": 1494201600000,
                                    "product": "rocky"
                                },
                                "doc_count": 1
                            },
                            {
                                "key": {
                                    "date": 1494288000000,
                                    "product": "mad max"
                                },
                                "doc_count": 2
                            }
                        ]
                    }
                }
            }
            ```

        + 那么下一页的聚合语句就是：

            ```json
            {
                "aggs" : {
                    "my_buckets": {
                        "composite" : {
                            "size": 2,
                            "sources" : [
                                { "date": { "date_histogram": { "field": "timestamp", "calendar_interval": "1d", "order": "desc" } } },
                                { "product": { "terms": {"field": "product", "order": "asc" } } }
                            ],
                            "after": { "date": 1494288000000, "product": "mad max" } 
                        }
                    }
                }
            }
            ```

#### Global Aggregation 全局聚合 ####

　　`Global Aggs` 全局聚合，主要是提供一个不受查询或约束条件影响，让所有文档都参与的聚合。`Global Aggs` 本身只是一个标识，重要的是依附在本聚合下的其他聚合或统计条件。

　　`Global Aggs` 的特色或注意项：

 + 只能是顶层聚合，作为子聚合来说，是无意义的。（即 `Global Aggs` 作为顶层包含其他聚合才有意义，被其他聚合包含是无意义的）

 + 目的是让其子聚合，不受其他查询条件影响，对所有文档进行处理

 + 本聚合没有任何参数

　　下面是聚合的结构范式：

 + 结构范式：

    ```json
    {
        "aggs" : {
            "聚合名称" : {
                "global" : {}
                [, 其他聚合语句]
            }
    }
    ```
    本聚合无没有任何参数

 + 使用示例：

    ```json
    {
        "query" : {
            "match" : { "type" : "t-shirt" }
        },
        "aggs" : {
            "all_products" : {
                "global" : {}, 
                "aggs" : { 
                    "avg_price" : { "avg" : { "field" : "price" } }
                }
            },
            "t_shirts": { "avg" : { "field" : "price" } }
        }
    }
    ```
    示例给出对同一字段，两个计算平均的聚合，不同的是 `t_shirts` 聚合受查询条件 `query:match` 的影响，而 `avg_price` 则在 `Global Aggs` 的庇护下，对所有文档进行计算平均，结果示例如下：

    ```json
    {
        ...
        "aggregations" : {
            "all_products" : {
                "doc_count" : 7, 
                "avg_price" : {
                    "value" : 140.71428571428572 
                }
            },
            "t_shirts": {
                "value" : 128.33333333333334 
            }
        }
    }
    ```
    一个对所有文档计算平均，另一个仅对 `t_shirts` 计算平均

#### IP Range Aggregation IP 范围聚合 ####

　　在 `ES` 中，`IP` 是作为一个字段类型存在，因此也有类似时间或数值的范围聚合。`IP Range Aggs` 与其他的聚合基本上差不多，下面是其结构范式：

 + 结构范式

    ```json
    {
        "aggs" : {
            "聚合名称" : {
                "ip_range" : {
                    "field" : "ip 类型字段名",
                    "ranges" : [
                        {
                            "key": "桶名，可选",
                            "from": "范围下限 ip ",
                            "to" : "范围上限 ip",
                            "mask": "以掩码方式定义范围" 
                        }
                        [, { 可以有多个范围，表示多个桶 }]
                    ],
                    "keyed": "true 桶有外明确名称，false 匿名，false 是默认值"
                }
            }
        }
    }
    ```
    - 使用 `[from, to)` 来定义范围，其含义与其他的范围聚合一样，如 只有上限或只有下限，同时给出上、下限等。要注意，每个值都是一个确定的 `ip`
    - **`mask`**：以掩码的方式给出范围，本选项与 `[from, to)` 是互斥的，两者只能选其一

 + 使用示例：

    - 单纯的 [from, to) 形式

        ```json
        {
            "aggs" : {
                "ip_ranges" : {
                    "ip_range" : {
                        "field" : "ip",
                        "ranges" : [
                            { "to" : "10.0.0.5" },
                            { "from" : "10.0.0.5" }
                        ]
                    }
                }
            }
        }
        ```
        以 `10.0.0.5` 为分界点，聚合两个桶

    - 复杂的示例：

        ```json
        {
            "aggs" : {
                "ip_ranges" : {
                    "ip_range" : {
                        "field" : "ip",
                        "ranges" : [
                            { "key": "infinity", "to" : "10.1.0.5" },
                            { "key": "and-beyond", "from" : "10.1.0.5" },
                            { "key": "others", "mask" : "10.0.0.127/25" }
                        ],
                        "keyed": true
                    }
                }
            }
        }
        ```
        下面是结果示例：

        ```json
        {
            ...
            "aggregations": {
                "ip_ranges": {
                    "buckets": {
                        "infinity": {
                            "to": "10.1.0.5",
                            "doc_count": 10
                        },
                        "and-beyond": {
                            "from": "10.1.0.5",
                            "doc_count": 260
                        },
                        "others":{
                            "from": "10.0.0.0",
                            "to": "10.0.0.128",
                            "doc_count": 128
                        }
                    }
                }
            }
        }
        ```

#### Significant Terms Aggregation 关注聚合 ####

　　`Significant Terms Aggs` 聚合提供一个关注 `不寻常现象` 的聚合。有些不太容易理解，本聚合的一些使用场景：

 + 当我们尝试搜索 `H5N1` 时，会自动与 `禽流感` 合并搜索。（术语相关性分析与统计）
 + 从信用卡持卡人挂失的交易记录中找出“异常交易”的商户。（在大量的寻常交易中检测和跟踪信用卡欺诈）
 + 为自动新闻分类器建议与股票符号$ATI相关的关键字。（关键字的相关性分析）
 + 产品销售记录中不成比例的销售记录。（不寻常的比例）
 + ....

　　在使用本聚合时要注意，由于涉及到 `相关性统计分析`，并且有个对比过程，因此本聚合需要提供一个 `背景资料`（用来对比），否则就没意义，此时聚合就相当于 `Terms Aggs` 聚合了，具体来说，本聚合的要求或限制如下：

 + 聚合字段必须是索引。（即不进行索引的字段不能用）
 + 不支持浮点类型的字段
 + 由于本聚合的 `背景集` 是整个索引文档，故如果用作foreground set的查询返回结果也是整个文档集合(match_all)的话，该聚合则失去意义。
 + 如果有相当于match_all查询没有查询条件提供索引的一个子集significant_terms聚合不应该被用作最顶部的聚合——在这个场景中前景是完全一样的背景设定,所以没有文档频率的差异来的观察和合理建议。

　　下面是聚合的结构范式：

 + 结构范式

    ```json
    {
        "aggs" : {
            "聚合名称" : {
                "significant_terms" : { 
                    "field" : "聚合字段",
                    "size": "指定桶返回的结果数",
                    "shard_size": "每个桶分片的返回结果数，默认= 2 * (size * 1.5 + 10)",
                    "min_doc_count": "",
                    "shard_min_doc_count": "",
                    "include": "",
                    "exclude": "",
                    "collect_mode":"",
                    "execution_hint":"",

                    "background_filter": {},
                    "jlh":{},
                    "mutual_information": {
                        "include_negatives": true/false,
                        "background_is_superset": true/false
                    },
                    "chi_square":{},
                    "gnd":{
                        "background_is_superset": true/false
                    },
                    "percentage":{}
                }
            }
        }
    }
    ```
    - 与 `Terms Aggs` 相同的参数，如 `size`、`shard_size` 等，这里就不详说
    - 由于本聚合是针对 `评分` 来进行统计分析，因此 `评分` 的方法也是本聚合的一个重点，常用的 `评分算法` 如下：（注意所有评分算法是互斥的，只能选其一）

        + **`jlh`**：`JLH` 算法（默认），字段参数也很简单就是一句：`"jlh":{}`。评分公式：`(foregroundPercentage / backgroundPercentage) * (foregroundPercentage - backgroundPercentage)`。“Foreground”的意思是该项在当前搜索结果中出现的百分比， “Background” 是整个集合的全局百分比。通过全局与局部的对比来 `凸显` 局部出现的 `不寻常`。
        + **`mutual_information`**：
        + **`chi_square`**
        + **`gnd`**
        + **`percentage`**

    - **`background_filter`**：自定义 `背景集`。本字段通常是一个查询语句，如 `Terms` 查询，用来提供对比材料。

 + 示例

    - 下面是英国某地区中自行车盗窃案的搜索

        ```json
        {
            "query" : {
                "terms" : {"force" : [ "British Transport Police" ]}
            },
            "aggregations" : {
                "significant_crime_types" : {
                    "significant_terms" : { "field" : "crime_type" }
                }
            }
        }
        ```
        + 其中的 `query` 语句，就是具体的对比资料。本聚合往往需要与其他查询或聚合组合使用，才能有效果（因为有对比，才会有结果）
        + 返回的结果示例：

            ```json
            {
                ...
                "aggregations" : {
                    "significant_crime_types" : {
                        "doc_count": 47347,
                        "bg_count": 5064554,
                        "buckets" : [
                            {
                                "key": "Bicycle theft",
                                "doc_count": 3640,
                                "score": 0.371235374214817,
                                "bg_count": 66799
                            }
                            ...
                        ]
                    }
                }
            }
            ```
            有几个数据需要关注：最外层的 `doc_count`--- 是 `British Transport` 地区的总案件文档，而 `bg_count` --- 则是整个国家当时的案件文档总数。里层的名字叫 `Bicycle theft`（自行车盗窃案）的桶，`doc_count` --- 是 `British Transport` 地区的自行车盗窃案件文档数，`bg_count` --- 则是全国当时总的自行车盗窃案件数，通过比对就可以发现 `不寻常` 事情：对于全国来说 `66799/5064554 ≈ 1%` 占的比例不高，但对于 `British` 来说 `3640/47347 ≈ 7%` 相对就高多了，这也是本聚合的目的。

    - 利用这种前景与背景的对比，做推荐系统。（用来提高推荐的精准度，而不是泛泛而谈）

        + 例如在收集关于电影爱好方面的资料，以电影名称为主题，同时兼顾喜好。（如主题为 《终结者》，同时喜欢其他电影）
        + 普通的推荐系统，会以某电影主题为条件，聚合喜好来得到，喜欢某电影的同时，喜欢其他电影最多的排行

            - 如喜欢 《终结者》 的人，同时也喜欢 《阿甘正传》
            - 但这种查询聚合有个缺点：得到的结果反映的是 `普遍关系`，而不是某种 `意义关系`。事实上，每个人都可能喜欢《阿甘正传》，所以谈不上是喜欢《终结者》群体的 `偏好`。

        + 使用本聚合时，可以为推荐系统提供针对《终结者》人群的特定分析来得到一个更有 `意义` 的关联

        ```json
        {
            "query": {
                "match": {
                    "movies_liked": "Terminator"
                }
            },
            "aggregations": {
                "movies_like_terminator": {
                    "significant_terms": {
                        "field": "movies_liked",
                        "min_doc_count": 1
                    }
                }
            }
        }
        ```
        在查询上匹配 `《终结者》`，同时聚合上对喜欢进行聚合，从而得到一个精确的偏好。（示例结果显示，喜欢 《终结者》的，同时也喜欢 《洛奇》，而之前的《阿甘正传》反而不在偏好中）        


#### Sampler Aggregation 取样聚合 ####

　　`Sampler Aggs` 取样聚合，从搜索结果中抽取样本（如果没有搜索请求，就是从所有文档中抽样），让这些样本参与接下来的子聚合的计算。样本的抽取是先按照分数排序，然后从上往下抽取指定数量的文档。简单来说 Sampler Aggregation 限制参与聚合的文档的数量。

　　本聚合最重要（主要）应用场合：`避免长尾数据对搜索的影响，长尾数据是指大量但是意义不大的数据`。

　　**`长尾数据`**：是指，当两个或以上查询条件时，`热门` 查询条件的大量匹配数据，往往会将 `冷门` 查询条件的匹配数据 `挤掉`（如果 `冷门` 是 `良币` 的话，可以理解为 `劣币逐良币效应`。在这种情况下，本聚合会将 `热门` 查询的结构筛掉一部分（限制数量），以给 `冷门` 查询留个合理空间。

　　在官方文档中，使用一个搜索例子来说明：`javascript` 是个非常热门的关键词，而 `kibana` 则相对 `冷门` 得多，如果两者进行联合查询时，出现的情况就是大量的 `javascript` 相关性高的文档排在前面，而 `kibana` 则靠后排，甚至很难排上来，这明显不符合我们的搜索需求。那么使用本聚合后，情况就了比较好的权衡。

　　本聚合有一个限制，就是不能用于：**`使用 breadth_first (即广度优先）的聚合下，因为使用受限文档数据，广度不来呀`** （即不能作为广度优先的聚合的子聚合）

　　也有称本聚合为 `海选`，也就是选分数最高的前 `N` 位的含义。下面是其范式：

 + 结构范式：

    ```json
    {
        "aggs": {
            "聚合名称": {
                "sampler": {
                    "shard_size": "每片返回最大文档数，也可以理解为 TOP N"
                }
            }
        }
    }
    ```
    - **`shard_size`**：表示每个分片要返回的文档总数（即 `TOP N` 的 N），目的是减少文档量来降低 `长尾数据` 的影响

 + 示例：

    ```json
    {
        "query": {
            "query_string": {
                "query": "tags:kibana OR tags:javascript"
            }
        },
        "aggs": {
            "sample": {
                "sampler": {
                    "shard_size": 200
                },
                "aggs": {
                    "keywords": {
                        "significant_terms": {
                            "field": "tags",
                            "exclude": ["kibana", "javascript"]
                        }
                    }
                }
            }
        }
    }
    ```
    - 一方面限制长尾数据，另一方面与 `significant_terms` 聚合配合，以便能更好得到所需的数据。
    - 返回结果示例：

        ```json
        {
            ...
            "aggregations": {
                "sample": {
                    "doc_count": 200,
                    "keywords": {
                        "doc_count": 200,
                        "bg_count": 650,
                        "buckets": [
                            {
                                "key": "elasticsearch",
                                "doc_count": 150,
                                "score": 1.078125,
                                "bg_count": 200
                            },
                            {
                                "key": "logstash",
                                "doc_count": 50,
                                "score": 0.5625,
                                "bg_count": 50
                            }
                        ]
                    }
                }
            }
        }
        ```
        - 从第一个 `doc_count=200` 而知，确实被限制在 200 个文档
        - 排第一的是 `elasticsearch`，这也说明了，在讨论 `"kibana", "javascript"` 时，更多涉及到 `elasticsearch` 

#### Significant Text Aggregation 关注聚合 ####

　　与 `Significant Terms Aggs` 类似的聚合，只不过本聚合是针对 `text` 类型字段，因此与之前的 `Significant Terms Aggs` 有以下明显不同：

 + 仅针对 `text` 类型，因此不对内容有所要求。（也不需要 `doc-values`）
 + 会对查询的文档进行 `重新分词`，目的除了分析统计之外，还能删除重复（或其他类型）的 `噪音`，让结果更准确反应需求

　　同时也带来了一些问题和限制：

 + 对大量的文档进行聚合时，由于 `重新分词` 必然带来时间消耗与内存的增量使用。（时间与内存等资源的消耗）
 + 不能在 `Child Aggs`（下面有介绍章节）中使用
 + 不支持 `nested` 类型对象数据

#### Diversified Sampler Aggregation 多元化取样聚合 ####

#### Children Aggregation 子聚合 ####

　　`Children Aggs` 是针对 `join` 类型的，单一桶聚合。



