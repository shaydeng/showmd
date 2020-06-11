
## I1. 说明 ##

　　描述不同版本的重要变更或开发要注意的问题。

## I2. 内容 ##

### I2.2 2020.04a 版本 ###

 + macroview-libs 升级到 `2.14.0` 版本，此版本最大的变化在两方面：

    - `Result` 体系结构发生变化，有一些方法可能会发生改变

    - `JSON` 方面的开发变化，逐步使用 `Json` 来替换 `JSONObject` ，使用 `JsonList` 来替换 `JSONArray`

        + 在过度期间，会在 `com.macroview.agent.commons.json.JsonUtils` 提供两者间的转换方法

### I2.1 2020.03a 版本 ###

