
### 1. 文档摘要

　　本文档说明 `Macroview-web-lang` 2.x 中`Apache HttpClient`封装类的使用。

　　`Apache HttpClient`经常用于调用某些产品或服务器，提供的 HTTP API。就我们开发组而言，比较多的第三方服务器都提供了 HTTP API 接口，例如 CMX, CMS 等等，都可以使用本文档所说的封装类来处理。

### 2. Maven

```xml
    <dependency>
    	<groupId>com.macroview</groupId>
    	<artifactId>macroview-web-lang</artifactId>
    	<version>2.8.0</version>
    </dependency>
```

### 3. 内容

　　所有的方法在类：**`HttpClientUtils`** 中。

　　本**`HttpClientUtils`**的一些默认设置：

 + **使用连接池**（即长连接设置 `keepAlive=true`）

 + **连接池最大连接数：100**

     可以在使用`HttpClientUtils`之前，通过`System.setProperty("mwf.httpclient.max_tcp", 200)`来修改，示例修改为 200 个连接。

 + **支持重定向策略**：即请求发送重定向时，自动发送重定向请求

 + **对HTTPS/SSL请求，将使用免证书策略**

#### 3.1 请求参数类：HttpRequestConfiguration

　　并非所有方法都需要传入此类。为了方便使用 `HttpClientUtils`，目前很多方法都做了简化。真正需要使用本类来构建请求参数的方法，只有方法`request(...)`，如果有需要可以使用下述方法，来创建请求参数类：

**默认设置**

 + **连接超时：1分钟，使用connectTimeout()来修改**

 + **读数据超时：1分钟，使用socketTimeout()来修改**

**静态方法**

 + **HttpRequestConfiguration createGetConfigUsingUrl(String url)**：创建`get`方法请求参数类

 + **HttpRequestConfiguration createPostConfigUsingUrl(String url)**：创建`Post`方法请求参数类

 + **HttpRequestConfiguration createPutConfigUsingUrl(String url)**：创建`Put`方法请求参数类

 + **HttpRequestConfiguration createDeleteConfigUsingUrl(String url)**：创建`Delete`方法请求参数类

**成员方法**

 + **setUrl/getUrl**：url 的 set/get 方法

 + **HttpRequestConfiguration setContentType(String)**：设置`Content-Type`请求头

 + **void setEncoding(String encoding)**：设置编码

 + **HttpRequestConfiguration encoding(String encoding)**：设置编码

     这与`setEncoding()`的区别在于，本方法可以进行`链式`调用。

```java
  HttpRequestConfiguration config = HttpRequestConfiguration.createPostConfigUsingUrl(url)
                                                            .setJsonHeader()
                                                            .encoding("UTF-8")
                                                            .addParam("op", "push");
``` 

 + **HttpRequestConfiguration setJsonHeader()**：设置 JSON 数据请求头

```java
  HttpRequestConfiguration config = HttpRequestConfiguration.createPostConfigUsingUrl(url)
                                                            .setJsonHeader();
```                                                            

 + **HttpRequestConfiguration useXmlContentType()**：设置`XML`数据请求头

 + **HttpRequestConfiguration setPostJson(String)**：设置要发送的`JSON`数据

    注意，这个方法内部已经使用`setJsonHeader`，并且编码为`UTF-8`

 + **HttpRequestConfiguration setPostJson(Object)**：将对象转为`JSON`，然后发送

 + **HttpRequestConfiguration setCustomHttpEntiry(HttpEntity)**：自定义发送数据

 + **HttpRequestConfiguration addHeaders(Header[] ds)**：添加请求头（数组）

 + **HttpRequestConfiguration addHeader(name, value)**：添加单个请求头

 + **HttpRequestConfiguration addHeaders(Map<String, String>)**：添加请求头（Map）

 + **HttpRequestConfiguration addUserPwdForBasicAuthen(userName, pwd)**：添加 Authen Basic 的帐号与密码

 + **HttpRequestConfiguration addUserPwdForBasicAuthen(UserNameAndPassword)**

 + **HttpRequestConfiguration addParams(List<NameValuePair>)**：添加请求参数（列表）

 + **HttpRequestConfiguration addParam(name, value)**：添加一个请求参数

 + **HttpRequestConfiguration addParams(Map<String, Object>)**：添加一组请求参数（Map）

 + **HttpRequestConfiguration addBeanParams(Object)**：将某个对象的属性作为请求参数

 + **HttpRequestConfiguration addCookie(name, value)**：添加一个Cookies

#### 3.2 返回类 HttpServerResponse 说明

　　大部分的方法都会直接返回`HttpServerResponse`类，`HttpServerResponse`将包含了所有应该返回的信息。

　　`HttpServerResponse`的使用是非常灵活的，下面将详细说明：

 + **getValue() 或 getResponseString()**：获取请求返回结果（字符串）

 + **isSuccess()**：方法表示请求成功

