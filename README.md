# frp-quickstart

frp内网穿透软件linux服务端/客户端以及Windows客户端一键安装脚本。

## Linux Installing

- via `curl`
    ```
    sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/siaimes/frp-quickstart/master/frp-quickstart.sh)"
    ```
- via `wget`
    ```
    sudo bash -c "$(wget -O- https://raw.githubusercontent.com/siaimes/frp-quickstart/master/frp-quickstart.sh)"
    ```

## Windows Installing

Windows脚本基于[winsw](https://github.com/winsw/winsw)。下载[frp_x.x.x_windows_amd64.zip](https://github.com/fatedier/frp/releases)并解压。将解压得到的`frpc.exe`和`frpc.ini`放到当前目录，并编辑好配置文件。双击install.bat即可将frp安装为Windows服务，双击uninstall.bat即可将Windows服务删除。