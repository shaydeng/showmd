
## 基础注解 ##

　　MWF 支持两种类型的 WEB 请求映射注解集，从使用角度来看，这两种类型的注解集其实可以混用。不过，为了方便维护与管理，强烈建议只单用其中一种。本文章说明 MWF 注解方案的使用方法。

　　通用的请求注解都会分成两部分：类注解；方法注解；

   + 类注解：通常映射到请求路径。换句话说，每个请求路径我们可以映射到一个或一个以上的类上。这种做法是有益的，因为我们可以用路径来对功能模块进行分类。或者说，同一个模块或功能的请求，映射到同一条请求路径上来，方便维护、理解与管理。目前支持的类注解有两个：

     - **`@Controller`**：这个注解，更多关注于返回 `JSP`（视图），当然也可以使用 `@ResponseBody`注解支持 `JSON/XML`类型的返回

	 - **`@RestController`**：这个注解，表示本类所处理的请求，返回一律视为 `JSON/XML`。所以，当我们需要返回 `JSON` 格式数据时，通常使用这个类注解来完成。


   + 方法注解：将终端操作映射到类的方法上。类中每一个方法对应一个请求，或者一组同类的请求。同样方便维护、理解与管理

      - **注意**： 类注解路径 + 方法注解终端操作 = 一个完整的请求

         + 例如请求： /user/list 拆解为 /user 映射到类，而 /list 则映射到类的方法，从而组成完整的 /user/list 请求映射。

      - 方法注解中，分成两类：一是针对具体的请求方法来定义；二是接受多种请求方法（视为同一处理），下面是框架支持的请求方法注解：

	    + **`@Get`**：`GET` 请求方法支持
		+ **`@Post`**：`POST` 请求方法支持
		+ **`@Put`**：`Put` 请求方法支持
		+ **`@Delete`**：`Delete` 请求方法支持
		+ **`@Request`**：不区分请求方法，只要是请求就接收

　　下面详细解释 MWF 注解方案的内容：

### @Controller 注解 ###

 + @Controller : 类注解。本注解只能注解在类上，表示此类所映射的路径名称。

      - 原型： @Controller(path="<要映射的路径>")

      - 例如，将 /user 映射到帐号操作请求处理类 UserAction 的注解方法如下：

```java
/**
 * /user 请求处理类，处理 /user/xxx 请求。
 *
 * @author jai
 * @since: v1.0
*/
@Controller(path="/user")
public class UserAction {

   	// 内容
}
```

### @RestController 注解 ### 

　　`@RestController` 的使用与 `@Controller` 没任何区别，区别在于返回值。对于 `@RestController`而言，返回值会自动转为 `JSON/XML`（视请求时提供的 `Content-Type`的要求而定），所以在进行 `REST`形式的开发时，我们通常会使用 `@RestController`。

### 方法上的注解 ###

 + @Get ： 方法注解。本注解只能注解在方法上，表示一个 Get 请求。

      - **原型： @Get("<映射的终端请求>")**

      - 通常 Get 请求表达一个查询请求

      - 例如，将 Get /user/list 请求映射到方法 list() 中去： 

```java
/**
 * /user 请求处理类，处理 /user/xxx 请求。
 *
 * @author jai
 * @since: v1.0
*/
@Controller(path="/user")
public class UserAction {

	/**
	 * Get /user/list 请求，显示帐号列表。
	 */
	@Get("/list")
   	public ModelAndView list(){
		
		return new ModelAndView("user/index");
   	}
}
```

   + @Post ： 方法注解。本注解只能注解在方法上，表示一个 Post 请求。

      - **原型： @Post("<映射的终端请求>")**

      - 通常 Post 请求表示一个更新请求，例如新增、修改等

      - 例如，Post /user/create 保存客户端提交的新帐号，可以写作如下：

```java
/**
 * /user 请求处理类，处理 /user/xxx 请求。
 *
 * @author jai
 * @since: v1.0
*/
@Controller(path="/user")
public class UserAction {

	/**
	 * Get /user/list 请求，显示帐号列表。
	 */
	@Get("/list")
   	public ModelAndView list(){
		
		return new ModelAndView("user/index");
   	}

	/**
	 * Post /user/create 保存客户端提交的帐号数据
	 */
   	@Post("/create")
   	public @ResponseBody Result<String> saveUser(UserBean user){
		// save user to db
		return Result.SUCCESS;
   	}
}
```

   + @Delete ： 方法注解。本注解只能注解在方法上，表示一个 Delete 请求。

      - **原型： @Delete("<映射的终端请求>")**

      - 通常 Delete 请求表示一个删除操作请求

      - 例如，delete /user/{userid} 删除由 userid 定义的帐号，可以写作如下：

