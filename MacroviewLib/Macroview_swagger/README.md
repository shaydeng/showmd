@[toc](目录)

### 1. 说明

　　本文档对 `Macroview swagger`库的一个使用说明。

### 2. 内容

 + 当前版本：**2.10.5**

 + 支持的 swagger 的版本：**1.5.20 (OpenAPI 2.x)**

　　本库是一个 `Swagger` 注解库用于 `MWF` 项目的 API 说明库 

####  2.1 目前支持的 Swagger 注解

 + **@Api**：Action(Controller) 类级注解，将 Action 注解为一个 API 资源。

     - 正常情况下，只有使用 `@Api`注解的 `Action`，才会被 `Swagger`解释处理。

     - 注解的参数：

       * tags：Api 分组标签（名称），具有相同标签的 API 会归并在一个组下显示（用来分类）

       * value：意义与 `tags` 相同，在 `tags`没值的情况下会使用本参数。

       * description：详细描述（说明类或 API 的作用） 

    ```java
       //示例
       @Api(value="用于 User 操作的接口", tags="用户操作接口")
       @RestController("/users")
       public class UserAction{
           //...
       }
    ```


 + **@ApiOperation**：定义在请求处理方法上的注解，用来说明此方法所映射的请求的内容

     - 正常情况下，只有使用 `@ApiOperation` 注解的方法，才会被处理

     - 相同的请求路径，而请求方法不同（指 `Get`、`Post`、`Put`、`Delete`等方法）的情况下，会被归组为同一个操作对象。

     - 主要参数：（参数比较多，这里列出主要）

       * value：操作名称，也可以是方法上的请求路径，长度为120个字母（60个汉字）（`如果不填本项，则默认是请求路径`）

       * notes：操作的详细说明

       * httpMethod：http 请求方法名称，可选：`GET`、`POST`、`PUT`、`DETELE`、`OPTIONS`、`PATCH`。(`如果不填本项，会自动通过 MWF 的注解来获取`)

       * code：http 请求状态值，默认为 200。

    ```java
       //示例
       @Api(value="用于 User 操作的接口", tags="用户操作接口")
       @RestController("/users")
       public class UserAction{

           @ApiOperation(value="获取用户信息", notes="使用 userId 来得到此 user 的详细信息")
           @ApiImplicitParams({
               @ApiImplicitParam(name="userId", value="用户ID", dataType="long", paramType="path")
           })
           @Get("/{userId}")
           public DataResult<User> getUserBy(@PathVariable Long userId){
               //...
           }
           //...
       }
    ```


 + **@ApiImplicitParams**：注解在方法上的，此方法所需要的参数说明，这个解释是一个数组，具体内容由数组元素 `@ApiImplicitParam`。（通常作用于外部参数）

 + **@ApiImplicitParam**：对单个参数进行说明

     - 主要参数：（参数比较多）

       * name：参数名称（必填）
       * value：参数简单描述（例如 name 的中文名称）
       * required：是否为必传参数
       * dataType：参数类型（对应 Java 的数据类型名称或类名）
       * paramType：参数获取位置（从什么地方来），可选位置包括
          - path：参数值从请求路径中获取
          - query：查询参数中获取
          - body：请求体中获取（通常是 post 操作）
          - header：请求头中获取
          - form：（不常用）


    ```java
       //示例
       @Api(value="用于 User 操作的接口", tags="用户操作接口")
       @RestController("/users")
       public class UserAction{

           @ApiOperation(value="获取用户信息", notes="使用 userId 来得到此 user 的详细信息")
           @ApiImplicitParams({
               @ApiImplicitParam(name="userId", value="用户ID", dataType="long", paramType="path")
           })
           @Get("/{userId}")
           public DataResult<User> getUserBy(@PathVariable Long userId){
               //...
           }
           //...
       }
    ```

 + **@ApiParam**：方法参数的说明，通常用于方法内参数的说明。可以留意到 `@ApiImplicitParam`的注解比较灵活，并有更多的说明。而 `@ApiParam`就简单得多

     - `@ApiParam`注解，等价于 `@ApiImplicitParam`的`paramType=query`的情况参数

     - 主要参数：

       * name：参数名称。（`不填时使用方法参数名作为此参数值`）
       * value：参数的简要说明（例如参数的中文含义）
       * required：是否为必传参数
       * defaultValue：提供一个默认值（**注意：这个默认值只对测试有用，不能用于真正的方法调用**）

    ```java
       //示例
       @Api(value="用于 User 操作的接口", tags="用户操作接口")
       @RestController("/users")
       public class UserAction{

           @ApiOperation(value="查询用户信息", notes="使用 userName 来得到此 user 的详细信息")
           @Get("/query")
           public DataResult<User> getUserBy(
                    @ApiParam(name="userName", value="用户的名称", required=true)
                    String userName
                ){
               //...
           }
           //...
       }
    ```

 + **@ApiResponses**：方法返回值的说明（响应内容说明），这是一个 `@ApiResponse`注解数组，可用于说明不同情况下的返回内容

     - 例如请求处理成功情况下的返回值，失败情况下的返回值等

     - 有可能情况下，每一种返回值对应一个 `@ApiResponse`

 + **@ApiResponse**：具体的返回值描述注解

     - 每一种返回值对应一个 `@ApiResponse`。例如 `200`、`400`等每个状态码对应一个返回结果

     - 主要参数：

       * code：返回码。(通常是标准的 HTTP 请求返回码)
       * message：返回的文本消息（如错误原因描述等）
       * response：返回类型信息（**可选**）。通常是包含包名称的完全类名，又或者是产生错误的异常类的完全类名等
       * responseContainer：如果返回类型是一个容器，这里给出容器的名称，可选名称包括：`List`、`Set`、`Map`

    ```java
       //示例
       @Api(value="用于 User 操作的接口", tags="用户操作接口")
       @RestController("/users")
       public class UserAction{

           @ApiOperation(value="操作")
           @ApiResponses({
               @ApiResponse(code=400, message="请求参数没填好"),
               @ApiResponse(code=404, message="请求路径没有或不对")
           })
           @Get("/todo")
           public ApiResponse toDo(){

           }
           //...
       }
    ```

####  2.2 即将支持的 Swagger 注解

　　上面的 `注解`是针对动作的说明，而针对数据的说明，又有下面的注解：

 + **@ApiModel**：对数据类型（通常是针对请求参数或返回参数的类）进行更为详细的说明

     - 一般情况下，如果不用此注解，`swagger`会通过反射来得到默认的说明

