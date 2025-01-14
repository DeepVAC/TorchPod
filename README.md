# TorchPod
迄今为止最先进的容器化开发环境，以Docker image形式（遵循OCI规范的image）封装，以GNU/Linux KDE图形系统呈现。

## TorchPod构成
TorchPod对外提供两个层级的容器：
- gemfield/torchpod-kde，这是基础的TorchPod镜像，可以启动GNU/Linux(KDE6)图形化系统，并提供多种登陆方式。
- gemfield/torchpod，这是基于gemfield/torchpod-kde 之上安装了pytorch开发环境。

对于gemfield/torchpod系列镜像，可以单独使用docker进行部署，也可以使用k8s进行部署。

## TorchPod支持的宿主机类型
- X86-64 + Linux
- X86-64 + CUDA + Linux
- X86-64 + Windows10（及以上）（备注：需要安装WSL2，参考：[Windows10上使用Docker运行Linux容器](https://zhuanlan.zhihu.com/p/405329231) )
- X86-64 + CUDA + Windows10（备注：在WSL2的基础上还需要[Enable NVIDIA CUDA in WSL 2](https://docs.microsoft.com/en-us/windows/ai/directml/gpu-cuda-in-wsl) ）

## TorchPod的主要组件及版本

|torchpod:kde6      |TorchPod 1.0          |TorchPod 1.0 pro          |
|-------------------|----------------------|--------------------------|
|镜像               |gemfield/torchpod:1.0 |gemfield/torchpod:1.0-pro |
|OS                 |Ubuntu 24.04          |Ubuntu 24.04              |
|KDE Plasma         |6.2.5                 |6.2.5                     |
|KDE Framework      |6.10.0                |6.10.0                    |
|PyTorch            |                 |                     |
|PyTorch CUDA运行时 |                  |                      |
|PyTorch CUDNN运行时|                 |                     |
|torchvision        |              |                   |
|torchaudio         |                |                 |
|torchtext          |               |                  |
|Conda              |               |                    |
|Python             |                |                     |
|libtorch静态库     |无                    |                     |
|deepvac项目        |无                    |                  |
|libdeepvac项目     |无                    |                 |

除了这些核心软件，TorchPod还有如下鲜明特色：
- 无缝使用DeepVAC规范；
- 无缝构建和测试libdeepvac；
- 包含有kdiff3、kompare、kdenlive、Dolphin、Kate、Gwenview、Konsole、vscode等诸多工具。

另外，标准版和pro版内容完全一致，除了pro版本增加了如下内容：
- tensorrt python包，可以用来将PyTorch模型转换为TensorRT模型；
- libboost-dev，用于C++开发者；
- CUDA开发库，用于基于cuda的开发，或者pytorch的源码编译；
- MKL静态库，用于基于mkl的开发，或者libtorch的静态编译；
- pycuda python包，用于运行TensorRT模型;
- gemfield版pytorch，基于master分支构建的pytorch python包，设置```export PYTHONPATH=/opt/gemfield```环境变量后来使用（从而覆盖掉标准路径下的标准版pytorch）；
- opencv4deepvac，opencv 4.4的静态库，为libdeepvac项目而生。路径为```/opt/gemfield/opencv4deepvac```；
- libtorch静态库，LibTorch静态库，为libdeepvac项目而生。路径为```/opt/gemfield/libtorch```；
- deepvac项目，https://github.com/DeepVAC/deepvac 项目在本地的克隆；
- libdeepvac项目，https://github.com/DeepVAC/libdeepvac 项目在本地的克隆。

为了支持上述功能，pro版本的镜像足足增加了10个GB。也正是因为此，torchpod拆分成了标准版和pro版。

# TorchPod的部署及运行
## 部署
TorchPod有三种部署方式：
1. 纯粹的Docker命令行方式，部署且运行后只能在命令行里工作。
```bash
#有cuda设备
docker run --gpus all -it --entrypoint=/bin/bash gemfield/torchpod
#没有cuda设备
docker run -it --entrypoint=/bin/bash gemfield/torchpod
```

2. 图形化的Docker部署方式，部署后可以在本地、vnc客户端、rdp客户端、浏览器中访问图形界面。共有如下8种部署方：

|protocol| mode  | 部署方式 |备注 |
|--------|-------|----------|---------|
|x11     | local |命令1     |同时支持ssh|
|x11     | rdp   |命令2     |同时支持ssh
|x11     | vnc   |命令3     |同时支持ssh、web|
|wayland | local |命令4     |同时支持ssh|
|wayland | rdp   |命令5     |同时支持ssh，尚未开发完成|
|wayland | vnc   |命令6     |同时支持ssh、web，尚未开发完成|


- 命令1: 启动图形化容器（X11），使用本地宿主机的X11服务端（注意：本地系统需要运行X服务）
```bash
Xephyr :2 -screen 1920x1080 -resizeable #如果本地没有X服务，启动Xephyr新建一个
docker run -it --rm -eTORCHPOD_MODE=local -ePROTOCOL=x11 -e DISPLAY=:2 -v /tmp/.X11-unix:/tmp/.X11-unix gemfield/torchpod
```

- 命令2：启动图形化容器（X11），通过RDP来访问
```bash
docker run -it --rm -eTORCHPOD_MODE=RDP -ePROTOCOL=x11 -p 3389:3389 gemfield/torchpod
```

- 命令3：启动图形化容器（X11），通过VNC来访问，ssh端口可选
```bash
docker run -it --rm -eTORCHPOD_MODE=VNC -ePROTOCOL=x11 -p 7030:7030 -p 5900:5900 -p 20022:22 gemfield/torchpod
```

- 命令4：启动图形化容器（wayland），使用本地宿主机的wayland compositor（或者本地的wayland服务端）
```bash
docker run -it --rm --cap-add SYS_NICE --device=/dev/dri -eTORCHPOD_MODE=local -ePROTOCOL=wayland -v /tmp/.X11-unix:/tmp/.X11-unix -v $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY:/run/gemfield/wayland-0 -v $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY.lock:/run/gemfield/wayland-0.lock gemfield/torchpod
```
- 命令5：启动图形化容器（wayland），通过RDP来访问（备注：尚未开发完成，目前得手动启动krdp服务）
```bash
docker run -it --rm --cap-add SYS_NICE --device=/dev/dri -eTORCHPOD_MODE=RDP -ePROTOCOL=wayland -v /tmp/.X11-unix:/tmp/.X11-unix -v $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY:/run/gemfield/wayland-0 -v $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY.lock:/run/gemfield/wayland-0.lock  -p 3389:3389 gemfield/torchpod
```

- 命令6：启动图形化容器（wayland），通过VNC来访问，ssh端口可选（备注：尚未开发完成，目前得手动启动krfb服务）
```bash
docker run -it --rm --cap-add SYS_NICE --device=/dev/dri -eTORCHPOD_MODE=VNC -ePROTOCOL=wayland -v /tmp/.X11-unix:/tmp/.X11-unix -v $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY:/run/gemfield/wayland-0 -v $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY.lock:/run/gemfield/wayland-0.lock -p 7030:7030 -p 5900:5900 -p 20022:22 gemfield/torchpod
```

参数中的端口号用途：
|端口号 | 协议 | 用途 |
|-------|------|------|
|3389   |rdp   |通过rdp客户端，Windows远程桌面连接客户端|
|5900   |vnc   |通过vnc客户端|
|7030   |http  |通过浏览器来访问图形界面|
|20022  |ssh   |用于ssh客户端、sftp客户端、KDE Dolphin、vscode remote ssh等|

注意，当使用vscode remote ssh功能时，首先在vscode上新建ssh target，然后在"Enter SSH Connection Command"输入框中输入：
```bash
ssh -p 20022 gemfield@<your_host_running_torchpod>
```
密码输入:gemfield


3. k8s集群部署方式（需要k8s集群运维经验，适合团队的协作管理）。请访问[基于k8s部署torchpod](./docs/k8s_usage.md)以获得更多部署信息。

## 2. 登录
三种部署方式中的第一种无需赘述，使用```docker exec -it```登录即可。后两种部署成功后使用图形界面进行登录和使用。支持如下使用方式：
- 1，浏览器(http://your_host:7030);
- 2，vnc客户端，比如realvnc客户端：https://www.realvnc.com/en/connect/download/viewer/ 。realvnc公司承诺viewer永远免费使用。
- 3，rdp客户端，比如KRDC、remmina、Windows远程桌面等。

## 3. 账户信息
TorchPod默认提供了如下账户：
- 用户:gemfield
- 密码:gemfield
- HOME:/home/gemfield

如果要改变该默认行为，可以在docker命令行上（或者k8s yaml中）通过-e参数注入以下环境变量：
- TORCHPOD_USER=<my_name>
- TORCHPOD_PASSWORD=<my_password>
- HOME=<my_home_path>

## 4. 账户安全
为了安全，用户在初始登录TorchPod后，最好使用```passwd```命令来修改账户密码。

## 5. 输入法
要启动中文输入法，非常简单，只需要点击桌面左下角的Applications——>系统——>Fcitx 5即可启动，然后就可以使用中文输入法了（通过桌面右下角输入法图标右键切换，或者ctrl+space组合键来切换）。
