
## 1. 文档摘要

　　本文档说明开发组自定义的一些 Tag 的使用。

## 2. 文档内容

### 2.1 Tag 的引用

　　需要在 `JSP` 文件头加入 `Tag`的引用：

```jsp
<!-- 定义的一些函数 -->
<%@ taglib uri="/WEB-INF/mf.tld" prefix="mf"%>

<!-- 继承 Tag Block/override -->
<%@ taglib uri="/WEB-INF/mv.tld" prefix="mv"%>

<!-- 一些 JSP 组件 -->
<%@ taglib tagdir="/WEB-INF/tags/macroview" prefix="m"%>
```

### 2.2 mf: 自定义函数

#### 2.2.1 <mf:formatDateByLong(long, String) />

    将日期长整数格式化成字符串输出

    这是日期转换方法，可以将日期以指定模式（第二个参数）格式化输出

```jsp
<!-- 定义的一些函数 -->
<%@ taglib uri="/WEB-INF/mf.tld" prefix="mf"%>

创建日期：<mf:formatDateByLong(createTime, 'yyyy-MM-dd HH:mm:ss') />
```
 + **<mf:formatDateByUnixTime(long, String) />** 将 Unix 时间长整数转为 Java 时间，然后格式化输出

 + **<mf:formatMemoryFor1000(long, String) />** 将字节数转为 KB，MB，GB

    要注意，转制是以 `1000`来转换，而不是 `1024`。转换结果是不带单位的数字字符串

```jsp
<!-- 定义的一些函数 -->
<%@ taglib uri="/WEB-INF/mf.tld" prefix="mf"%>

文件大小：<mf:formatMemoryFor1000(size, 'MB') />
```

#### 2.2.2 <mf:secondToTimeStr(second) />

    将秒数格式化成 `HH:mm:ss` 输出

```jsp
<!-- 定义的一些函数 -->
<%@ taglib uri="/WEB-INF/mf.tld" prefix="mf"%>

上线总时间：<mf:secondToTimeStr(loginTime) />
```

#### 2.2.3 <mf:inArray(String, Object) />

    判断某个字符串是否在某列表内

    第二个参数可以是一个数组，也可以是一个实现 `List`接口的列表对象

#### 2.2.4 <mf:inMap(String, Map) />

    判断某个Key值，是否在Map中

### 2.3 mv: 为 JSP 文件提供继承

　　我们知道，每个项目界面都会存在一个固定的框架结构，这是界面一致性的需要。而这些固定的框架结构，在代码里往往会带来很多重复的内容，我们可以通过页面继承的方式来复用这些内容，避免过多的复制粘贴带来不便。

　　页面继承的好处在于：

  + **简化页面代码**
  + **更突出页面差异（内容）**
  + **更好的可维护性**

　　本页面继承由两个`tag`组成：

#### 2.3.1 <mv:block name='名称标识'>

    本标签就是定义一个可继承块，表示块的内容可以被`子页`覆盖。`tag`的名称属性必须唯一，子页需要使用这个名称来定位要继承的块。

#### 2.3.2 <mv:override name='名称标识'>

    覆盖父页中的块

    本标签通常用在“子页”，表示要覆盖的内容。当子页的某块内容与父页不同时，可以使用本标签来覆盖父页内容。

　　下面是一个典型示例：(页面模板)

