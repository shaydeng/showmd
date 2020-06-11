
### ※ 文档摘要

　　本文档说明 Macroview-app-base 类库的内容

### ※ 文档内容

　　`Macroview App Base` 类库，提供一个项目中，基础组成部分的一些抽象内容和增强基础类。

#### ■ DB 方面的增强类

 + **AppBaseModel** 类。提供了一些分页查询方法，进一步简化分页操作。

    `分页`是我们在开发过程中，常常遇到的一种数据记录显示方式。而`分页`处理的核心，就是`分页`查询，通过页号与页大小，再加上其他的查询条件，成了`分页`查询共有的特性。下面是添加的方法：

    - queryWithDefaultPageBean(...) ：使用 DefaultPageBean 及子类来分页查询数据。

    - queryWithPagination(...)：使用 DefaultPageBean 及子类来分页查询，并将数据记录映射到给出的类

    - findByPageBean(...)：使用 DefaultPageBean 来构建查询条件进行查询，最终返回列表数据。

    - queryData(...)：使用sql 来查询数据

    **不过，在通常情况下，很少会使用本类，而是使用本类的子类 `HasCreateTimeEntity`。**

 + **HasCreateTimeEntity** 类。
 
     它是 **AppBaseModel** 的子类，具有其的有功能，并提供了一个 “createTime” 字段，所以在继承本类后，不再需要定义“createTime”这个字段了。

     在项目开发的实践当中，我们常常会建议每一个表，除非有特殊情况，否则都会带上“createTime”字段，作为记录的时间戳。**换句话来说，除非有特殊原因，所有的实体类都应该继承本类。**

```Java
 //标准的使用范例
 
 @Table
 @Entity
 public class User extends HasCreateTimeEntity{
 
     public final static User dao = new User();  //可以看作是 DAO 

     private String name;

     private String jobTitle;

     //...其他字段
     public String getName(){
         return name;
     }

     public void setName(String name){
         this.name = name;
     }

    //...其他 set/get 方法
 }
```

 + **AppRepository** 类。类似 `AppBaseModel`，专用于`贫血模型`下，作为数据仓库的父类使用，它所提供的方法跟 `AppBaseModel`一样。

#### ■ 分页

　　待续

#### ■ 多任务执行

　　我们在开发过程中，通常会遇到多任务情况。也就是在后台（服务器端）执行一些即时或定时任务，例如定时清除数据；定时发送邮件；定时同步数据等等。

　　为了方便管理与使用，本类库提供了一个简单的任务执行管理器：`AppWorkerManager`。这个任务管理器，会在系统启动时，自动启动并执行管理器中的任务。

　　一般来说，我们都会建议使用这个管理器来执行任务。

+ **AppWorkerManager** ：多任务执行与管理类

    `AppWorkerManager`是一个静态类，所提供的方法基本都是静态方法。再次强调：在我们的项目当中，本类是在系统启动时，通过 `ServletInitListener`来初始化并启动，不需要手工干预。

    - submitWorker(Appworker)：提交一个继承自 `Appworker`的定时任务类，定时执行任务。

    - executeWorker(Appworker)：执行一次性的任务，不需要定时执行。

    - execute(Runnable)：执行一次性的任务

    - stopAndRemoveWorker(Appworker)：尝试停止和移除任务

+ **AppWorker**：这是一个继承自 `Runnable` 的接口，是任务管理器中任务所需要实现的接口。

    本接口提供一些方法需要实现，不过类库中同时提供一些特定的接口实现类，可以继承这些类来快速实现一些功能和减少工作量。并且，更重要的是，**这些子类的内部能够释放数据库连接，避免连接泄漏！**

    - getDelay()：要延迟多长时间，才进行第一次的启动。用来控制任务的首次启动时间。

    - getTimeUnit()：时间单位，是秒，分钟，小时，天等等

    - getAppName()：任务名称，通常要求唯一。任务名称用来追踪任务的运行情况使用。

    - getPeriod()：上一次结束到下一次启动的时间间隔

+ **SimpleAppWorker**：简单定时任务基类

    它是`Appworker`的一个实现，定义以秒为单位，名称使用  class.getSimpleName() 即类的名称。因此，当你继承了此类时，只需要实现 `getPeriod()`（即给出定时任务的执行周期） 方法即可。减少了工作量，也简化了类的维护。

+ **LoopWorker**：无限循环任务类，通常用于类似“生产者-消费者”这样的任务形式。

+ **BlockingQueueWorker<T>**：带一个无界阻塞队列，并且是无限循环的任务抽象类，此类可用于提供队列服务的任务类

　　使用示例：

```Java
 //定义一个定时任务类
 public class MyWorker extends SimpleAppWorker {

     @Override
     public long getPeriod(){
         return 3600;  //即每隔一个小时执行一次任务
     }

     /**
      * 侦听 ServletInitEvent 事件，此事件是系统启动完成时发布。侦听此事件，用来将任务添加到管理器
      */
     @Observes
     public void startWorker(ServletInitEvent event){
         AppWorkerManager.submitWorker(this); //将任务添加到任务管理器，由管理器启动并执行任务
     }
 }
```