```java
  HttpServerResponse result = HttpClientUtils.get("http://www.baidu.com");
  if(result.isSuccess()){
      System.out.println("Response:" + result.getValue());
  }
```

 + **statusCodeIs2xx()**：表示请求成功，并且`URL`（包括参数等）调用成功

    在很多提供服务的系统中，请求调用是否成功，往往是通过`HTTP Status`（状态码）来确定。因为，基于`URL`之上的服务，往往会在`URL`之上定义一套规则，例如，需要包含特定意义的参数等。如果不符合规则，即使服务器无问题，请求操作成功，但在应用层面上，请求调用是失败的。

    所以通常，如果`URL`调用成功的话，会返回`2xx`（如200）状态码表示，如果调用不成功就会返回，如403权限不足等，其他状态码。

    方法`isSuccess()`与`statusCodeIs2xx()`区别在这里。

    另外，并非所有服务系统，都会以`HTTP Status`来确定成功与否，此时需要通过返回值来确定，这已经不是本类所处理的事情了。

```java
  HttpServerResponse result = HttpClientUtils.get("http://www.baidu.com");
  if(result.statusCodeIs2xx()){
      System.out.println("Response:" + result.getValue());
  }else {
      System.out.println("请求错误...返回状态码：" + result.getStatusCode());
  }
```

 + **done(value)/fail(err)**：`Lambda`式的成功与失败处理

```java
  HttpClientUtils.get("http://www.baidu.com")
                 .done(v->System.out.println("Response:" + v))
                 .fail(err->System.out.println("请求错误...返回状态码：" + err.getStatusCode());
```

 + **when(success, err)**：`Lambda`式的，更加复杂的成功与失败处理，常用于直接返回某些数据

```java
	public static StringResult get(String url){
		String apiBaseUrl = MerakiCloudConfigManager.getDashboardApiUrl();
		String apiKey = MerakiCloudConfigManager.getApiKey();
				
		return HttpClientUtils.get(apiBaseUrl + url, (config)->{
                                   config.addHeader("Content-type", "application/json;charset=UTF-8")
                                         .addHeader(KEY_HEADER, apiKey);
                               })
                                .when(
                                    success->{ //成功处理并直接返回
                                        return doResponse(success);
                                    }, 
                                    err->{  //失败，处理并直接返回
                                        return StringResult.ofErrResult(null, err);
                                });
	}
```

 + **getException()**：获取异常，如果调用失败。通常会抛出异常，用本方法获取异常信息。

 + **getHeaders()**：获取响应头信息。（数组）

 + **getCookies()**：获取响应`Cookies`。（Map）

 + **getStatusCode()**：获取响应的`http`状态码

 + **ifHeaderIs(header, value, Consumer)**：Lambda 式的处理，如果包含某个头信息，则执行后面 `Consumer`。请求成功才会有机会执行这个方法。

```java
   HttpClientUtils.get(url)
                  .ifHeaderIs("x-event", "push", result->{
                      System.out.println("Push 成功.");
                  })
                  .fail(err->{
                      System.out.println("Push 失败");
                  });
```

 + **ifCookieIs(header, value, Consumer)**：Lambda 式的处理，如果包含某`Cookies`信息，则执行后面 `Consumer`。请求成功才会有机会执行这个方法。

 + **JSONObject toJson()**：将结果转换为`JSONObject`(Fastjson 类库)

```java
  public JSONObject get(String url){
      HttpServerResponse result = HttpClientUtils.get(url);
      if(result.statusCodeIs2xx()){
          return result.toJson();
      }else {
          return null;
      }
  }      
```

 + **DataResult<T> toObject(Class<T> entityClazz)**：直接将成功返回的`JSON`转为类`Class<T>`对象

```java
  public DataResult<ServerUser> get(String url){
      HttpServerResponse result = HttpClientUtils.get(url);
      if(result.statusCodeIs2xx()){
          return result.toObject(ServerUser.class);
      }else {
          return DataResult.ofErrResult(null, result);
      }
  }      
```

 + **ListResult<T> toObjects(Class<T> clazz)**：直接将成功返回的 `JSON`数组转为类`Class<T>`列表

```java
  public ListResult<ServerUser> getUsers(String url){
      HttpServerResponse result = HttpClientUtils.get(url);
      if(result.statusCodeIs2xx()){
          return result.toObjects(ServerUser.class);
      }else {
          return ListResult.ofErrResult(null, result);
      }
  }      
```

#### 3.3 Get 操作

 + **HttpServerResponse get(url, SetRequestConfig)**：定制 `get` 请求，请求参数用`SetRequestConfig`加入

