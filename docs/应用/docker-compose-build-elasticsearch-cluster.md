
## 1. 准备工作 ##

### 1.1 docker 环境准备 ###

 + 安装 docker
 + 安装 docker-compose
 + 如果要关闭 firewalld 要注意关闭后重启 docker 服务

### 1.2 操作系统准备 ###

　　需要对宿主操作系统进行配置修改，下面以 `CentOS 8` 为例：

 + 修改系统文件设置

```shell
 vi /etc/security/limits.conf
```
添加以下内容：
```shell
 * soft nofile 65536
 * hard nofile 65536
```

 + 修改虚拟内存配置

```shell
 vi /etc/sysctl.conf
```
添加内容：
```shell
 vm.max_map_count=655360
```

 + 检查 net.ipv4.ip_forwad 即 ip 转发有没有打开

```shell
 sysctl net.ipv4.ip_forward  # net.ipv4.ip_forward=1 表示已经打开
 # 设置 net.ipv4.ip_forward
 vi /etc/sysctl.conf  # 新增 net.ipv4.ip_forward=1
 sysctl -p /etc/sysctl.conf
 systemctl restart network
```

## 2. 编写 docker-compose.yml ##

编写集群的 `docker-compose.yml`

```yml
version: '2.2'
services:
  es01:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.5.1
    container_name: es01
    environment:
      - node.name=es01
      - cluster.name=es-docker-cluster
      - discovery.seed_hosts=es02,es03
      - cluster.initial_master_nodes=es01,es02,es03
      - bootstrap.memory_lock=true
      - "ES_JAVA_OPTS=-Xms1g -Xmx1g"
    ulimits:
      memlock:
        soft: -1
        hard: -1
    volumes:
      - data01:/usr/share/elasticsearch/data
    ports:
      - 9200:9200
      - 9300:9300
    mem_limit: 2g
    networks:
      - elastic
  es02:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.5.1
    container_name: es02
    environment:
      - node.name=es02
      - cluster.name=es-docker-cluster
      - discovery.seed_hosts=es01,es03
      - cluster.initial_master_nodes=es01,es02,es03
      - bootstrap.memory_lock=true
      - "ES_JAVA_OPTS=-Xms1g -Xmx1g"
    ulimits:
      memlock:
        soft: -1
        hard: -1
    volumes:
      - data02:/usr/share/elasticsearch/data
    mem_limit: 2g
    networks:
      - elastic
  es03:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.5.1
    container_name: es03
    environment:
      - node.name=es03
      - cluster.name=es-docker-cluster
      - discovery.seed_hosts=es01,es02
      - cluster.initial_master_nodes=es01,es02,es03
      - bootstrap.memory_lock=true
      - "ES_JAVA_OPTS=-Xms1g -Xmx1g"
    ulimits:
      memlock:
        soft: -1
        hard: -1
    volumes:
      - data03:/usr/share/elasticsearch/data
    mem_limit: 2g
    networks:
      - elastic

volumes:
  data01:
    driver: local
  data02:
    driver: local
  data03:
    driver: local

networks:
  elastic:
    driver: bridge
```

## 3. 创建与启动集群 ##

```shell
 docker-compose up -d
```

