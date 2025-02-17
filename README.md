# TorchPod
跨平台的容器化开发环境，以Docker image形式（遵循OCI规范的image）封装，以GNU/Linux KDE图形系统呈现。支持如下三个平台：
- Linux
- Windows
- macOS

TorchPod镜像托管在docker hub上，可以使用docker命令进行部署，也可以使用docker desktop进行部署，也可以使用k8s进行部署。

# TorchPod的主要组件及版本

|gemfield/torchpod  |版本号                 |
|-------------------|----------------------|
|OS                 |Ubuntu 24.04          |
|KDE Plasma         |6.3                   |
|KDE Framework      |6.10                  |
|Qt                 |6.8                   |
|Python             |3.12                  |
|openjdk            |21                    |
|firefox            |135                   |
|fcitx5             |5.1                   |
|vs code            |1.92                  |
|libreoffice        |24.2                  |
|vlc                |3.0                   |



# TorchPod的部署及运行
TorchPod可以部署在如下平台上：
- Linux
- Windows
- macOS

其中macOS支持intel处理器和apple silicon处理器。


## 1,Linux
部署后可以在本地、vnc客户端、rdp客户端、浏览器中访问图形界面。共有如下8种部署方：

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
或者
```bash
#在vt5（一般来说就是ctrl+Alt+F5对应的terminal）上启动X服务
sudo X :5 -terminate vt5
#切换回来
docker run -it --device=/dev/dri --rm -eTORCHPOD_MODE=local -ePROTOCOL=x11 -e DISPLAY=:5 -v /tmp/.X11-unix:/tmp/.X11-unix gemfield/torchpod
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
当然，你也可以在本地启动一个新的wayland compositor（e.g. Kwin），然后TorchPod作为客户端连接这个新的wayland compositor：
```bash
export $(dbus-launch)
kwin_wayland --xwayland --socket /tmp/torchpod
#指定该unix socket来连接上述的新的wayland compositor
docker run -it --rm --cap-add SYS_NICE --device=/dev/dri -eTORCHPOD_MODE=RDP -ePROTOCOL=wayland -v /tmp/.X11-unix:/tmp/.X11-unix -v /tmp/torchpod:/run/gemfield/wayland-0 -v /tmp/torchpod.lock:/run/gemfield/wayland-0.lock -p 3389:3389 gemfield/torchpod
```
- 命令5：启动图形化容器（wayland），通过RDP来访问（备注：仍需要你手动在“系统设置”中打开“远程桌面”，并设置用户名密码，并手动启动/usr/bin/krdpserver，并在连接时点击确认按钮等）
```bash
docker run -it --rm --cap-add SYS_NICE --device=/dev/dri -eTORCHPOD_MODE=RDP -ePROTOCOL=wayland -v /tmp/.X11-unix:/tmp/.X11-unix -v $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY:/run/gemfield/wayland-0 -v $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY.lock:/run/gemfield/wayland-0.lock  -p 3389:3389 gemfield/torchpod
```

- 命令6：启动图形化容器（wayland），通过VNC来访问，ssh端口可选（备注：仍需要你手动启动/usr/bin/krfb，包括设置密码，并在连接时点击确认按钮等）
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


k8s集群部署方式（需要k8s集群运维经验，适合团队的协作管理）。请访问[基于k8s部署torchpod](./docs/k8s_usage.md)以获得更多部署信息。

## 2, macOS


## 3, Windows


# vscode
注意，当使用vscode remote ssh功能时，首先在vscode上新建ssh target，然后在"Enter SSH Connection Command"输入框中输入：
```bash
ssh -p 20022 gemfield@<your_host_running_torchpod>
```
密码输入:gemfield

# 登录
四种方式：
- 1, docker命令：```docker exec -it```
- 2，vnc客户端，推荐tigervnc客户端，其可以在运行时动态调整窗口大小;
- 3，rdp客户端，比如KRDC、remmina、Windows远程桌面等;
- 4，浏览器：http://your_host:7030

也可以在docker desktop的GUI界面上登陆。

# 账户信息
TorchPod默认提供了如下账户：
- 用户:gemfield
- 密码:gemfield
- HOME:/home/gemfield

如果要改变该默认行为，可以在docker命令行上（或者k8s yaml中）通过-e参数注入以下环境变量：
- TORCHPOD_USER=<my_name>
- TORCHPOD_PASSWORD=<my_password>
- HOME=<my_home_path>

为了安全，用户在初始登录TorchPod后，最好使用```passwd```命令来修改账户密码。

# 中文输入法
要启动中文输入法，非常简单，只需要点击桌面左下角的Applications——>系统——>Fcitx 5即可启动，然后就可以使用中文输入法了（通过桌面右下角输入法图标右键切换，或者ctrl+space组合键来切换）。

# 基于TorchPod的生态
目前有如下项目基于TorchPod：
- torchpod-ai: 基于TorchPod的PyTorch、ollama开发运行环境
- torchpod-oh：基于TorchPod的openharmoey开发环境