```java
	HttpServerResponse result = HttpClientUtils.get("http://172.22.251.121:8080/explore/repos", 
                                    (config)->{
                                        config.addParam("q", "Doc")
                                              .addParam("tab", "");
                                    });
	result.done(v->System.out.println("Result:" + v))
	      .fail(err->{
	    	  System.out.println("错误:" + result.getException());
	      });
```

 + **HttpServerResponse get(url)** : 使用 `get` 方法请求

 + **HttpServerResponse get(url, userName, password)**：使用 `Authen Basic`认证的服务器 `get`请求

 + **HttpServerResponse get(url, UserNameAndPassword)**：使用 `Authen Basic`认证的服务器 `get`请求

    其中参数`UserNameAndPassword`是一个包含获取`UserName`和`Password`的接口。

 + **HttpServerResponse get(url, Map<String, Object>)**：带请求参数（由Map提供）的`get`请求

 + **HttpServerResponse get(url, Object)**：带请求参数（用对象属性）的`get`请求

     将遍历参数`Object`的所有属性，然后加入到 `url`作为参数

 + **<T> DataResult<T> get(url, Class<T>)**：发出`get`请求，并将得到的`JSON`数据转成`Class<T>`对象返回

    要注意，返回的结果必定是`JSON`数据才能正确转换。

 + **<T> ListResult<T> getList(url, Class<T>)**：发出`get`请求，并将得到的`JSON`对象数组转成`Class<T>`组成的列表

 + **<T> DataResult<T> get(url, Map<String, Object>, Class<T>)**：发出带参数（由Map提供）的`get`请求，并将得到的`JSON`数据转成`Class<T>`对象返回

#### 3.4 Post 操作

 + **HttpServerResponse post(url)** : 使用 `post` 方法请求

 + **HttpServerResponse post(url, SetRequestConfig)**：定制 `post` 请求，请求参数用`SetRequestConfig`加入

 + **HttpServerResponse post(url, json, userName, password)**：向使用 `Authen Basic`认证的服务器 发送`post`请求

 + **HttpServerResponse post(url, json, UserNameAndPassword)**：向使用 `Authen Basic`认证的服务器 发送`post`请求

    其中参数`UserNameAndPassword`是一个包含获取`UserName`和`Password`的接口。

 + **HttpServerResponse postHttpEntity(url, HttpEntity)**：使用外部定义的数据体`HttpEntity`来发送`post`请求

 + **HttpServerResponse post(url, json)**：向服务器端`post`发送一个`json`数据

 + **HttpServerResponse postXml(url, xml)**：向服务器`post`发送 `xml`数据（Playbody发送）

 + **<T> DataResult<T> post(url, Class<T>)**：发出`post`请求，并将得到的`JSON`数据转成`Class<T>`对象返回

    要注意，返回的结果必定是`JSON`数据才能正确转换。

 + **<T> DataResult<T> post(url, json, Class<T>)**：向服务器端`post`发送一个`json`数据，并将得到的`JSON`数据转成`Class<T>`对象返回

    要注意，返回的结果必定是`JSON`数据才能正确转换。

 + **<T> DataResult<T> post(url, Map<String, Object>, Class<T>)**：向服务器端`post`发送一个`Map`数据，并将得到的`JSON`数据转成`Class<T>`对象返回

    要注意，返回的结果必定是`JSON`数据才能正确转换。


#### 3.5 Put 操作

 + **HttpServerResponse put(url, json)** : 向服务器端`put`发送一个`json`数据

 + **HttpServerResponse put(url, SetRequestConfig)**：定制 `put` 请求，请求参数用`SetRequestConfig`加入

 + **HttpServerResponse put(url, json, userName, password)**：向使用 `Authen Basic`认证的服务器 发送`put`请求

 + **HttpServerResponse put(url, json, UserNameAndPassword)**：向使用 `Authen Basic`认证的服务器 发送`put`请求

    其中参数`UserNameAndPassword`是一个包含获取`UserName`和`Password`的接口。

#### 3.6 Delete 操作

 + **HttpServerResponse delete(url)**：发送`delete`请求

 + **HttpServerResponse delete(url, Map<String, Object>)**：发送带参数（由Map提供）的`Delete`请求

 + **HttpServerResponse delete(url, userName, password)**：向使用 `Authen Basic`认证的服务器 发送`delete`请求

 + **HttpServerResponse delete(url, json, UserNameAndPassword)**：向使用 `Authen Basic`认证的服务器 发送`delete`请求

    其中参数`UserNameAndPassword`是一个包含获取`UserName`和`Password`的接口。

+ **HttpServerResponse delete(url, SetRequestConfig)**：定制 `delete` 请求，请求参数用`SetRequestConfig`加入

#### 3.7 上传与下载 操作

 + **HttpServerResponse postFile(url, final Map<String, File>)**：向`url`上传一批文件（由Map<文件名, File>提供文件描述）

 + **void download(url, saveFile)**：将`url`(Post 请求)所提供的文件下载到本地，并以文件名`saveFile`保存

 + **HttpServerResponse download(url, Map<String, Object>, String saveFile)**：带参数的`post`下载

 + **HttpServerResponse downloadGet(url, saveFile)**：`Get`请求的下载操作

 + **HttpServerResponse getStream(url, OutputStream)**：`Get`请求下载到一个流（不是文件）

#### 3.8 最基本请求操作

 + **HttpServerResponse request(HttpRequestConfiguration)**：最基本请求，请求方法与数据，全由外部提供

 + **void shutdown()**：使用之后，关闭所有连接（池）释放资源。