```jsp
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page isELIgnored="false"%>
<%@ taglib uri="/WEB-INF/c.tld" prefix="c"%>
<%@ taglib uri="/WEB-INF/mv.tld" prefix="mv"%>
<%@ taglib tagdir="/WEB-INF/tags/macroview" prefix="m"%>
<!-- 标签引用 -->

<!DOCTYPE html>
<html>
<head>
	<title>云平台管理</title>
    <!-- 使用 jsp:include 引入每个页面都要的内容 -->
	<jsp:include page="/WEB-INF/views/head.jsp"></jsp:include>

	<style type="text/css">

	</style>
    <!-- 定义一个头部块，以便子页能够定义自己的 style 等 -->
	<mv:block name="head">
	
	</mv:block>
	
</head>
<body id="app-body" class="hold-transition skin-black-light sidebar-mini">

	<div id="app-wrapper" class="wrapper" >
		<header class="main-header"> <!-- 固定内容，每个页面必须要　-->
	        <jsp:include page="/WEB-INF/views/head_bar.jsp"></jsp:include>
		</header>
		  
		<!-- 左边菜单项 Left side column. contains the logo and sidebar -->
		<aside class="main-sidebar">
			
		  	<!-- sidebar: style can be found in sidebar.less -->
			<section id="left-sidebar" class="sidebar">
                <!-- 左边栏菜单并非所有页要都需要，所以设置为可继承块，不需要时可以覆盖 -->
				<mv:block name="main_left_sidebar">
					<jsp:include page="/WEB-INF/views/mainMenu.jsp"></jsp:include>
				</mv:block>		    		
		  	</section>
		  	<!-- /.sidebar -->
		</aside>
		  
		<!-- 主区域 -->
		<div class="content-wrapper" style="min-height:922px;">

		  	<!-- Content Header (Page header) 主区域头信息区，子页可以定制自己的信息区 -->
		  	<section class="content-header">
				<mv:block name="main-content-header">
			
				</mv:block>			
		  	</section>
		
		  	<!-- Main content 主工作区域，子页可以定制自己的工作内容 -->
		  	<section class="content">
				<mv:block name="main-content-area">
			
				</mv:block>			
		  	</section>
		  
		  <!-- /.content -->
		</div>
		<!-- /.content-wrapper -->		  
		  
		  
		<footer class="main-footer">
		</footer>
	</div><!-- div.wrapper -->

	<jsp:include page="/WEB-INF/views/footer.jsp"></jsp:include>	
	
	<script type="text/javascript">
		$(document).ready(function(){
			var hv = $("#host-view").attr("menu-item");
			$("#left-sidebar ul.sidebar-menu > li.active").removeClass("active");
			$("#left-sidebar ul.sidebar-menu > li#" + hv).addClass("active");			
		});
	</script>

    <!-- 子页需要覆盖本块，编写自己的 javascript 内容 -->
	<mv:block name="script_content">
		<script type="text/javascript">
			window.location.href = "${BaseContextPath}/dashboard/index";
		</script>			
	</mv:block>  

</body>
</html>
```

　　在上面模板页布局下，继承页的示例：

```jsp
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page isELIgnored="false"%>    
<%@ taglib uri="/WEB-INF/c.tld" prefix="c"%>  
<%@ taglib tagdir="/WEB-INF/tags/macroview" prefix="m"%>
<%@ taglib uri="/WEB-INF/mv.tld" prefix="mv"%>

<!-- 引入头区域，用来增加新 js -->
<mv:override name="head">
	<script type="text/javascript" src="${BaseContextPath}/static/vue/vue.min.js"></script>	
	<script type="text/javascript" src="${BaseContextPath}/static/vue/vue-Pagination.js"></script>
</mv:override>
<!-- 其他的没有覆盖，表示保留（继承）下来 -->
<!-- 编写主体内容 -->
<mv:override name="main-content-area">
	<div id="host-view" menu-item="RadiusSessionManager" class="row">
		<div class="col-md-12 my-margin-10">
			<div id="session-content" class="panel panel-default panel-border-default z-depth-1 " style="margin-right:20px;">
				<div class="panel-heading header-title-font">会话列表</div>
				<div class="panel-body">
                    .... (主体页面内容省略)
				</div>
			</div>
		</div>
	</div>
</mv:override>

<!-- 引入 javascript 区域，编写本页的 javascript -->
<mv:override name="script_content">
	<script type="text/javascript" src="${BaseContextPath}/static/plugins/moment.min.js"></script>
	<script type="text/javascript">
		$(document).ready(function($) {
		});	

	</script>

</mv:override>

<!-- 这是重点内容，表示本页继承自 index.jsp 这个页面 -->
<%@ include file="../index.jsp" %>
```

