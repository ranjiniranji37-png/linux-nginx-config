# Linux Server Administration and Nginx Reverse Proxy

Secure Linux server configuration with SSH key-only login, UFW firewall, and an Nginx reverse proxy (gzip, caching headers, rate limiting, SSL/TLS termination) in front of the Flask app from the Docker project.

## Files

| File | Purpose |
|---|---|
| `sshd_config` | Hardened SSH server settings |
| `ufw-setup.sh` | Firewall rules (ports 22, 80, 443 only) |
| `nginx.conf` | Nginx reverse proxy configuration |

## 1. User and permissions

```bash
sudo adduser deployuser
sudo usermod -aG sudo deployuser
```

Only `deployuser` is allowed to log in over SSH (`AllowUsers deployuser`). Root login is disabled.

## 2. SSH key-based authentication

On the local machine:

```bash
ssh-keygen -t ed25519 -C "deployuser"
ssh-copy-id deployuser@SERVER_IP
```

Then copy `sshd_config` to `/etc/ssh/sshd_config` and restart SSH:

```bash
sudo sshd -t
sudo systemctl restart ssh
```

Key settings: `PasswordAuthentication no`, `PermitRootLogin no`, `MaxAuthTries 3`.

## 3. UFW firewall

```bash
bash ufw-setup.sh
```

All incoming traffic is denied by default. Only ports 22 (SSH), 80 (HTTP) and 443 (HTTPS) are allowed.

## 4. Nginx reverse proxy

```bash
sudo apt install nginx -y
sudo cp nginx.conf /etc/nginx/nginx.conf
sudo nginx -t
sudo systemctl restart nginx
```

Features in `nginx.conf`:

- **Reverse proxy:** forwards traffic to the app on `127.0.0.1:5000`
- **Gzip compression:** enabled for text, CSS, JSON and JavaScript
- **Caching headers:** `/static/` files cached for 7 days
- **Rate limiting:** 10 requests per second per IP, burst of 20
- **HTTP to HTTPS redirect:** port 80 redirects to 443
- **Security headers:** X-Frame-Options, X-Content-Type-Options, hidden server version

## 5. SSL/TLS termination

Sandbox (self-signed certificate):

```bash
sudo mkdir -p /etc/nginx/ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/selfsigned.key \
  -out /etc/nginx/ssl/selfsigned.crt \
  -subj "/CN=localhost"
```

Production (Let's Encrypt): use Certbot and replace the certificate paths in `nginx.conf`.

```bash
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d example.com
```

## 6. Verification

```bash
sudo ufw status verbose
sudo nginx -t
curl -k -I https://localhost
curl -I http://localhost
```

Expected: HTTP returns `301` redirect to HTTPS, and HTTPS returns the app response with security headers.
