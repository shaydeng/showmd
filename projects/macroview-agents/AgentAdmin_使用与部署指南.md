
## x1. 说明 ##

 + 本文档描述了用 `Java` 开发的 AgentAdmin 的部署方法

 + 由于 `AgentAdmin` 能够作为一个相对独立的模块，嵌入到其他 `应用` 当中，因此本文档所指的 `使用` 是指，如何将 `Admin`模块嵌入到应用当中，而非 `Admin` 的使用手册。

 + 关于 `AgentAdmin` 的嵌入应用，是指：能嵌入使用 `MWF` 开发的应用中，暂不支持其他的开发框架的应用

## x2. 部署 ##

　　**`AgentAdmin`** 本身是一个标准的 `Servlet Web` 应用程序，能够部署到标准的 `Servlet` 容器当中，例如 **`Tomcat`** (8.x+)。

### x2.1 相关项目 ###

　　**`AgentAdmin`** 本身由以下三个项目组成：

 + macroview-agent-admin：这是逻辑实现的核心项目，包含了所有的实现代码，自身可以单独打成一个 `Jar` 包。

 + macroview-agent-admin-web：包含了项目所使用的界面（JSP 文件）与静态资源

 + macroview-agent-admin-main：作为独立的 `Servlet` 应用，本身包含了 `macroview-agent-admin` 与 `macroview-agent-admin-web` 成为一个完整的应用，如果作为单独的 `AgentAdmin` 使用部署时，就是将本项目进行打包部署。 

　　还有一个是依赖项目：

 + macroview-agent-commons：一些依赖库与实现


### x2.2 部署单独的 AgentAdmin ###

#### x2.2.1 需求清单 ####

　　下面是一个简单的需求清单：

 | 系统 | 版本 | 说明 |
 |-|-|-|
 | JDK/OpenJDK | v8.x  | 只能使用 JDK/OPENJDK 8，更高的版本需要额外的内容，因此标准版暂只支持 JDK8 的版本 |
 | Tomcat      | v8.x+ | 建议使用 8.5.x 这个版本的最新版，8.0.x 这个系列基本上停止更新 |
 | MySQL       | v5.7+ | 通常建议使用 5.7 的最新版，也可以使用 8.x 的，但未经测试 |
 
#### x2.2.2 项目打包 ####

　　当我们将 `AgentAdmin` 本身部署到 `Servlet 容器` 里运行时，就是将 `macroview-agent-admin-main` 进行打包部署。

　　我们只需要按照标准的 `war` 打包操作即可，也就是使用 `maven` 执行下面的打包命令：

```shell
mvn package -Dmaven.test.skip=true
```

　　命令运行成功结束后，就会得到一个可以放到 `Servlet 容器`（如 Tomcat）里部署运行的 `war` 文件。

#### x2.2.3 数据库初始化 #### 

　　可以在项目的 `/doc/sql` 目录中找到要部署版本的 `macroview_agent_admin_last.sql` 文件，一般来说新部署的应用，就使用这个 sql 文件来初始化数据库。 

    注意：初始化登录帐号是 `admin/M@croview`

### x2.3 嵌入 AgentAdmin ###

　　**注意：这里所指的，能够嵌入 AgentAdmin 的应用，也应该是使用 MWF 框架开发的应用，暂不支持嵌入到其他框架开发的应用中去**

#### x2.3.1 添加依赖 ####

　　事实上，我们可以将 `AgentAdmin` 作为一个模块加入到应用当中。

　　方法也比较简单，只需要在应用项目中加入下面的依赖即可：

```xml
<dependency>
    <groupId>com.macroview.agent</groupId>
    <artifactId>macroview-agent-admin</artifactId>
    <version>1.0.0</version>
</dependency>

<dependency>
    <groupId>com.macroview.agent</groupId>
    <artifactId>macroview-agent-admin-web</artifactId>
    <type>war</type>
    <version>1.0.0</version>
</dependency>
```

#### x2.3.2 数据库方面 ####

　　可以在项目的 `/doc/sql` 目录中找到要部署版本的 `macroview_agent_admin_last.sql` 文件。

　　如果应用本身是支持数据库的应用，其实不需要手工进行数据库方面的处理，`Macroview-DB` 在项目启动时会自动创建相关的数据表。