　　从最后一条可以知道，我们可以定义多个模板页，然后在其他地方继承使用。

### 2.4 m: 为 JSP 提供组件

　　将复杂多变的内容封装成`JSP`标签，目的在于简化使用，提供可维护性。

#### 2.4.1 <m:i18n message='key'>

    输出 `i18n`字符串，根据`key`来得到当前语言下对应的字符串

```jsp
<%@ taglib tagdir="/WEB-INF/tags/macroview" prefix="m"%>

  <!-- 在中文状态下，显示 "姓名"，在英文状态下，显示 "User Name">
  <m:i18n message='form.input.user'>:<input type="text" name="userName">
```

#### 2.4.2 <m:table>

    表格标签组件

　　表格标签组件目的就是简化表格的构建。在 HTML 中，列表标签对应是 **`<table>`** 标签。 table 标签并不是一个独立使用的标签，还需要列标签的配合，才能显示一个完整的列表。在标签库中，表格标签是**`<m:table>`**，列标签是**`<m:column>`**（**注意：0.x 版本使用 column，而到了 2.x 版本时，建议用 td 替代 column**）。表格标签定义表格本身的样式，而列标签则定义每一列的显示内容。
  
　　要注意，列表组件是建立在所显示的每一行对应一个对象（即对象列表），而每一列对应要显示对象的属性。例如 User 列表（帐号列表），列 “名称” 则对应 User 的 name 属性。

　　标签库中关于列表组件的定义如下：
```jsp  
  
  <m:table id="id" tableClass="css 类名" items="列表显示的items" pagination="true/false 是否需要分页" onPageGoto="分页组件的显示方法">
     <m:column id="列id" tdClass="css 类名" property="item 对象的属性/#/$" title="列的标题" propertyType="属性类型" format="内容显示格式化串" /> 
  </m:table>
  
  /**
   * <m:table> 标签参数：
   *   id          ---- 这是表格的 id，为必选项，通常为了方便操作，我们也应该为其提供一个 id
   *   tableClass  ---- 表格格式，标签内定样式为“table table-striped table-hover” （Bootstrap 条纹状，鼠标悬停）
   *   items       ---- 这是要显示的对象记录（数组或列表），要注意，如果带分页时。记录集应该是 items.content 
   *   pagination  ---- 是否需要分页显示，true 表示显示分页组件（使用了 <m:pagination> 标签），此时items 应该带分页信息数据，false 为不需要。
   *   onPageGoto  ---- 对应分页组件中的翻页事件
   *
   * <m:column> 标签参数：
   *    id         ---- 列 id，可选
   *    tdClass    ---- 列 css 类名，我们可以用这个属性来为 jquery 提供辅助选择
   *    property   ---- 有三种类型值选择： 
   *                     1）# 值，表示此列为序号（即自动生成的 1, 2, 3... 序号）
   *                     2）$ 值，表示此列为自定列，可以自定义列的内容。在内部，我们可以通过一个名称为 varColumnBean 的变理来引用当前记录的各个属性值
   *                     3）对象属性名称，自动显示对象的属性值
   *    title      ---- 列标题（表格中每列的标题）
   *    propertyType、format  ---- 目前，这两个属性仅用于 日期类型的格式化显示：propertyType='date' 固定值，然后format 给出日期格式化串，如: yyyy/mm/dd
   */
   
   //下面是一些使用示例
   //1. 不使用分页
   //  users ---> List<User> 
   <m:table id="mytable" property="${users}">
      <m:column property="#"/>   <!-- 第一列为序号 -->
      <m:column proeprty="name" title="帐号名称"/>
      <m:column property="createTime" title="创建日期" propertyType="date" format="yyyy/MM/dd"/>  <!-- 日期显示格式为 2015/02/21 -->
      <m:column proeprty="$" title="操作">   <!-- 自定义列内容，显示删除按钮，用来删除帐号,  varColumnBean.id 表示为此行的 user 的 id -->
          <button type="button" class="btn btn-default delete-btn" data-userid="${varColumnBean.id}">删除</button>
      </m:column>
   </m:table>
   
   //2. 使用分页
   //  UserListBean extends DefaultPageBean  ( 或至少要实现方法：List<T> getContents()、get/setPageNo()、get/setPageSize()、getHasConent())
   <form id="myForm" name="form">
     <m:table id="mytable" property="${userList}" pagination="true" onPageGoto="myPageGoto">
        <m:column property="#"/>   <!-- 第一列为序号 -->
        <m:column proeprty="name" title="帐号名称"/>
        <m:column property="createTime" title="创建日期" propertyType="date" format="yyyy/MM/dd"/>  <!-- 日期显示格式为 2015/02/21 -->
        <m:column proeprty="$" title="操作">   <!-- 自定义列内容，显示删除按钮，用来删除帐号,  varColumnBean.id 表示为此行的 user 的 id -->
          <button type="button" class="btn btn-default delete-btn" data-userid="${varColumnBean.id}">删除</button>
        </m:column>
     </m:table>
   </form>
```


