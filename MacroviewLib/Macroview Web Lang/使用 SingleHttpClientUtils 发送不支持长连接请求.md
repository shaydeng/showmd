　　我们知道，可以使用 HttpClientUtils 来向 Http 服务器发送请求，特别是在提供 REST API 的应用场合中，使用非常简单方便。

　　不过，HttpClientUtils 里面封装了连接池，如果服务器支持 KeepaLive 属性，HttpClientUtils 使用得很好，但是如果服务器不支持 keepalive (即设置为0值）时，HttpClientUtils 容易产生错误。在这种情况下可以使用 SingleHttpClientUtils 来代替 HttpClientUtils 。 

　　SingleHttpClientUtils 顾名思义，不使用连接池，每次都是创建一次连接，用完就关闭。由于 SingleHttpClientUtils 的 API 跟 HttpClientUtils 几乎一样，所以同样易学易用。

  + **Get 请求与返回值**
  
 ```Java
    //最简单的的 Get 请求
    String value = SingleHttpClientUtils.get("http://wwww.baidu.com"); //最简单的 Get 请求，并返回字符串结果
	
	//带参数的的 Get 请求
	Map<String, Object> params = new HashMap<>();
	params.put("UserName", "Jai");
	String value = SingleHttpClientUtils.get("http://my.server.com/api/getUser", params);  //带参数的 Get 请求
	
	//带参数与请求头的 Get 请求
	Map<String, Object> params = new HashMap<>();
	params.put("UserName", "Jai");
	
	Map<String, String> headers = new HashMap<>();
	headers.put("Basic", "qowjlojv-aqweq3r3==");
	
	String value = SingleHttpClientUtils.get("http://my.server.com/api/login", headers, params); 
```

  + **GetExt() Get 请求并将返回的JSON转为对象**  

```Java

   //使用默认的请求参数发起 Get 请求，并将 JSON 值转为对象
   User user = SingleHttpClientUtils.getExt(
                                         "http://my.server.com/api/getUser", 
										 new HttpRequestConfiguration()
									 )
                                    .toObject(User.class);
									
   //HttpResponseData getExt(url, HttpRequestConfiguration) 中的 HttpRequestConfiguration 参数，可以设置请求参数，请求头，超时等等 
   //而返回值 HttpResponseData 则可以得到响应头，响应值，Cookies 等等
```  

  + **Post 请求与返回值**
  
```Java
  
  //Post 请求与 Get 请求使用一样
  
  //Post 最简单的请求
  String value = SingleHttpClientUtils.post("http://my.server.com/api");
  
  //Post Json 数据
  User user = new User();
  user.setName("Jai");
  String value = SingleHttpClientUtils.post("http://my.server.com/api/user", JSON.toJSONString(user));
  
  //Post 带参数请求
  Map<String, Object> datas = new HashMap<>();
  datas.put("UserName", "Jai");
  String value = SingleHttpClientUtils.post("http://my.server.com/api/getUser", datas);
```  

  + **PostExt() Post 请求并将返回的JSON转为对象**  

```Java

   //使用默认的请求参数发起 Post 请求，并将 JSON 值转为对象
   User user = SingleHttpClientUtils.postExt(
                                         "http://my.server.com/api/getUser", 
										 new HttpRequestConfiguration()
									 )
                                    .toObject(User.class);
									
   //HttpResponseData postExt(url, HttpRequestConfiguration) 中的 HttpRequestConfiguration 参数，可以设置请求参数，请求头，超时等等 
   //而返回值 HttpResponseData 则可以得到响应头，响应值，Cookies 等等
```  


