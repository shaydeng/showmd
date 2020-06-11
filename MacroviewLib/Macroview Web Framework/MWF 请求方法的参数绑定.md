
　　在使用 Servlet 当中，客户端所提交的数据都会存放在 HttpServletReqeust 中，并且都是以字符串（或字符串数组）形式存在。我们在获取使用这些数据时，都需要手工来获取并再转换成需要的数据类型。这些操作都比较机制乏味，能不能提供自动获取和转换呢？WMF 框架就提供了这种自动与便利。

　　MWF 提供了灵活、丰富的参数绑定方式，以最小的转换得到最大的方便。我们分下面几种类型来说明参数绑定方法。

  + **Servlet 自有类型的绑定，Servlet 类型包括：**

     - HttpServletRequest 和 HttpServletResponse 对象：我们的方法可以使用这两种对象作为参数，MWF 将自动将请求的 Request 和 Response 注入到方法

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
	   *
	   *   使用 HttpServletRequest 和 HttpServletResponse 作为方法参数
	   *
	   */
	  @Get("/list")
      public ModelAndView list(HttpServletRequest request, HttpServletResponse response){
		
	    return new ModelAndView("user/index");
   	  }

  }
  ```
     - HttpServletRequest 中的输入流类型： Request 包括了如 InputStream 或 Reader 的输入流。如果我们只对输入流感兴趣，就可以单独注入这个参数。
	  
     - HttpServletResponse 中的输出流类型：Response 包括了如 OuputStream 或 Writer 的输出流。如果只对输出流感兴趣，就可以单独注入这个参数。

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
	   *
	   *   如果只对输入流感兴趣，可以只使用 HttpServletRequest 的 InputStream 作为参数
	   *   如果只对输出流 Writer 感兴趣，可以在方法参数中注入
	   *
	   */
	  @Get("/list")
   	public ModelAndView list(InputStream request, Writer response){
		
		    return new ModelAndView("user/index");
   	}

  }
  ```

  + **Java 基础类型的绑定**
  
     - String 类型
     - 数值类型（如 Integer, Long 等）
     - Date 日期类型（java.util.Date）
     - Map 类型

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
	   * Get /user/browse?UserId=xxx 请求，显示帐号详细内容。
	   *
	   *   绑定注入参数 UserId
	   */
	  @Get("/browse")
   	public ModelAndView display(Long UserId){
		
		  return new ModelAndView("user/user_info");
   	}
   	
   	/**
   	 * Post /user/update  password=xxxx,role=xxxx  使用了 Map 注入
   	 *
   	 *  Map 保存了客户端提交的数据
   	 */
   	@Post("/update")
   	public @ResponseBody Result<String> updateUser(Map data){
   	
   	    User.dao.update( data.get("password"), data.get("role") );
   	
   		return Result.SUCCESS;
   	}
  }
  ```

  + **自定义类对象的绑定**
  
     - MWF 非常方便的地方就是，我们可以使用自定义对象作为参数。MWF 将会根据对象中的字段进行匹配绑定。下面给出一个简单的示例：

  ```HTML

  <!-- 提交数据 -->
  <form method="post" action="/user/create">
  
    用户名：<input type="text" name="username" value="">
    用户密码：<input type="password" name="password" value="">
    确认密码：<input type="password" name="repwd" value="">
    用户身份：<select name="role" size="1">
			<option value="User">普通用户</option>
			<option value="Admin">管理员</option>
	     </select>
  </form>
  ```

  ```Java

   //User.java
   
   public class UserBean{
   
   		private String username;  //绑定 <input name="username" > 的值，数据域名称与 input 的 name 属性名称要一样，区分大小写
   		
   		private String password;  //绑定 <input name="password" > 的值 
   		
   		private String repwd;     //...类推
   		
   		private UserRole role;  // UserRole 是个枚举类型，绑定 <select name="role" > 的值
   		
   		//下面是 set/get 内容，这里省略
   
   }

  /**
   * /user 请求处理类，处理 /user/xxx 请求。
   *
   * @author jai
   * @since: v1.0
  */
  @Controller(path="/user")
  public class UserAction {

	  /**
	   * Post /user/create 请求，创建新用户帐号。
	   *
	   *  form 提交的数据将绑定到 UserBean 中去。。。参数名称 userBean 可以随便起。
	   */
	  @Post("/create")
   	public ModelAndView create(UserBean userBean){
		
		  User user = userBean.toUser();
		  user.save();
		
		  return new ModelAndView("user/user_list");
   	}
  }
  ```         
     - MWF 还提供域驱动形式的绑定。即在表单元素，如 input，中添加数据域名称来明确指定的绑定，例如：

  ```HTML

    <!-- 提交数据 在 input 表单元素中 name 属性以  domain.property 形式来指定绑定对象 -->
    <form method="post" action="/user/create">
  
    用户名：<input type="text" name="user.username" value="">
    用户密码：<input type="password" name="user.password" value="">
    确认密码：<input type="password" name="user.repwd" value="">
    用户身份：<select name="user.role" size="1">
			<option value="User">普通用户</option>
			<option value="Admin">管理员</option>
	     </select>
    </form>
  ```

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
	   * Post /user/create 请求，创建新用户帐号。
	   *
	   *  form 提交的数据将绑定到 UserBean 中去。。。参数名称 user 就是 form 表单元素中指定要绑定的名称。
	   */
	  @Post("/create")
   	public ModelAndView create(UserBean user, File userImage){
		
		  User user = userBean.toUser();
		  saveUploadImg(userImage);
		  user.save();
		
		  return new ModelAndView("user/user_list");
   	}
  }
  ```

  + **请求路径参数**：我们可以将参数作为请求路径的一部分来使用。在这种情况下，路径的定义需要符合格式：\{参数名\}，下面是一个示例 （可以定义多个路径参数）。     
 
```Java   
    @Controller(path="/user")
    public class UserAction{
      
      
         /**
          * delete /user/{userId} 请求，删除一个 id 的帐号
          *
          *  其中用户 id 就包含在请求路径当中，此时我们可以使用 @PathVariable 来注入这个参数
          *
          *  要注意：参数的名称要与路径上的名称（即 {名称} 中的名称）一致。
          *
          */
         @Delete("/{userId}")
         public @ResponseBody deleteUser(@PathVariable Long userId){
            ....
         }
   
    ...
    ｝
```     
