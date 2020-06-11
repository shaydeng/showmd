                 
　　Macroview Web Framework 是为小型 Web 项目定制的快速开发框架。MWF 尽可能地简化 Web 本身的开发内容，包括：

   + 使用 Servlet 3.x 版本

   + 框架本身的零配置；

   + 简单易用的注解；

   + 映射方法参数的绑定等等。

　　目前 MWF 的最新版本为 1.10.3，我们如何创建一个 MWF 项目呢？下面简单说明如何进行：

   + 使用 Maven 创建一个 Web 项目。

      - Eclipse Maven Project 创建向导能够帮助我们快速创建一个 Maven Web 项目

      - 注意，Eclipse 创建的 Web 项目，有可以还是 Servlet 2.x 的内容，这时候需要将 WEB-INF/web.xml 修改为 Servlet 3.x 格式。最简单的 web.xml 就是一个空的文件

                <?xml version="1.0" encoding="UTF-8"?>  
                <web-app version="3.0" xmlns="http://java.sun.com/xml/ns/javaee"  
                          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  
                          xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/web-app_3_0.xsd">

                    <display-name>Web 应用名称</display-name>

                </web-app>

   + 添加 MWF 的依赖

                <dependency><!-- 基础工具类库 --->
                    <groupId>com.macroview</groupId>
    	            <artifactId>macroview-lang</artifactId>
    	            <version>1.8.0</version>
                </dependency>
                
                <dependency><!-- 用来扫描注解 -->
                    <groupId>com.macroview</groupId>
                    <artifactId>macroview-container</artifactId>
                    <version>0.1.12</version>
                </dependency>
                
                <dependency><!-- 一个简单易用和强大的 ORM 类库，本类库可选 -->
                    <groupId>com.macroview</groupId>
                    <artifactId>macroview-db</artifactId>
                    <version>1.4.5</version>
                </dependency>
                
                <dependency> <!-- MWF 框架 -->
                    <groupId>com.macroview</groupId>
                    <artifactId>macroview-web-framework</artifactId>
                    <version>1.10.0</version>
                </dependency>



   + 基本上就完成了一个 MWF 项目


