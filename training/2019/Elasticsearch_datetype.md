
## 说明 ##

　　本文档简述 `ES` 的日期类型内容。

## 内容 ##

　　日期格式主要包括如下3种方式：

 + 自定义格式

 + date mesh(已在DSL查询API中详解)

 + 内置格式

### 自定义格式 ###

 + 首先可以使用java定义时间的格式，例如：

```shell
  PUT my_index
```
```json
 {
   "mappings": {
     "_doc": {
       "properties": {
         "date": {
           "type":   "date",
           "format": "yyyy-MM-dd HH:mm:ss"
          }
        }
     }
   }
 }
```

 + date mesh

　　某些API支持，已在DSL查询API中详细介绍过，这里不再重复。

 + 内置格式

　　`ES` 为我们内置了大量的格式，如下：

 + epoch_millis

    时间戳，单位，毫秒。

 + epoch_second

    时间戳，单位，秒。

 + date_optional_time

    日期必填，时间可选，其支持的格式如下：

 + basic_date

    yyyyMMdd

 + basic_date_time

    yyyyMMdd'T'HHmmss.SSSZ

 + basic_date_time_no_millis

    yyyyMMdd'T'HHmmssZ

 + basic_ordinal_date

    4位数的年 + 3位(day of year)，其格式字符串为yyyyDDD

 + basic_ordinal_date_time

    yyyyDDD'T'HHmmss.SSSZ

 + basic_ordinal_date_time_no_millis

    yyyyDDD'T'HHmmssZ

 + basic_time

   HHmmss.SSSZ

 + basic_time_no_millis

    HHmmssZ

 + basic_t_time

    'T'HHmmss.SSSZ

 + basic_t_time_no_millis

   'T'HHmmssZ

 + basic_week_date

   xxxx'W'wwe，4为年 ，然后用'W', 2位week of year（所在年里周序号）1位 day of week。

 + basic_week_date_time

   xxxx'W'wwe'T'HH:mm:ss.SSSZ.

 + basic_week_date_time_no_millis

   xxxx'W'wwe'T'HH:mm:ssZ.
 + date

   yyyy-MM-dd
 + date_hour 

   yyyy-MM-dd'T'HH
 + date_hour_minute

   yyyy-MM-dd'T'HH:mm
 + date_hour_minute_second

   yyyy-MM-dd'T'HH:mm:ss
 + date_hour_minute_second_fraction

   yyyy-MM-dd'T'HH:mm:ss.SSS
 + date_hour_minute_second_millis

   yyyy-MM-dd'T'HH:mm:ss.SSS
 + date_time

   yyyy-MM-dd'T'HH:mm:ss.SSS
 + date_time_no_millis

   yyyy-MM-dd'T'HH:mm:ss
 + hour

   HH
 + hour_minute

   HH:mm
 + hour_minute_second

   HH:mm:ss
 + hour_minute_second_fraction

   HH:mm:ss.SSS
 + hour_minute_second_millis

   HH:mm:ss.SSS
 + ordinal_date

   yyyy-DDD,其中DDD为 day of year。
 + ordinal_date_time

   yyyy-DDD‘T’HH:mm:ss.SSSZZ,其中DDD为 day of year。
 + ordinal_date_time_no_millis

   yyyy-DDD‘T’HH:mm:ssZZ
 + time

   HH:mm:ss.SSSZZ
 + time_no_millis 

   HH:mm:ssZZ
 + t_time

   'T'HH:mm:ss.SSSZZ
 + t_time_no_millis

   'T'HH:mm:ssZZ
 + week_date

   xxxx-'W'ww-e,4位年份，ww表示week of year，e表示day of week。
 + week_date_time

   xxxx-'W'ww-e'T'HH:mm:ss.SSSZZ
 + week_date_time_no_millis

   xxxx-'W'ww-e'T'HH:mm:ssZZ
 + weekyear

   xxxx
 + weekyear_week

   xxxx-'W'ww,其中ww为week of year。
 + weekyear_week_day 

   xxxx-'W'ww-e,其中ww为week of year,e为day of week。
 + year

   yyyy
 + year_month 

   yyyy-MM
 + year_month_day

   yyyy-MM-dd，温馨提示，日期格式时，es建议在上述格式之前加上strict_前缀。
