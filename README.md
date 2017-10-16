# Drafter

## Drafter是什么

- Drafter是一个命令行工具，用于分析iOS工程的代码，支持Objective-C和Swift。
- 自动解析代码并生成方法调用关系图。
- 自动解析代码并生成类继承关系图。

## 安装

执行以下指令，会自动安装到 /usr/local/bin 目录中：

```shell
curl "https://raw.githubusercontent.com/L-Zephyr/Drafter/master/install.sh" | /bin/sh
```
或者直接下载并编译源码

## 基本使用

- 首先确保电脑中安装了[Graphviz](http://www.graphviz.org/Download_macos.php)，可以直接通过Homebrew来安装:`brew install graphviz`

- 生成方法调用关系图，以AFNetworking为例，如：

  ```shell
  drafter -f ./AFHTTPSessionManager.m
  ```

  在当前位置会自动生成一张以"文件名+.png"格式来命名的图片：

  ![1](./.res/1.png)

- 生成类继承关系图：

  ```shell
  drafter -f ./AFNetworking -m inherit
  ```

  在当前位置的文件夹中会生成一张名为"Inheritance.png"的图片：

  ![3](./.res/3.png)

## 参数

- **-f、—file \<arg>** 
  必要参数，指定一个文件或文件夹，多个参数之间用逗号分隔，切勿出现空格。

- **-m、—mode \<arg>**
  可选参数，指定解析模式，参数值可以为invoke、inherit、both。invoke表示只解析方法调用关系、inherit表示只解析类继承关系、both表示同时执行两种解析模式。默认为invoke。

- **-s、—search \<arg>**
  可选参数，指定关键字，多个关键字之间用逗号分隔，关键字忽略大小写。根据关键字过滤解析结果，只保留包含指定关键字的节点分支，如:

  ```shell
  drafter -f ./XXViewController.swift -s viewdidload
  ```

  生成的结果中只包含"viewDidLoad"这个方法下的调用信息：

  ![4](./.res/4.png)

- **-self、—self-method-only**
  可选参数，仅在解析调用关系图时起效，生成结果仅保留用户自定义的方法。
  默认情况下解析调用关系时会将所有的方法调用都解析出来，文件较大时结果会比较杂乱，开启该选项仅保留本文件中定义的方法，让结果更加清晰：

  ```shell
  drafter -f ./AFHTTPSessionManager.m -self
  ```

  可以看到，与上面的第一个例子对比，去掉了调用外部方法的连线，整个代码执行的逻辑更加清晰：

  ![2](./.res/2.png)

## 实现原理

实现细节请看[http://www.jianshu.com/p/9a1a32ec0af6](http://www.jianshu.com/p/9a1a32ec0af6)