# Install Server

#### Preparation
```bash
apt install rustup jq
sudo useradd --system --create-home --home-dir /home/rustdesk --shell /usr/bin/bash rustdesk
su - rustdesk
rustup default stable
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
RUST_LOG=debug PORT=21116 target/release/hbbs --rendezvous-servers <your IP or hostname>:21116 --relay-servers <your IP or hostname>:21117
RUST_LOG=debug PORT=21116 target/release/hbbr
```

#### Install
```bash
sudo cp ./target/release/{hbbr,hbbs,rustdesk-utils} /usr/local/bin/
sudo cp ./systemd-anb5/rustdesk@.service /etc/systemd/system/rustdesk@.service
sudo cp ./systemd-anb5/rustdesk-runner.sh /usr/local/bin/rustdesk-runner.sh
sudo cp ./systemd-anb5/rustdesk.json /etc/rustdesk.json
```
By default it runs under user `rustdesk`, this can be changed in `/etc/systemd/system/rustdesk@.service`.

# Configure New Server

#### Generate a new keypair
```bash
rustdesk-utils genkeypair
```
Copy these two keys and also keep a backup of them!

#### Edit rustdesk servers config file
```bash
vim /etc/rustdesk.json
```
| Self                               | Description |
|------------------------------------|-------------|
| `self`                             | IP or hostname to server. |

| Servers section                    | Description |
|------------------------------------|-------------|
| `name`                             | Name for the systemd instance. |
| `public_key`, `private_key`        | Keys generated with `rustdesk-utils genkeypair`. |
| `port`                             | Listening port for `hbbs` (rendezvous server). `hbbr` (relay server) uses `port + 1`. |
| `single_bandwidth`, `total_bandwidth`, `limit_speed` | Relay server speed limits. |
| `rust_log`                         | Stdout verbosity: `off`, `error`, `warn`, `info`, `debug`, `trace`. |
| `logurl`                           | Send logs as POST to this URL. Parameters: `server_name`, `client_ip`, `action`, `data`. |
| `logverbose`                       | Send verbose logs to `logurl`. Use `Y` or `N`. |
| `always_use_relay`                 | Disallow direct peer connections. Use `Y` or `N`. |

#### Start systemd instance
```bash
systemctl start rustdesk@<name>
```

#### Check daemon status for all instances
```bash
systemctl status rustdesk@*
```

#### Enable start at boot
```bash
systemctl enable rustdesk@<name>
```

#### Maintenance

##### Restart after editing /etc/rustdesk.json
```bash
systemctl restart rustdesk@<name>
```
It takes 15-30 seconds before all clients have reconnected.

##### Remove systemd statuses for non-existing instances
```bash
systemctl reset-failed
```

# Log statuses

PunchHoleRequest = connection request

PunchHoleSent = start P2P

RelayResponse = start relayed connection

# Reference

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

<!--
# Outdated / backup

sudo chown -R rustdesk:rustdesk /home/rustdesk /etc/rustdesk.json /usr/local/bin/rustdesk-runner.sh
sudo chmod 750 /usr/local/bin/rustdesk-runner.sh

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