```Java
/**
 * /user 请求处理类，处理 /user/xxx 请求。
 *
 * @author jai
 * @since: v1.0
*/
@Controller(path="/user")
public class UserAction {

	/**
	 * Get /user/list 请求，显示帐号列表。
	 */
	@Get("/list")
   	public ModelAndView list(){
		
		return new ModelAndView("user/index");
   	}

	/**
	 * Post /user/create 保存客户端提交的帐号数据
	 */
   	@Post("/create")
   	public @ResponseBody Result<String> saveUser(UserBean user){
		// save user to db
		return Result.SUCCESS;
   	}

	/**
	 * 删除帐号
	 */
	@Delete("/{userid}")
   	public @ResponseBody Result<String> deleteUser(@PathVariable userid){
		User.dao.delete(userid);
		return Result.SUCCESS;
   	}
}
```

　　是不是觉得很简单，确实如此，MWF 本身的定位就是足够简单。我们在 web 开发时，将模块的请求规划到同一个请求路径中去，这样就可以将请求处理集中在一个或两个类中，方便处理与维护。

### @ResponseBody 返回类型注解 ### 

　　之前说过，`@Controller` 注解用于返回 `JSP`（视图）的注解 ，但当我们需要某个或几个请求（混杂在 `@Controller`注解类），返回 `JSON/XML` 时，我们可以显式使用 `@ResponseBody` 注解，表明此请求不返回 `JSP`，而是其他类型。

　　`@ResponseBody`注解在方法上，如下面示例：

```java
/**
 * /user 请求处理类，处理 /user/xxx 请求。
 *
 * @author jai
 * @since: v1.0
*/
@Controller(path="/user")
public class UserAction {

	/**
	 * 删除帐号
	 */
	@Delete("/{userid}")
   	public @ResponseBody BooleanResult deleteUser(@PathVariable userid){
		User.dao.delete(userid);
		return Result.SUCCESS;
   	}
}
```

　　删除用户请求时，我们需要返回一个成功或错误的信息，而不是一个复杂或大的 `JSP`（视图）内容。

## 提高内容 ##

　　上面是基础内容，通常是一些经常性使用的功能，本篇讲解的是不常使用，但有时候很有用的内容。

### 请求钩子（Hook） ###

　　当我们需要对已经存在的请求处理进行额外的扩展（已有类库），又或者需要对某类请求，进行集中实现一些处理时，我们可以使用一种叫 `钩子`（Hook）的功能，在不修改（或不影响）原有功能代码的前提下，进行（代码级）无侵入扩展修改。

　　框架目前支持两种类型的钩子：

 + **`@Before`**：请求前置处理，即在执行正常的请求处理方法之前执行。

 + **`@After`**：请求后置处理，即在执行完正常的请求处理方法之后，再执行这个钩子

#### @Before 前置钩子 ####

　　当我们将 `@Before` 注解定义在某个方法（此方法，必须为 `@Controller`或`@RestController`注解的Action类）时，这个方法就成为一个`前置钩子`，下面是注解带的属性：

 + value 属性：同 `@Get`等一样，用来表示这个钩子，将`钩`住那个请求，如果 `value`为空（默认），则表示为 `@Controller`或`@RestController`的请求路径前置处理（即类的所有请求的前置处理方法）

 + method 属性 （RequestMethod[]类型）：用于区分具体的请求方法，目的用来精确定位请求

　　当某个类方法，将作为请求的前置钩子时，其参数可以使用下述的类型：

 + 空参数，即不带任何参数

 + 带与所 `钩` 的请求处理方法相同的参数

 + 只有 Request 和 Response 两个参数

 + `GetRequestData` 接口，是对 `Request`和`Response`的封装，更加方便取数据

