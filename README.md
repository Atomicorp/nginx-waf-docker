About

This container implements the Atomicorp NGINX Web Application Firewall (ModSecurity v3). It is designed to act as a reverse proxy, and supports automatic container detection and configuration. Rule policies are shared with the container over a volume 


Installation

1) Register for WAF rule updates at https://atomicorp.com/pricing/


2) Create volume directories for /etc/nginx/conf.d and /etc/httpd/modsecurity.d

	mkdir -p ~/waf/conf.d
	mkdir -p ~/waf/modsecurity.d

3) Download nginx ruleset at: https://updates.atomicorp.com/channels/rules/nginx-latest/, and extract the archive:

	tar xvf nginx-waf-201802271105.tar.gz

4) Copy the master nginx config:
	
	cp rules/conf/00_mod_security.conf ~/waf/conf.d
	cp rules/conf/tortix_waf.conf  ~/waf/modsecurity.d/
	cp rules/* ~/waf/modsecurity.d/



Usage

Basic 

DEFAULT_HOST declares the nginx default host

docker run -d -p 80:80 -e DEFAULT_HOST=www.example.com -v /var/run/docker.sock:/tmp/docker.sock:ro -v ~/waf/conf.d:/etc/nginx/conf.d -v ~/waf/modsecurity.d:/etc/httpd/modsecurity.d atomicorp/nginx-waf-docker

With SSL certificates

docker run -d -p 80:80 -p 443:443 -v /path/to/certs:/etc/nginx/certs -v /var/run/docker.sock:/tmp/docker.sock:ro -v ~/waf/conf.d:/etc/nginx/conf.d -v ~/waf/modsecurity.d:/etc/httpd/modsecurity.d atomicorp/nginx-waf-proxy


Name-Based virtual host support

available with the environmental variable -e VIRTUAL_HOST=www.example.com. Note that name based virtual  host certificates (if used)use naming convention <VIRTUAL_HOST>.key and <VIRTUAL_HOST>.crt Example: www.example.com.key and www.example.com.crt

docker run -e VIRTUAL_HOST=www.example.com -d -p 80:80 -p 443:443 -v /path/to/certs:/etc/nginx/certs -v /var/run/docker.sock:/tmp/docker.sock:ro -v ~/waf/conf.d:/etc/nginx/conf.d -v ~/waf/modsecurity.d:/etc/httpd/modsecurity.d atomicorp/nginx-waf-proxy


Thanks:

This project is a CentOS/RHEL based derivative of the project at:

https://github.com/jwilder/nginx-proxy
