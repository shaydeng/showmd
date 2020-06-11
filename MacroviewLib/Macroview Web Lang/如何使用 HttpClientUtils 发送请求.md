
　　本章内容只适用于 1.x 的版本，2.x 版本有比较大的变更。

　　HttpClientUtils 是对 Apache HttpClient Component 库的一个简单封装。封装的目的就是，将 HC 化繁为简，为80%的请求应用提供简单而用的功能。使用 HttpClientUtils 不需要你了解 HC 内部复杂的组织结构，而只需要关注你的请求动作即可，下面举例说明这个工具类的使用。

   + __单纯的 Get 请求和返回值__
   
		String result = HttpClientUtils.get("http://www.baidu.com")
									   .call()
								       .toText();
   
		//没什么高深的内容，理解也容易，给出 URL，然后 Call()，将结果以文本方式输出


		// 返回 Json 也容易
		JSONObject result = HttpClientUtils.get("http://www.baidu.com")
										   .call()
										   .toJson();

		// 返回 JavaPojo 也没问题
		User result = HttpClientUtils.get("http://www.baidu.com")
									 .call()
									 .toObject(User.class);


   + __带参数的 Get 请求__
   
		String result = HttpClientUtils.get("http://sdm.macroview.com")
									   .addParam("user", "Jai")
									   .call()
									   .toText();  
 
		//加参数也容易，就多了一个 addParam() 方法

		String result = HttpClientUtils.get("http://sdm.macroview.com")
									   .addParam("user", "Jai")
									   .addParam("email", "jai_lin@macroview.com")
									   .call()
									   .toText();  

		// 参数比较多，不想一个一个 add，那也可以弄成 Map，然后一次过添加

		Map<String, Object> params = new HashMap<>();
		params.put("user", "Jai");
		params.put("email", "jai_lin@macroview.com");
		params.put("phone", 245);

		String result = HttpClientUtils.get("http://sdm.macroview.com")
									   .addParams(params)
									   .call()
									   .toText();  

		//参数是 JavaPojo 又如何？。。一样没问题

		User user = User.dao.findByName("Jai");
		String result = HttpClientUtils.get("http://sdm.macroview.com")
									   .addParams(user)
									   .call()
									   .toText();  

   + __带 Header 的 Get 请求__
   
		//跟添加参数一样的使用
		String result = HttpClientUtils.get("http://sdm.macroview.com")
									   .addHeader("accept-language", "zh-CN")
									   .call()
									   .toText();  
 
		//跟添加参数一样的使用，添加 map
		String result = HttpClientUtils.get("http://sdm.macroview.com")
									   .addHeaders(map)
									   .call()
									   .toText();  

   + __单纯的 Post 请求__
 
		// Post 请求与 Get 请求的操作是一样的
		String result = HttpClientUtils.post("http://192.168.11.137")
									   .call()
								       .toText();

		// 返回 Json 也容易
		JSONObject result = HttpClientUtils.post("http://www.baidu.com")
										   .call()
										   .toJson();

		// 返回 JavaPojo 也没问题
		User result = HttpClientUtils.post("http://www.baidu.com")
									 .call()
									 .toObject(User.class);

		// Post 发送 json
		String result = HttpClientUtils.postJson("http://192.168.11.137", "{\"a\":10}")
									   .call()
								       .toText();

		// 甚至还可以更简单一些，如果单纯 Post 发送 json
		String result = HttpClientUtils.postAndCall("http://192.168.11.137", "{\"a\":10}")
								       .toText();


   + __带参数的 Post 请求__
   
		//使用与 Get 完全一样，这里就不举例子了
 
   + __获取不同类型的返回值__
   

		//看上面的例子就可以知道

   + __获取响应的 Header__

		//希望能够得到服务器响应的头信息（Headers）
		Map<String, String> headers = new HashMap<>();
		String result = HttpClientUtils.get("http://www.baidu.com")
									   .call()
									   .peekResponseHeader(headers)  // 这样得到响应头
								       .toText();


   + __获取响应的 Cookies__

		//希望能够得到服务器响应的 Cookies 
		Map<String, String> cookies = new HashMap<>();
		String result = HttpClientUtils.get("http://www.baidu.com")
									   .call()
									   .peekResponseCookies(cookies)  // 这样得到 cookies
								       .toText();

   + __其他的一些使用方式__

		//设置超时时间
		String result = HttpClientUtils.get("http://www.baidu.com")
									   .setConnectTimeout(10 * 1000) // 10 秒超时
									   .call()
									   .toText();
