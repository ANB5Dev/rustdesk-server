# Compile / setup server

#### Preparation
```bash
apt install rustup
rustup default stable
sudo useradd --system --create-home --home-dir /home/rustdesk --shell /usr/bin/bash rustdesk
```
*if needed:* open firewall on 5 subsequent ports, default: 21115-21119 (port-1 through port+4)

#### Clone git
```bash
git clone --recurse-submodules https://github.com/ANB5Dev/rustdesk-server.git
cd rustdesk-server
```

#### Build
```bash
cargo build --release
```

#### Test run
```bash
RUST_LOG=debug PORT=21116 target/release/hbbs -R 192.168.100.247:21116 -r 192.168.100.247:21117
RUST_LOG=debug PORT=21116 target/release/hbbr
```

#### Install
```bash
sudo cp ./target/release/{hbbr,hbbs,rustdesk-utils} /usr/local/bin/
sudo cp ./systemd-anb5/rustdesk@.service /etc/systemd/system/rustdesk@.service
sudo cp ./systemd-anb5/rustdesk-runner.sh /usr/local/bin/rustdesk-runner.sh
sudo cp ./systemd-anb5/rustdesk.json /etc/rustdesk.json
```
*TODO: file owners and rights*

#### Edit config file
```bash
vim /etc/rustdesk.json
```

#### Generate new keypair
```bash
rustdesk-utils genkeypair
```

#### Start systemd service
```bash
systemctl start rustdesk@<server name in JSON>
```

#### Check daemon status
```bash
systemctl status rustdesk@*
```

#### Remove systemd statuses for non-existing instances
```bash
systemctl reset-failed
```

# Documentation

### Environment variables
https://github.com/rustdesk/rustdesk-server?tab=readme-ov-file#env-variables

### Ports
https://rustdesk.com/docs/en/self-host/rustdesk-server-oss/install/#ports

	hbbs listens on:
	21114 N/A    (TCP), for web console, (only available in Pro version)
	21115 PORT-1 (TCP), NAT type test and online status query
	21116 PORT   (TCP/UDP), UDP for the ID registration and heartbeat service, TCP for TCP hole punching and connection service
	21118 PORT+2 (TCP), support web clients

	hbbr listens on:
	21117 PORT+1 (TCP), for the Relay services
	21119 PORT+3 (TCP), support web clients

# Logging

PunchHoleRequest = connection request

PunchHoleSent = start P2P

RelayResponse = start relayed connection

<!--
# Outdated / backup

sudo chown -R rustdesk:rustdesk /home/rustdesk /etc/rustdesk.json /usr/local/bin/rustdesk-runner.sh
sudo chmod 750 /usr/local/bin/rustdesk-runner.sh

RUST_LOG=debug KEY=Kbxy... PORT=21116 ALWAYS_USE_RELAY=N DB_URL=rustdesk.ASCI-demo.sqlite3 SERVERNAME="ASCI-test" LOGURL="https://...?token=..." LOGVERBOSE=Y ~/rustdesk-server/target/release/hbbs -r 192.168.100.247:21116 -R 192.168.100.247:21117
RUST_LOG=debug KEY=Kbxy... PORT=21116 SINGLE_BANDWIDTH=100 TOTAL_BANDWIDTH=200 LIMIT_SPEED=200 ~/rustdesk-server/target/release/hbbr

## link to our fork of hbb_common
cd libs/hbb_common
git remote set-url origin https://github.com/ANB5Dev/hbb_common.git
cd ../..
git config -f .gitmodules submodule.libs/hbb_common.url https://github.com/ANB5Dev/hbb_common
git submodule update --remote libs/hbb_common
git add .gitmodules libs/hbb_common
git commit -m "Updated hbb_common submodule to forked version"
git push origin master
-->