　　同样，这个方法的返回值，也只能有以下两种：

 + 无返回值 （即不带任何返回值）

 + 返回 true/false （此功能未实现）：一般建议的返回类型，返回 `true` 表示继续执行正常的处理方法，返回 `false`，则不再执行正常的处理方法，直接返回（这个要小心使用）

　　下面是一个示例：（接收 Agent 心跳请求）

```java
@RestController("/v1/service/agent")
public class AgentHeartbeatAction {

	/**
	 * Agent 发送过来的心跳
	 *
	 * @param data
	 * @return
	 */
	@Post("/heartbeat")
	public DataMap2 heartbeat(AgentHttpRequest data){
		AppMainLogger.MAIN.info("[Post /service/agent/heartbeat]==> 心跳请求：" + data);

		//.... 更多代码略
	}
```

　　接收心跳请求的功能已经写好，作为一个代码库提供给我们使用。当我们需要在自己的项目中，感知 `Agent` 是否存活时，一个方法就是修改上面的代码，加上自己项目的代码，另一个方法就是使用这里提供的 `钩子`（不需要修改已经有的代码），下面是`钩子`示例：

```java
@RestController("/v1/service/agent")
public class DemoHookAction {

	/**
	 *   请求：/v1/service/agent/heartbeat 的钩子，注意：这里支持同路径 GET/PUT/POST/DELETE 请求
	 */
	@Before("/heartbeat")
	public void beforeHeartbeat(AgentHttpRequest data) {
		AppMainLogger.MAIN.info("[Before /v1/service/agent/heartbeat]==> 心跳的请求钩子，请求参数：" + data);
	}
}
```

　　`钩子`的内容包括：

 + 定义与要 `钩` 住的请求一样的请求路径

 + 使用 `@Before` 注解，并且注解方法使用了一样的参数（当然也可以使用其他支持的参数）

 + 不带返回值 （因为不需要）

　　当请求 `/v1/service/agent/heartbeat` 过来时，会首先执行本方法（`@Before` 前置），然后再执行正常的处理方法（即 `heartbeat(...)` 方法）

　　这种做法的好处就是，不需要修改原有代码（零侵入），就可以扩展或改变原有代码的行为。

#### @After 后置钩子 ####

　　`@After` 跟 `@Before` 的功能原理一样，区别在于 `@After` 方法是原有方法执行完后，才执行，这个钩子可以做一些 `收尾工作`。

　　下面是注解带的属性：

 + value 属性：同 `@Get`等一样，用来表示这个钩子，将`钩`住那个请求，如果 `value`为空（默认），则表示为 `@Controller`或`@RestController`的请求路径前置处理（即类的所有请求的前置处理方法）

 + method 属性 （RequestMethod[]类型）：用于区分具体的请求方法，目的用来精确定位请求

　　当某个类方法，将作为请求的前置钩子时，其参数可以使用下述的类型：

 + 空参数，即不带任何参数

 + 带与所 `钩` 的请求处理方法相同的参数

 + 只有 Request 和 Response 两个参数

 + 请求处理方法的返回值（执行请求处理后的返回值）

   - 2.10.0 版本只支持 `ModelAndView` 的返回值

   - 2.12.0 版本将支持任何非 null 的返回值

 + `GetRequestData` 接口，是对 `Request`和`Response`的封装，更加方便取数据

　　这个方法没有返回值（即使有，将会被忽略）

　　下面是示例：

```java
@RestController("/v1/service/agent")
public class DemoHookAction {

	/**
	 *   请求：/v1/service/agent/heartbeat 的钩子，注意：这里支持同路径 GET/PUT/POST/DELETE 请求
	 */
	@After("/heartbeat")
	public void afterHeartbeat(AgentHttpRequest data) {
		AppMainLogger.MAIN.info("[After /v1/service/agent/heartbeat]==> 心跳的请求钩子，请求参数：" + data);
	}
}
```

　　于是，方法会在 `heartbeat(...)` 执行后再执行。

#### 关于钩子  ####

　　虽然，`MWF`提供了更强的 `Interceptor`（请求拦截器）来对请求进行拦截，继而进行二次处理。但拦截器的作用范围会更大，更重，当我们只需要针对某个（或少数几个）请求，进行处理时，`@Before`与`@After`为我们提供一个简单的，轻量级的拦截，比起使用 `Interceptor` 更好。

