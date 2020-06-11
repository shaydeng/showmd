
## 说明 ##

 + 本文档用来描述 `nodejs` 开发应用时，开发环境的配置与开发指南。

 + 文档的内容不是固定不变，会不定期添加内容

## 内容 ##

### 本地组件仓库 ###

　　公司发布的组件，显示是不能发布上 `npmjs` 的，因此需要有公司自己的本地组件服务器。

 + 本地源：**http://172.22.251.147/nexus/content/groups/macroview-npms/**

 + 组件发布服务：**http://172.22.251.147/nexus/content/repositories/npm-internal/**

### 配置本地源 ###

　　可以使用我们公司源来替换 `npmjs` （能得到公司自己的组件库组件）

```shell
 # 修改为我们的本地服务器

 npm config set registry http://172.22.251.147/nexus/content/groups/macroview-npms/ 
```

### 将组件发布到本地服务器 ###

　　当我们编写好组件之后，需要发布到公司的服务器上，下面是配置方法：

 + 配置用户与密码。上传需要用户与密码

    - 配置文件为 `.npmrc`，如果是 windows 环境，此文件在 `c:\Users\<登录帐号>` 下。如果没有就创建一个，文件添加下面的认证信息：

        ```ini
        always-auth=true
        _auth=ZGVwbG95Om1hY3Jvdmlldw==
        ```

    - 在组件的 `package.json` 中添加下面的配置

        ```json
        "publishConfig": {
            "registry": "http://172.22.251.147/nexus/content/repositories/npm-internal/"
        }
        ```  
    - 发布命令

        ```shell
         # 发布命令
         npm publish
        ``` 
        ```shell
         # 如果 package.json 没有添加 publishConfig 的内容，可以直接用下面命令发布

         npm publish --registry http://172.22.251.147/nexus/content/repositories/npm-internal/
        ``` 

