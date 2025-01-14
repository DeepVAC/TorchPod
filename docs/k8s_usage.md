# 在K8s集群中使用TorchPod
在K8s集群上部署TorchPod，一方面可以获得更灵活和多元的功能，另外一方面也可以更好的对数据进行权限控制。  

## 1. 部署
使用kubectl命令进行部署，部署后可以在vnc客户端、rdp客户端、浏览器中访问图形界面。这种方式适合团队的协作和管理。  
```bash
#针对自身的集群环境修改yaml后
kubectl apply -f k8s/torchpod.yaml
kubectl apply -f k8s/airlock.yaml
kubectl apply -f k8s/network.yaml
```

## 2. 网络策略
当TorchPod作为组织内部使用的开发环境时，默认配有较为严格的防火墙策略。在TorchPod上，用户**只能连接MLab代码服务**。除此之外，用户无法访问（也不应该访问）**其它任何服务器**（首次发现某个漏洞的人，发100元红包）。

然而，用户在TorchPod上仍然会有一些合理的（或者半合理的）联网需求，我们总结如下：
- 上传/下载一些数据集到TorchPod上（合理需求）；
- TorchPod上使用包管理工具（pip、apt等）安装软件包（半合理需求）；
- 下载TorchPod上训练结果的输出，分发给客户或其它测试人员（半合理需求）。

为了实现这些合理或者半合理需求，我们提供了**Airlock Pod**（ai5.gemfield.org:27031，该地址取决于你的实际部署）。Airlock Pod和TorchPod共享一个docker镜像(gemfield/torchpod:$version)，且共享/opt/public/airlock目录。区别在于3点：
- Airlock Pod可以访问外部网络；
- Airlock Pod对/opt/public/airlock 目录有写权限；
- Airlock Pod可以通过sftp挂载到本地（比如你的Dolphin）；
- Airlock Pod没有隐私可言。

#### 2.1 上传或者下载一些数据集到TorchPod上
使用Airlock Pod。一旦数据来到Airlock Pod的/opt/public/airlock目录下，用户可以从自己的TorchPod中拷贝到自己的TorchPod本地。
那么数据如何来到Airlock Pod的/opt/public/airlock目录下呢？有多种方法：
- 在Airlock Pod上使用ftp、wget、scp、git等工具，从外部环境下载到此目录；
- 使用sftp://ai5.gemfield.org:10022 （该地址取决于你的实际部署）上传（该服务支持sftp挂载到本地，详情请咨询管理员）。

#### 2.2 TorchPod上使用包管理工具（pip、apt等）安装软件包
软件包按照被使用的普及程度分为两类：基础型软件包、特定软件包。  
- 基础性软件包就是几乎大部分炼丹人员都会用到的，比如numpy、cmake、cv2等；
- 特定软件包就是几乎只有自己的特定项目会使用到，比如fonttools。

基础软件包和特定软件包都提供了临时安装方法（所谓临时安装，就是在TorchPod重启后会丢失）：
- pip包临时安装：
```bash
# 在airlock上
gemfield@airlock:/opt/public/airlock/pip$ pip download <pip-package>

# 切换到torchpod上
username@torchpod:/opt/public/airlock/pip$ pip install *
```
- apt包临时安装：
```bash
# 在airlock上（这种方式下载deb包到当前目录）
gemfield@airlock:/opt/public/airlock/apt$ apt-get download <apt-package>
# 或者（这种方式下载该包及所有的依赖包到/var/cache/apt/archives）
gemfield@airlock:/opt/public/airlock/apt$ apt-get install --download-only <apt-package>

# 切换到torchpod上
username@torchpod:/opt/public/airlock/apt$ sudo dpkg -i <apt-package>
```

此外，基础软件包应该固化到TorchPod的image中。用户按照如下的方法提交固化申请：
- 将安装步骤封装为bash脚本，在Airlock Pod上测试成功（一定要测试成功！！！）；
- 然后该脚本连同安装需求描述提交到https://github.com/DeepVAC/TorchPod 的issues里，通知管理员。

#### 2.3 下载TorchPod上训练结果的输出，分发给客户或其它测试人员
这个是罕见需求，目前只能：
- 联系管理员。

## 3. 在TorchPod上维护github项目
通常情况下，如果想要参与github项目的开发维护，则直接在自己的私人电脑或者办公电脑上完成即可。但有时候，这些项目的开发维护需要借助TorchPod上的资源（比如CUDA设备、数据集、已训练模型等），但由于TorchPod的网络策略，我们并没有办法直接在TorchPod上访问github这样的外网。那怎么办呢？借助MLab代码服务。
#### 3.1 申请在TorchPod上维护某github项目
只有符合产品研发需要的github项目才会被批准。批准的标志就是该github项目会出现在MLab代码服务上。下文我们就以DeepVAC项目为例(https://github.com/DeepVAC/deepvac)。  
TorchPod用户向管理员发出在TorchPod上维护DeepVAC的申请，管理员批准，DeepVAC项目出现在MLab代码服务上：http://ai1.gemfield.org/deepvac/deepvac

#### 3.2 在办公电脑上配置git
- 在github上fork DeepVAC仓库；
- 克隆你的fork：git clone https://github.com/<your_name>/deepvac
- 在仓库中添加remote（注意，由于前述的clone仓库，git已经默认帮你配好了origin这个默认的remote）：
```bash
#添加mlab remote
git remote add mlab http://ai1.gemfield.org/deepvac/deepvac

#添加upstream
git remote add upstream https://github.com/DeepVAC/deepvac
```
- 验证remote添加成功
```bash
gemfield@ThinkPad-X1C:/github/deepvac$ git remote -v
mlab    http://ai1.gemfield.org/deepvac/deepvac (fetch)
mlab    http://ai1.gemfield.org/deepvac/deepvac (push) 
origin  https://github.com/<your_name>/deepvac (fetch)
origin  https://github.com/<your_name>/deepvac (push)
upstream https://github.com/DeepVAC/deepvac (fetch)
upstream https://github.com/DeepVAC/deepvac (push)
```
#### 3.3 在办公电脑上新建轻量级工作分支
假设你现在需要往deepvac提交feature1。则需要在办公电脑上（想想为什么？）按照如下的步骤：
```bash
#同步上游
git fetch upstream
git rebase upstream/master
#新建工作分支
git checkout -b feature_1
#同步到MLab
git push mlab feature_1
```
注意：完成上述步骤后，办公电脑上该仓库就停留在feature_1分支上。

#### 3.4 在TorchPod上开发、测试、提交
以下步骤在TorchPod上：
```bash
#克隆代码
git clone http://ai1.gemfield.org/deepvac/deepvac

#切换（注意不是新建）
git checkout feature_1

#开发、测试
......
git add
git commit -m "xxx"

#将feature_1同步到mlab上
git push feature_1
```

#### 3.5 在办公电脑上同步feature_1分支
以下步骤在办公电脑上，且在之前停留的feature_1分支上：
```bash
#同步feature_1分支
git fetch mlab
git rebase mlab/feature_1

#同步到自己fork的deepvac上
git push feature_1
```

#### 3.6 在github上创建PR
在github网页上，切换到自己fork的deepvac项目上，创建PR。

**注意：自始至终，办公电脑上没有发生任何的开发。这不是必须的，但不这么做会增加git流程的复杂度。**