#### 2.4.3 <m:pagination> 分页标签

　　分页组件是我们做列表显示时所需要的组件。组件本身的内容不多，但是附加的零碎却不少，并且还得要与服务器端配合使用。在本节中，主要是介绍客户这部分的使用。

　　分页标签的使用语法如下：
```jsp
  <%@ taglib tagdir="/WEB-INF/tags/macroview" prefix="m"%>

  <m:pagination id="分页组件id" css="css类名" totals="总记录数" pageSize="每页记录数" pageNo="当前显示页号"
     select_size="true/false 显示自定义页面记录数组件" onPageGoto="点击页号事件"/>

  /**
   * 其中参数：
   *  id        --- 分页组件的id，这是必选项
   *  css       --- html css 的类名，可以定义自己的显示样式，是可选项
   *  totals    --- 记录总数，用来计算（显示）页码数量
   *  pageSize  --- 每页记录数的大小，默认为 20 条记录，可选
   *  pageNo    --- 当前显示的页码（即第几页的数据）
   *  select_size --- 显示自定义每页记录数的组件（即可选每页 20 条记录，40 条记录等等），取值为 true/false，true 显示表示，默认为 true
   *  onPageGoto  --- 用户选择页码时的事件处理名称，即点击页码翻页动作处理，如果这里不填，也可以侦听 mv.pagination.goto 事件来处理
   **/
   
   //下面是使用例子
   <form id="myForm">
      <m:pagination id="myPage" totals="100" pageNo="1" pageSize="20" onPageGoto="gotoPage"/>
   </form>
   
   <script type="text/javascript">
      function gotoPage(pageId){
          var pageNo = $("#myPage_pageNo").val(); //单独获取当前页码
          var datas = $("#myForm").serialize();  //也可以通过 form 来获取整个分页组件的数据
          //进行分页显示处理...
      }
      
      // 下面示例，通过事件侦听来处理页码选中
      $("#myPage").bind("mv.pagination.goto", function(pageId){
         var pageNo = $("#" + pageId + "_pageNo").val(); //单独获取当前页码
         ///...同上面一样
      });
   </script>
```

　　在服务器端，应该向 pagination 发送或接收的数据（分页）： totals（总数）、pageNo（当前页码）、pageSize（每页记录数）。在 Macroview App Base 开发组件中，对应的类是 ** `DefaultPageBean`**，我们可以继承这个类的基础上来作处理。

　　具体且详细的示例用法，可以参考：[分页开发指南](../Macroview%20DB/分页查询指南.md)

### 总结

　　使用自定义 JSP 标签的目的就是减少重复劳动，加快开发进度。所以，如果你发现有更好的方法或建议能够减少重复，利于系统维护，可以自己动手做一做或告诉给我知。



