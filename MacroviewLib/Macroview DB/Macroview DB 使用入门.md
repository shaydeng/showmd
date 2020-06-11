
@[toc](目录)

### Macroview DB

　　Macroview DB（MD） 是一个简单和易用的 ORM （对象与关系数据映射）框架，可以方便地将对象转为数据表记录，又或者将数据表记录转换为对应的对象。

　　当前 Macroview DB 的版本为 2.8.0 ，并使用与支持下面的技术内容提供操作服务。

  + **Apache DBUtils** : 框架的底层 JDBC 操作，使用 Apache DButils 来对 JDBC 进行封装。不过，在本框架中，有针对性地对 DButils 进行了一些修改，与原来的有所不同。
  
  + **JPA 注解**： Macroview DB 使用 JPA 的一个注解子集，方便 java 属性类型与 数据记录的字段进行映射。
  
　　Macroview DB 的数据操作层面非常灵活，提供两种的模式的操作：

  + **贫血模型**。其实，就是领域对象（即数据类）只是单纯的 set/get 属性操作，而所有逻辑处理都放到 Repository 类（或 dao 类）当中。 
  
```java  
    public class UserRepository extends SimplePagingAndSortingRepository<User> {  // 定义 Repository 来操纵 User 数据
	
	   ..... // 逻辑处理
	   
    }  
```

  + **充血模型**。就是领域对象（即数据类）本身除了 set/get 属性之外，还包含了对象应该有的业务处理逻辑。（即某种意义来说，数据类与 dao 类合二为一）
  
```java
     public class User extends PagingAndSortingBaseModel{
     
        private String name;
        
        //.... 其他属性
        
        //.... 逻辑处理方法
     }
```       

　　无论是继承自 SimplePagingAndSortingRepository 还是 PagingAndSortingBaseModel，都不影响对数据的操纵。并且这两个基础类本身已经实现了丰富的操作API，可以让开发人员不需要添加和编写额外的代码，即可以对数据进行诸如增、删、查、改的操行。

　　即使遇到一些复杂或没有直接API 实现的操作，也可以使用基础 API 来进行简化或简单实现。
  
　　另外，还要注意，更高一级的类库：`Macroview-App-Base` 将提供对 `MDB` 的进一步支持，提供了`AppBaseModel`（支持分页）、`HasCreateTimeEntity`（支持分页同时定义了 `createTime`字段），所以我们在使用 `MD`时， 同时会引入 `Macroview-app-base`（也是 2.8.0）来获取更丰富的操作支持。

### 0x00 引入 Macroview-DB

　　我们可以在 Maven 中，使用下面的依赖表述来引入类库。(所依赖的 Macroview-Lang、Maroview-Container 均为 2.8.0 版本)

    <dependency>
    	<groupId>com.macroview</groupId>
    	<artifactId>macroview-db</artifactId>
    	<version>2.8.0</version>
    </dependency>

　　另外，由于类库是使用注解来定义java 类属性与数据字段的映射，所以在使用本类库的时候，需要使用类库的方法来扫描所有实体类（Entity Class）。不过，如果使用我们的 Macroview-Container 类库的话，由于 Macroview-Container 类库本身提供类扫描的支持，在扫描类的同时，会自动执行 Macroview-DB 的实体类扫描类进行自动扫描。所以通常会建议将 Macroview-DB、Macroview-Container、Macroview-WebFramework 三者结合使用，这样就能简化了很多的工作。

