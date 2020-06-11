

@[toc](目录)

# 0. 前言 #

## 0.1 说明 ##

　　本文档主要包括数据的聚合的量度计算方面的聚合，基础部分参见：

 + [入门](./Elasticsearch_入门.md)

 + [查询](./Elasticsearch_查询与聚合入门.md)

 + [聚合基础与桶聚合](./Elasticsearch_查询与聚合入门_聚合.md)

# 1. 内容 #

　　在第一篇的基础中得知，`Elasticsearch` 本身分成三种类型的聚合：

 + **桶聚合**

 + **量度聚合**：对文档数据进行统计计算

 + **管道聚合**：对文档进行处理，然后通过 `管道` 交由下一个处理器进行处理

　　本篇所讲的聚合内容为 `量度聚合` 与 `管道聚合`

## 1.1 量度聚合 Metrics Aggregations ##

　　`Metrics Aggs` 针对文档数值类型的聚合。

### 1.1.1 Avg Aggregations 求平均值的聚合 ###

　　`Avg Aggs`（平均值聚合）是一个单值（`single-value`）量度聚合，主要用于计算数值字段的平均值。

 + 结构范式：

    ```json
    {
        "aggs":{
            "聚合名称":{
                "avg":{
                    "field": "聚合的字段名称",
                    "missing": "为没有值的字段指定一个值",
                    "script":{
                        "id": "外部 script 的标识符，可以使用内置或外部 script",
                        "source": "script 的语句内容",
                        "lang": " script 语言名称，如 painless, javascript 等",
                        "params: {
                            "source 字段中用到的参数的定义"
                        }
                    }
                }
            }
        }
    }
    ```
    - `script`部分：支持外部与内置两种类型的 `script`，当使用外置时，支持 `id`、`source`、`params`三种属性，当使用内置时，支持 `source`、`lang`、`params` 三种属性 

