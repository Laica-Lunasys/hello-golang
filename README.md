# hello-golang

## How to Use

### In Local...
```bash
# Start
bash ./launcher.sh start

# Stop
bash ./launcher.sh stop
```
> Note: If you want start just only daemon (for dev), Try: `bash ./daemonctl.sh start postgres`.

### On Stage...
```bash
# Start
bash ./launcher.sh start --with-caddy

# Stop (Automatic stop / delete when running or exists caddy container)
bash ./launcher.sh stop
```