　　MC、MD、MWF 结合使用的方法，可以参考文章：[如何创建MWF项目](http://192.168.11.148:8080/sdm/blackboard/view/3)
    
　　不过，如果你只想使用 MD 的话，也没多大问题，你只需要在你的代码当中，手工执行实体类的扫描方法即可，内容大致如下：

```java
   ScanDbAnnotations scanEntityClasses = new ScanDbAnnotations();
   scanEntityClasses.doWith( EntityClass );                       // EntityClass 就是实体类的 class
```    
    
### 0x01 使用 Macroview-DB

#### 0x00 创建与配置 JDBC 连接

　　在大多数的应用开发当中，使用数据库连接池已经是基础要求，除非是某些特殊的环境要求。同样，MD 本身就支持和使用连接池，所以要使用 MD 首先要做的事情就是连接池的配置。

　　MD 内部默认使用开源的 druid （阿里巴巴开源） 作为连接池（当然，也可以改用其他的）。并且，还默认放在 classes 根目录中的文件 druid.properties，作为 druid 连接池的配置文件。

　　换句话来说，只要我们编写了一个叫 druid.properties 的连接池配置文件，并放到 classes 目录的话，你就可以免除了在代码中创建连接池的工作--- 是不是很方便？

　　但是，如果我想在代码中手工来创建连接池 --- 对于自动创建心里不爽的话，又如何做呢？ 其实也不复杂，只要实现接口：DataSourceFactory 即可。甚至不用你去执行这个接口，扫描类能够自动扫描识别它，然后帮你去执行构建连接池。

```java
   
   //实现接口：DataSourceFactory 的示例
   public class MyDataSourceFactory implements DataSourceFactory{
   
       /**
        * 为 DataSource 定义一个唯一标识名称 （即连接池的名称）
        *
        */
       @Override
       public String getDataSourceName(){
           return "MyDataSource";
       }
       
       /**
        * 要连接的数据库系统类型
        *
        */
       @Override
       public DataBaseType getDataBaseType(){
           return DataBaseType.MySQL;         // 数据库类型，包括 MSSQL2005, MSSQL2012, Db2, Oracle 等
       }
       
       /**
        * 构建连接池，并返回
        *
        */
       @Override
       public DataSource createDataSource(){
           //...
       }
       
   }
```

　　通常来说，如果没有特殊的要求（例如指定某个连接池，或者个人爱好等），druid 连接池已经满足要求（配置项跟 Apache DBCP 连接池一样）。

　　不过，当项目或系统要连接多个数据源的时候（如连 MySql, MSSQL 等），又如何呢？这个也很简单。。。毕竟这个框架是我们自己的，方便是第一。

　　当需要连接多个数据源的时候，还是跟只有一个数据源一样简单方便，下面说说步骤：

  + **编写连接池配置**：同样，也是编写一个 druid 连接池配置文件，文件名字根据需要来编写，放在 classes 目录下。 例如：
  
   classes\MyMsSQL2012.properties

　　下面给出 MySql 连接池配置的示例，要**注意：**MySql 的连接参数，需要添加 generateSimpleParameterMetadata=true 参数，用来生成查询结构。
  
```properties
  driverClassName=com.mysql.jdbc.Driver
  url=jdbc:mysql://localhost:3306/test?generateSimpleParameterMetadata=true&amp;useUnicode=true&amp;characterEncoding=utf-8
  
  username=root
  password=macroview
  
  #filters=stat
  minIdle=1
  initialSize=1
  maxActive=20
  maxWait=60000
  timeBetweenEvictionRunsMillis=60000
  minEvictableIdleTimeMillis=300000
  validationQuery=SELECT 1
  testWhileIdle=true
  testOnBorrow=false
  testOnReturn=false
  poolPreparedStatements=false
  maxPoolPreparedStatementPerConnectionSize=20
```  
　　当然，如果需要更加高级或更贴近应用的配置，还是要根据当前项目的需要进行配置。  
  
  + **创建所有实体类的父类**：也就是说，创建专用于此数据源的实体类的基类。并进行如下面示例的设置：
  
```java

  /**
   * 没错，只需要为基类增加一个注解 @DataSource ，然后写上个名字，填上连接池文件即可
   *
   */
  @DataSource(name="MSSqlServer", sources="classpath:MyMsSQL2012.properties")
  public class MsSQL2012BaseModel extends PagingAndSortingBaseModel{
  
      //...
  }
  
  /**
   * 实体类继承上面所定义的基类即可
   *
   */
  @Entity
  @Table
  public class User extends MsSQL2012BaseModel{
     
      public User findByName(String name) throws Exception{
         //...
      }
  }
```

　　不复杂吧，很方便吧。注意，这里的示例是使用充血模型。如果是使用贫血模型，方法是一样的。只不过由 model 转为 Repository 而已。

#### 0x01 定义实体类

　　所谓定义实体类，其实就是定义实体类与数据表的映射。在 MD 中我们不自己弄出一套注解出来，而是直接使用 JPA 的注解。目前MD只直接部分的 JPA 注解，并没有安全支持，也不支持JPA规范，而是借用其注解而已。

　　定义 O 与 R 的映射（ORM），分成两个层面：一个是类与表的层面；另一个是类的属性与表的字段层面。

  + __类与表的映射__：类与表层面的映射比较简单，目前MD只用来说明实体类对应那个数据表，暂时不支持复杂的名字空间，角色权限之类的。

      - @Entity ：实体类注解，表示这个类是个实体类。
     
      - @Table ：数据表注解，表示这个类所映射的数据表信息
     
      - @TableReadOnly ： 这个不是 JPA 注解，是我们框架定义的注解，用来表示这个表是一个只读的表（如视图），此时 save, delete 等方法将无效。

下面是一个实体类定义的示例：

```java
/**
 * 定义类 User 为实体类，并且映射到表 "T_User"
 *
 */
@Entity
@Table(name="T_User")
public class User extends PagingAndSortingBaseModel{
   
}

/**
 * 定义类 Department 为实体类，并且映射到表 "Department"。
 *
 * 注意，如果 @Table 不使用 name 这个属性时，默认为类名
 *
 */
@Entity
@Table
public class Department extends PagingAndSortingBaseModel{
 
}   
```     

  + __类属性与数据表字段映射__：将类的属性映射到数据表的字段上。目前，MD只支持下面的 JPA 注解。

    - **@Id :** 用来注解主关键字。不过，如果继承 PagingAndSortingBaseModel 的话，内部已经默认主关键字段为 id，不需要我们再去定义。如果要用其他字段，则要继承 Model 这个类。
     
    ```java    
    @Table
    @Entity
    public class MyEntity extends Model{
    
        private Long code;
    
        /**
         * 主关键字不叫 Id, 叫 code 。
         *
         */
        @Id
        @GeneratedValue(strategy=GenerationType.IDENTITY)
        public Long getCode(){
           return code;
        }
    }
    ```     
    
    - **@Column ：**用来注解属性与字段映射。在默认的情况下，可以不加 @Column。此时使用属性名字与类型与相同名字的字段映射。

    ```java    
    @Table
    @Entity
    public class User extends PagingAndSortingBaseModel{
    
        /**
         *  映射到字段 
         */
        @Column(name="name")
        private String userName;

        /**
         * 不添加 @Column 注解的情况下，默认映射到同名字段，这里会被映射到 password 字段
         */    
        private String password;
        
        /**
         * 字段的特殊要求：这个字段的数据不能新增（插入操作不会写这个字段数据），但是可以更新（在更新操作时会写这个数据）
         *
         * 默认的设置是 insertable=true, updatable=true 即插入与更新时写这个字段，除非特别需要，通常我们都用默认值
         */
        @Column(name="T_Data", insertable=false, updatable=true)
        private Date privateDate;
    
        /**
         *  可以用 columnDefinition 来定义一些特殊的字段类型，其中最有名的就是 MSSQL 的 nvarchar 这种 utf-8 类型。
         *
         */
        @Column(name="T_attachData", columnDefinition="nvarchar(250)")
        private String attData;
    }
    ```     
    
    - **@Enumerated ：**枚举类型专用注解，指示是存放枚举类型的名称（字符类型）还是序号（数值类型）

    ```java    
    @Table
    @Entity
    public class User extends PagingAndSortingBaseModel{

       /**
        *  在枚举类型字段 role 中，我们是用数值类型来存放其值。
        */
       @Enumerated(EnumType.ORDINAL)
       private AccountRole role;
       
       /**
        * 而字段 language 而是存放枚举的名称（字符串类型）
        */
       @Enumerated(EnumType.STRING)
       private LanguageType language;
    }
    ```      
    
    - **@Temporal ：**日期类型的专用注解，表示对应的字段类型是 date 类型、time类型，还是 timestamp 类型（包括 datetime 类型）
       
    ```java    
    @Table
    @Entity
    public class User extends PagingAndSortingBaseModel{

       /**
        *  将日期类型定义为 timestamp ，即包括日期与时间的完整值
        */
       @Temporal(TemporalType.TIMESTAMP)
       private Date lastLogin;
       
    }
    ```            
    - **@Transient：**表示所注解的属性不映射到数据表上，也即不写入到数据表中。通常有一些类属性没有对应字段时，就需要使用这个注解了。
     
    ```java    
    @Table
    @Entity
    public class User extends PagingAndSortingBaseModel{

       /**
        * 这只是一个内部类成员变量，与数据表没关系，所以也要使用 @Transient 来剔除
        */
       @Transient
       private String privateData;

       /**
        * 因为 getLoginTotal 只是一个统计方法，并不是数据表的字段，所以用 @Transient 注解来表示这不是字段
        */
       @Transient
       public String getLoginTotal(){
         //....
       }
       
    }
    ```            

　　有了这几个注解，基本上能够完成大部分的映射工作了。
  

#### 0x10 可以直接使用的 API

　　无论是继承自 Model 实体类，还是 Repository 的仓库类，其基类都已经实现了大部分的数据操作 API。在很多场合，我们只需要直接使用这些API，就能够解决问题。

　　特别是 Model 实体类，我们可以直接在实体类中定义一个静态全局变量，使用起来更加方便。下面是示例：

```java
   /**
    * 定义类 User 为实体类，并且映射到表 "T_User"
    *
    */
   @Entity
   @Table(name="T_User")
   public class User extends PagingAndSortingBaseModel{
   
       //定义一个静态全局类变量
       public final static User dao = new User();
   
   }
   
   //我们可以这样使用（即在其他地方）
   User.dao.findAll();  //调用 findAll 方法获取所有 User 
   
   User.dao.findByName("Jai");  // 查找
```

　　这样使用是不是感觉很好用，很自然？

　　下面列出基类提供给我们使用的 API

  + **public T load(Long id)** ：使用关键字 id 来加载实体类
  
  + **public T findOne(Long id)** ：实现的功能与 load(id) 一样。其实 load() 本身就是调用 findOne 来实现。
  
  + **public List< T > findAll()**：查找所有记录，对于小量记录的表来说，方法很好用。不过，如果对于大量记录的表来说，避免使用本方法。
  
  + **public List< T > findBy(String propertyName, Object value)**：通过属性名和属性值来查找一组实体类
  
```java
   List<User> users = User.dao.findBy("role", 1);  // role 是帐号角色属性，这里表示查找所有管理员帐号
```

  + **public T findUniqueBy(String propertyName, Object value)**：使用属性名和属性值来查找单个实体类，这对于具有唯一值的属性很有用
  
```java
   User user = User.dao.findUniqueBy("userName", "Jai");  // 通常帐号名是唯一的，所以使用这个方法可以查到所需要的实体
```

  + **public List< T > findWithWhere(String whereCondition, Object...values)**：使用自定义条件来查找，要注意条件中使用字段名称

```java
	/**
	 * 使用 ap 的名称或 mac 来查询 设备。。这是一个 or 查询
	 *
	 * @param radioMacAddress
	 * @param apName
	 * @return
	 */
	public List<WlcMobileStation> findMobileStationByAp(String radioMacAddress, String apName) throws Exception{
		String where = "(apMacAddress=?) or (apName = ?)";
		return msRepository.findWithWhere(where, new Object[]{radioMacAddress, apName});
	}
```

  + **public List< T > findWithWhereLimit(int count, String whereCondition, Object...values)**：使用自定义条件来查找，并返回前 count 条记录
  
  + **public Collection< T > findByValues(String propertyName, String[] values)**：使用属性对应一组值来查询，就是 in 操作
  
```java
   Collection<User> users = User.dao.findByValues("userName", new String[]{"Jai", "Tony"}); //查找一组实体
```  

  + **public Collection< T > findAll(Sort sort)**：使用某个字段进行排序之后，返回所有记录

```java
  //对 userName 字段倒序排列，并返回所有记录
  Sort onNameSort = Sort.createInstanceBy(Sort.DESC, "userName");
  Collection<User> users = findAll(onNameSort);
```

  + **public Collection< T > findWithPagination(QueryModel query, Pageable pageable)**：最基础的查找并分页输出的方法
  
　　这是最基础的分页输出方法，除非要进行特别定制，否则不建议使用。而是使用更加简单高级的方法。在后面，我们会介绍各种简化版分页方法。  

  + **protected List< T > query(String sql, Object...objects)**：更加底层方法，可以实现上述查找方法无法又或者难以实现的方法，这是一个保护方法。
  
  + **protected < E > List< E > query(Class< E > entityClass, String sql, Object...objects)**：这个查找方法更加灵活，所返回的结果并不一定是当前实体类。
  
　　这个方法特别适用于 join 操作（SQL），又或者只返回一个数据子类（与本实体类无关的另一个实体类）。

```java

  /**
   * 在这个示例中，我们在实体类 TempWlcOnline 中实现返回 非 TempWlcOnline 实体类的数据
   *
   * 方法可以让我们脱离实体类的限制
   *
   */
  @Entity
  @Table(name="TempWlcOnlines")
  public class TempWlcOnline extends BaseModel{

	  /**
	   * 查询在 MobileStation 表，而不在临时表的记录
  	 *
  	 * @return
  	 */
  	public List<WlcMobileStation> queryOffLineMobiles() throws Exception{
    		String sql = "SELECT m.* FROM %s AS m LEFT JOIN %s AS t ON m.mac = t.mac WHERE isnull(t.id)";
		
	    	return query(WlcMobileStation.class, 
			           		String.format(sql, msRepository.TableName(), this.TableName()), 
				          	new Object[0]);
	   }
  ｝
```

  + **public Collection< T > findBySqlMap(String sqlMapName, Object...objects)**：这是从外部资源中加载 sql 语句的方法

　　如果 SQL 语句非常复杂，可以将这个语句放到外部文件，使得对语句的维护变得较为容易

  + **public void delete(T entity)**：对于 Repository 类型，用来删除一个实体
  
  + **public void delete()**：对于 Model 类型，使用本方法来删除自己对应的记录

  + **public void save(T entity)**：用于 Repository 类型，用来保存实体
  
  + **public void save()**：用于 Model 类型，用来保存实体
  
　　无论是 save() 方法还是 save(T) 方法，所实现的逻辑都是：对于新实体是新增操作（insert）；而已经存在的，则为更新操作（update）。而判断究竟是 insert，还是 update，要靠主关键字 id 是否为null，所以通常要求 id 的类型是类（如 Long, Integer 等而非 long, int）。

  + **public void save(T entity, boolean autoGenKeys)**
  + **public void save(boolean autoGenKeys)**：autoGenKeys=true，表示insert时将生成的 id 值赋给 id；autoGenKeys=false 则不会赋给id。

　　并非所有的主关键字都是由数据库来生成，又或者过旧的 JDBC 驱动并不支持这种操作（但是我们要求所有新设计的表，都应该有一个自增字段作主关键字，除非表是旧或已有的数据表），此时需要用到 autoGenKeys = false 的场景。

  + **public void updateProperty(T entity, String propertyName)**
  + **public void updateProperty(String propertyName)**：支持只更新一个字段的场景，这种情况下，使用本方法比 save() 更有性能优势
  
  + **public void batchUpdate(Iterable<T> entities)**：批量更新
  
  + **public void batchInsert(Iterable<T> entities)**：批量插入
  
  + **public void batchDeletes(Iterable<T> entities)**：批量删除
  
#### 0x11 声明式查询

　　查询是数据操作最常用，也最易出错的内容。在一般情况下，我们都会是用字符串拼接的方式来构建查询条件。不过单个或二、三个查询条件的查询，使用字符串拼接问题不大，但是多于四、五个以上时，使用字符串拼接麻烦、容易出错，并且维护起来也比较困难。

　　有鉴于此，MD 为了降低构建查询条件难度，提高可读性和可维护性，引入了部分查询注解。当然，能够解决 80% 的查询功能，下面在说注解之前，先说说相关的函数与类。

  + **public < T extends BaseModel > List< T > findByQueryModel(QueryAndOrderModel model)**：只查询不分页

  + **public Page< T > queryWithPagination(QueryModel query, PageRequest pageable)**：查询并进行分页

　　在这两个方法当中，所要求的参数都是查询相关接口，包括：

  + **QueryModel** 查询条件定义接口，需要定义要查询的字段（所有字段或某些字段）；定义查询条件。
  
  + **QueryAndOrderModel** 查询与排序定义接口，其实是在 `QueryModel` 的基础上再提供排序内容。

  + **PageRequest** 分页条件接口，包含每页大小，当前页码等

　　这些方法与接口，是实现声明式查询的基础。因为声明式查询在底层中，还是会在内部拼接为SQL语句，然后由这些方法来执行。所以在这些方法之后就有了更进一步的方法：

  + **public < T extends BaseModel > Page< T > queryWithPaginationBy(Object queryBean, PageRequest pageable)**，其中 queryBean 就包含了查询注解的查询类。

　　如何进行声明式查询？就是在要查询的类属性上，使用查询注解来声明查询条件，下面是一个应用示例：

```java
  /**
   *  一个定义了查询注解的，声明式查询 Bean 。  DefaultPageBean 是一个实现了 PageRequest 接口的类，可以身兼两种角色：查询类与分页实现类
   */
  public class AccountRequestBean extends DefaultPageBean{
  
    /**
     *  @NotNamed 表示本字段不参与查询
     */
    @NotNamed
    private Long accountId;
    
    /**
     *  @Like 是  like 查询操作
     */
    @Like
    private String name;
    
    /**
    * 不添加任何查询注解时，默认为 @Equals，即相等查询 
    */
    private String role;
  
    /**
    * 不参与查询
    */
    @NotNamed
    private String password;
  
    //...
  }  
  
  //使用
  AccountRequestBean qb = new AccountRequestBean();
  qb.setName("J");
  Page<User> users = User.dao.queryWithPaginationBy(qb, qb);
```

　　从上面的例子我们可以看到，使用声明式查询非常简单和直观，不需要去维护拼接查询条件，只需要标识要查询的字段即可，是不是很方便？要注解，这些查询都是使用“and”的联合查询，目前还不提供“or”的查询，但是已经满足大部分的场景。

　　下面说说目前系统所支持的查询操作与对应的注解

  + **@Equals ：**相等查询，相当于查询条件中的“=”（等号）。这个注解是默认缺省操作，所以可以不用写出来。
  
```java
  public class AccountRequestBean extends DefaultPageBean{
  
    @Equals
    private String role;

    //不添加任何注解情况下，默认为 @Equals
    private String language;

    //...
  }
  
  AccountRequestBean rb = new AccountRequestBean();
  rb.setRole("Admin");
  rb.setLanguage("zh_CN");
  
  // 相当于查询条件语句： role = 'Admin' and language = 'zh_CN'
```

  + **@Like：**字符串的相似查询，相当于查询条件中的“like”（相似）。注解支持三种相似查询：前缀、包含和后缀。
  
```java

   /**
    * 前缀匹配，其实相当于   userName like 'value%'，意思：必须前面相同，才相似...
    */
   @Like(type=LikeType.StartsWith)
   private String userName;
   
   /**
    * 包含，这是默认的参数。相当于  title like '%value%'，意思：即只要有就相似...
    */
   @Like(type=LikeType.Contains)
   private String title;
   
   /**
    * 后缀匹配，相当于 fileExt like '%value'，意思：必须后面部分相同，才相似...
    */
   @Like(type=LikeType.EndsWith)
   private String fileExt;
  
   /**
    * 不带任何参数的情况下，默认为 @Like(type=LikeType.Contains)
    */ 
   @Like
   private String content;
```  
   
  + **@NotEquals：**不等查询。这个注解刚好与 @Equals 相反，相当于查询条件中的“<>”（不等）。

  + **@Min：**大于或等于。相当于“>=”。
  
```java

   @Min
   private int age;
```

  + **@Max：**小于或等于。相当于“<=”。
  
  + **@NotNamed**不参与查询。当不需要或不希望某个字段参与查询时，使用本注解。
  
```java

   /**
    *  createTime 字段只是数据存放字段，不用于查询。所以要添加 @NotNamed 字段，此时本字段不会出现在查询语句当中
    */
   @NotNamed
   private Date createTime;
```

  + **@Between：**两者之间，相当于“between...and”操作。要注意，使用本注解的字段必须要实现 `com.macroview.commons.base.Range< T >` 接口.

　　目前，在 macroview-lang 类库中，我们已经提供了三个常用的 Range 接口实现：

  + DateTimeRange: 这是用于日期的范围表示，可以用于一个日期范围的查询。
  
  + IntegerRange：这是整数的范围表示，可以用于一个整数范围的查询。
  
  + LongRange：这是长整数的范围表示，可以用于一个长整数范围的查询。
  
　　当然，Range 接口本身也很简单，自己自定义其实现也是非常简单容易。下面以时间范围为例，说明注解的使用。

```java

  //包含历史数据查询的查询类
  public class MsLogHistoryQueryBean extends MobileStationQueryBean{
  
    /**
    * 使用时间范围查询
    */
    @Between
    private DateTimeRange createTime;
  
    /**
    * 不参加查询，对应  Web 的开始时间，是用来 组成  createTime 的内容
    */
    @NotNamed
    private Date beginTime;
    
    /**
    * 不参加查询，对应 web 的开始时间，是用来组成 createTime 的内容
    */
    @NotNamed
    private Date endTime;
    
   /**
    * 时间的查询范围
    * @return the createTime
    */
    public DateTimeRange getCreateTime() {
      if(beginTime == null || endTime == null)
        return null;
      
      createTime = new DateTimeRange(beginTime, endTime);
      
      return this.createTime;
    }
  
    /**
    * @return the beginTime
    */
    public Date getBeginTime() {
      return beginTime;
    }
  
    /**
    * @param beginTime the beginTime to set
    */
    public void setBeginTime(Date beginTime) {
      this.beginTime = beginTime;
    }
  
    /**
    * @return the endTime
    */
    public Date getEndTime() {
      return endTime;
    }
  
    /**
    * @param endTime the endTime to set
    */
    public void setEndTime(Date endTime) {
      this.endTime = endTime;
    }
  }  
```

　　看起来有一些繁琐，不过如果能够配合 UI 组件的话（即组件本身就可以赋给 range 的话），应该可以简化其内容的。 

  + **@OrderBy：**排序字段定义。使用本注解可以注解要排序的字段。本字段相对其他字段独立，可以与其他注解一起使用。有两个值：Direction.ASC 和 Direction.DESC（默认）。
  
```java

  /**
   *  定义 id 为排序字段，相当于  @OrderBy(Direction.DESC)，因为 Direction.DESC 是默认内容
   */
  @OrderBy
  private Long id;
  
  /**
   * 按字典顺序排
   */
  @OrderBy(Direction.ASC)
  private String status;

  /**
   * 可以同其他的注解一起使用
   */
  @OrderBy(Direction.ASC)
  @Like
  private String title;
```

  + **@CustomConditions：**自定义查询条件。这个使用就比较灵活，可以表述一些特殊的查询。
  
　　@CustomConditions 包含了两个参数：value 和 ignoreField。value 就是查询表达式内容，而 ignoreField 表示所注解的属性的值可以参与也可以不参与，ignoreField=true 表示所注解的字段将不参与到查询式子内，ignoreField=false 表示所注解的字段将参与查询，默认为 ignoreField=false。

```java

  /**
   * 本查询表达式的意思： updateDate 与 字段 createTime 日期中的天相差为0(即同一天)。其中表达式中的“?”，就是所注解字段的值
   */
  @CustomConditions("DATEDIFF('DAY', createTime, ?)=0")
  @Temporal(TemporalType.DATE)
  private Date updateDate;
```

　　从示例可以看出来，我们可以使用 @CustomConditions 来定制一些带函数（即数据库内置函数）的特定表达式，这样使得构建查询更加灵活与复杂。   

　　另外，如果我们的项目包含了 macroview-app-base 的话，实体类可以继承 AppBaseModel（或 Repository 继承 AppRepository< T >），还可以使用简化版的查询方法：

  + **public DefaultPageBean queryWithPagination(DefaultPageBean pageBean)**，DefaultPageBean 类包含了分页内容，我们继承 DefaultPageBean 之后再添加上面的查询注解，用起来就更加简单。
  
```java

  //查询 Bean 
  public class MobileStationQueryBean extends DefaultPageBean {
  
    /**
    * 手机号码的查询
    */
    @Like
    private String mac;
  
    @Like
    private String ip;
    
    @Like
    private String ssid;
  
    @Like
    private String apName;
    
      /**
      * 管理状态
      */
    @Enumerated(EnumType.ORDINAL)
      private MSPolicyManagerState managerState;
    
    @NotNamed
    private Boolean online;
  
    // set/get ...
  }    

  //在 Action 使用

  public class MobileStationAction {
   
   ...
    
      /** 
       *   一个语句就实现的查询条件拼接与分页功能，再与 UI 的分页组件相结合，很快就实现了查询与分页功能。
       */
    	@Get("/list")
	    public ModelAndView list(MobileStationQueryBean queryBean){

		     logger.info("[Get /clients/list]==> 查询条件:" + queryBean);
		
		     ModelAndView mv = new ModelAndView("MobileStation/list");
		
         //一个方法就可以实现查询与分页
		     mv.addObject("clients", MobileStation.dao.queryWithPagination(queryBean));
		
		     return mv;
	    }
      
   ...
  }   
```  
  
  + **public DefaultPageBean queryWithPagination(DefaultPageBean pageBean, Class<?> subClass)** 方法跟上面的一样，唯一不同的就是查询是 subClass 对象集。这样查询的结果更加灵活。  
  
　　有了查询注解，是不是省事多了？

### 0x11 Macroview-DB 其他功能

#### 0x00 关闭边接

　　无论用与不同连接池，我们都面临着数据库连接的关闭问题。MD 使用下面的方法来关闭数据库连接。

```java
  DataConnectionManager.returnConnection();
     
  //如果是多个数据源，要关闭某个数据源的连接，则：
     
  DataConnectionManager.returnConnection(dataSourceName);
```

　　通常情况下，我们都需要手工、显式地关闭数据库连接，如下面例子所示：

```java

	public WifiDeviceLog findLastLogs(String deviceMac) throws Exception{
    try{
      List<WifiDeviceLog> logs = findWithWhere("deviceMac = ? ORDER BY Id desc LIMIT 1", deviceMac);
      if(logs != null){
        return logs.get(0);
      }
    }finally{
        //必须关闭连接
        DataConnectionManager.returnConnection();  
    }
		return null;
	}
   
```

　　手工、显式地关闭数据库连接，存在下面几个问题：

  + 容易忘记。
  
  + 增加其他框架与 MD 的耦合度。
  
  + 不容易共享连接，虽然有连接池。
  
　　那么，能否将关闭数据连接的操作放到基础 API 中进行呢？事实上是可以的，只是在一个 web 请求周期之中，连接不容易共享，同时也让一些例如延时加载的功能失效（虽然 MD 还没有这种功能）。所以虽然将关闭连接放到基础API中，也是一个可行和常用的方案，不过依然还是希望有更好的方法。

　　在 MD 中，我们引入一个 web filter 类（也就是 Servlet Filter 过滤器）：DbCloseConnectionFilter，在一个 web 请求周期完成之后，执行 `DataConnectionManager.returnConnection()` 语句，自动将数据库连接关闭。

　　由于我们的 servlet Filter 使用了 Servlet 3.x 的注解技术，所以也就不需要在 web.xml 配置，只要在 web 项目中引入 MD 的包，启动后 Servlet 容器就会自动启动这个 Filter。

　　**换句话来说，只要是在 servlet 3.x 的环境下，不需要我们进行手工关闭数据库连接。**

　　当然，如果不是 web 项目的话，那也就只能手工关闭连接了。特别是在多线程的环境下（web 应用也会有多线程、多任务），Servlet Filter 是管不了的。在这种情况下，我们就必须要手工关闭连接。

```java
 
   /**
    * 在线程任务中，必须要手工关闭连接，这是要注意的地方
    */
   public class MyTask implements Runnable{
    
         public void run(){
         
             try{
               
               //.... 线程中代码
             }finally{
                DataConnectionManager.returnConnection();
             }    
         }    
   }
```

　　当然，这并不是解决不了的问题，在类库 macroview-app-base （0.11.0 或以上）中，我们引入了一组多线程、多任务工具，可以帮助我们来关闭数据库连接，例如：

```java

   // 创建和运行线程：使用 TaskUtils.startThread() 方法
   Thread thread = TaskUtils.startThread( new MyTask() );
   
   // 创建任务： 任务继承 SimpleAppWorker 
   public class MyWorker extends SimpleAppWorker{
     
   }
   
   // 运行任务： AppWorkerManager
   AppWorkerManager.submitWorker( new MyWorker() ); 
```

　　这些具体的工具的使用，可以参看相关的文档。如果无法使用这些工具，又或者不想用的话，那也只能手工来关闭连接了。


#### 0x01 事务方法

　　Macroview-DB 也提供基础的事务处理。事务处理由类 TransactionFactory 来管理，并且是管理当前连接的事务。TransactionFactory 提供了事务所需要的三个方法：开始、提交和回滚。

  + **public static void beginTrans()**：表示开始一个事务。如果当前已经存在事务，则使用当前事务（对于嵌套事务，计数加1）
  
  + **public static void commit()**：表示提交事务。如果存在嵌套事务，则当计数为1时才会提交。（即最后一个或最外层才提交）
  
  + **public static void rollback()**：表示回滚事务。如果存在嵌套事务，则当计数为1时才会回滚。（即最后一个或最外层才正式回滚）

　　下面使用一个示例来说明使用：

```java

	/**
	 * 添加一个 MacFiltering User。
   *
   *   因为需要向数据库添加记录，并同时要向 WLC 添加一个帐号，所以使用一个事务来，当向 WLC 添加帐号时失败，要回滚数据库中的记录
	 * 
	 * @param user
	 * @return
	 */
	private boolean insertMacFilteringUser(WlcAuthenUser user) {
    
		try{
      
      //开始一个事务
			TransactionFactory.beginTrans();
			
			try{
				user.save();
				
				MacFilter client = new MacFilter();
				client.setMacAddress(user.getUserName());
				client.setDescription(user.getDescription());
				client.setWlanId(user.getWlanId());
				client.setInterfaceName(user.getInterfaceName());
				
				mfService.addMacFilter(client);
				
        //提交事务
				TransactionFactory.commit();
				
				return true;
				
			}catch(Exception e){
				try{
          //回滚事务
					TransactionFactory.rollback();
					
					logger.error("[Wlc AAA Manager]==> 添加 Mac Filtering 帐号失败，添加的帐号：" + user + "，异常：", e);
				}catch(Exception re){
					logger.error("[Wlc AAA Manager]==> 添加 Mac Filtering 失败后，回滚记录失败。添加的帐号：" + user + ", 异常：", e);
				}
			}
			
		}catch(Exception ex){
			logger.error("[Wlc AAA Manager]==> 添加 Mac Filtering 帐号时，启动事务失败，添加的帐号：" + user + "，异常：", ex);
		}
		return false;
	}
```

　　用起来是有点麻烦，不过并不是太复杂。如果引入完整的IOC的话，可以简化为声明式事务，不过这已经不是 MD 的事。另外还可以有一个简化一点的方案，就是利用 JDK8 的 Lambda 表达式，这已经是 For JDK8 版本的内容。

#### 0x10 引用外部 SQL 文件

　　这是一个不常用的功能，在 MD 中我们可以将 SQL 语句移到一个外部文件当中（JSON 格式文件），这样带来的好处如下：

  + 对于复杂和比较长的 SQL 语句，放在 Java 文件中可读性差，当然带来的维护性就不好。如果独立放到一个文件时，相对可读性就会好很多。例如一些报表、统计的SQL，可以独立出来。
  
  + 对于需要调整和变化的 SQL 语句，每次改动语句都需要编译和重新部署，如果放到外部文件当中，可以独立维护进而不需要重启系统就可以直接修改 SQL 语句。
  
  + 希望 sql 语句更加灵活，有更高的可定制性。
  
　　下面看看如何使用这一项功能：

  + 按照下面 JSON 格式，将 SQL 语句写到一个文本文件中，扩展名通常为 .json （也可以 .sql 等等）

```json
  /**
   * 每一个文件有一个唯一 id，maps 就是 sql 语句集，每条 sql 语句由 “名称” 和 内容组成
   *
   * 名称同样唯一，我们要在 java 里面通过名称来加载 sql 语句，所以名称最好能反映 sql 语句的意思。
   *
   * sql 语句内，可以使用 ${} 这样的占位符，让 java 程序里灵活生成 sql 语句。其中 ${Table} 是内置的占位符，用来表示实体类所对应的数据表名称 
   */
  {
    id: "MobileStationLog",
    
    maps:{
      queryMsLogByMac: "SELECT DISTINCT mac FROM ${Table} WHERE (mac like ?) Limit ? ",
      queryLogProperty: "Select Distinct ${field} From ${Table} Where (${field} like ?) Limit ?"
    }
  }
```  

  + 定义好 json 文件之后，需要在实体类（Entity 类）或仓库类（Repository 类）中使用注解 @SqlMapResource 引入  

```java
  /**
   *  使用注解 @SqlMapResource 引入 sql 资源文件。注解有两个参数：
   *
   *  resource = "package:mobile_station.js" ：这个参数用来引入文件，其中前缀 package 表示文件同实体类（如 WlcMobileStation）放在同一个目录
   *
   *  dynamic = true|false : 如果取 true 值，表示修改之后不需要重启系统即可生效。false 表示修改需要重启。默认为 false
   *
   *    如果SQL 语句不可能会变，并且要求一定的性能，就使用 dynamic=false，如果 sql 语句可能会变，并且可以容忍一些性能损失，使用 dynamic=true
   *
   */
  @Entity
  @Table(name="MobileStation")
  @SqlMapResource(resource="package:mobile_station.js")
  public class WlcMobileStation extends HasCreateTimeEntity{
  
    /**
    * Mobile Station IP
    */
    private String ip;
  
    ...
    
  }  
```   

  + 有了上面两步之后，我们就可以通过 queryForSqlMapTo、queryBySqlMapWithParams、findBySqlMapWithParams 三个方法来使用上面SQL语句了
  
     - **protected List< T > queryForSqlMapTo(Class< T > toEntityClass, String sqlMapName, Object...objects)**：比较底层的方法，执行一条没有占位符的语句，并返回 entityClass 对象列表
     
     - **protected List< T > queryBySqlMapWithParams(Class<?> entityClass, String sqlMapName, Map<String, String> params, Object...objects)**：执行一条有占位符的语句
     
     - **protected List< T > findBySqlMapWithParams(String sqlMapName, Map<String, String> params, Object[] objects)**：使用当前实体类作为 entityClass

```java

 @Entity
  @Table(name="MobileStation")
  @SqlMapResource(resource="package:mobile_station.js")
  public class WlcMobileStation extends HasCreateTimeEntity{

     //...
     /**
      * "queryMsLogByMac" 就是 sql 的名称，相似查找 mac，如果有重复的话就去掉重复，并只取前 count 条记录
      */
     public List<WlcMobileStation> queryMsLogByMac(String mac, int count) throws Exception{
      
         //因为没有占位符，所以第二个参数为 null 
         return findBySqlMapWithParams("queryMsLogByMac", null, new Object[]{mac, count});  
     }  
     
     /**
      * 这是带占位符的 sql 执行方法。。从 sql 语句可以看出： queryLogProperty("mac", value, count) 就是上面 queryMsLogByMac(value, count) 同样的效果
      *
      * 但是本方法就灵活得多，可以是  queryLogProperty("ip", value, count) 查找 ip ， queryLogProperty("apMac", value, count) 查找 apmac 等等
      */
     public List<WlcMobileStation> queryLogProperty(String fieldName, String value, int count) throws Exception{
         Map<String, String> params = new HashMap<>();
         params.put("field", fieldName);  //占位符 ${field} 的值
       
         return  findBySqlMapWithParams("queryLogProperty", params, new Object[]{value, count});
     }
  
     //...
  }    
```

　　示例二：

```json

　 /**
    * sql 语句很长，虽然语句本身并不复杂，但是很长。如果是在 java 里面去拼接，可读性确定不高，但是放在这里的话，就好看很多了（json 本身没有换行概念 !-_-!）
    */
 　{
    id: "acl",
    
    maps:{
      queryAclRulesById: "Select r.id, r.ruleIndex, r.action, r.direction, concat(r.sourceIpAddress, '/', r.sourceIpNetmask) As sourceIp, concat(r.destinationIpAddress, '/', r.destination) As destIp, r.protocol, r.startSourcePort, r.endSourcePort, r.startDestinationPort, r.endDestinationPort, r.dscp, r.direction From wlcaclrecord r Join wlcacltable a On r.aclName=a.name Where a.id=? Order By r.ruleIndex"
    }
  }
```

　　提高可读性，那么相应可维护性就会高。出错又或者修改时，就比较容易找到或修改。

  