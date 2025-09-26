# Project 1: Flask App CI/CD with Jenkins Master-Agent + Ansible + PostgreSQL

Overview
- Jenkins builds and packages a simple Flask app.
- Artifact is archived by Jenkins and deployed by Ansible to multiple CentOS app servers.
- PostgreSQL runs on a DB server (CentOS). The Flask app connects to Postgres via env vars.

What is included
- `app.py`, `config.py`, `requirements.txt`, `templates/` and `db/init.sql` - the Flask app and DB seed.
- `Jenkinsfile` - pipeline that builds, packages, archives artifact and triggers Ansible.
- `ansible/` - inventory, `playbook.yml` and roles: `python_flask`, `postgresql`, `deploy_app`.

High-level steps to use
1. Prepare AWS EC2 instances:
   - Jenkins master: Amazon Linux 2 (user: ec2-user)
   - Jenkins agent: Ubuntu 22.04 (user: ubuntu)
   - DB server: CentOS 7/8 (user: centos)
   - App servers: CentOS 7/8 (user: centos)

2. Configure SSH keys and update `ansible/inventory.ini` replacing placeholders like `JENKINS_MASTER_IP`, `DB_SERVER_IP`, `APP1_IP` etc.

3. In Jenkins:
   - Create credentials for SSH and an agent labeled `jenkins-agent`.
   - Add this repository as a Pipeline job and enable parameterized builds.

4. Run the pipeline with `APP_VERSION` and `DB_HOST` parameters. The pipeline will:
   - Create a Python venv and install requirements.
   - Package the app into `flask_app-<version>.tar.gz` and archive it.
   - Trigger the Ansible playbook on the agent which:
     - Installs Python and creates virtualenv on app servers.
     - Installs and configures PostgreSQL on the DB server and seeds the DB.
     - Deploys the artifact on app servers, creates env file with DB host, and starts the systemd service.

Notes & assumptions
- The Ansible roles are written for CentOS-style package/service names; adjust package names or tasks if using different distro versions.
- The DB initialization file is copied from the repository and executed on the DB server.
- For production use, replace plaintext DB passwords with Vault/secret management and secure SSH keys.

Quick test locally (without Jenkins/Ansible):
1. Create a Python venv and install requirements:
   python -m venv .venv; .\.venv\Scripts\activate; pip install -r requirements.txt
2. Start Postgres locally and create the DB and table (use `db/init.sql`).
3. Set env vars for DB connection and run app:
   $env:DB_HOST='localhost'; $env:DB_NAME='devopsdb'; $env:DB_USER='devops'; $env:DB_PASS='password'
   python app.py
4. Visit http://localhost:5000 and you should see "I am almost a DevOps Engineer!" and the seeded users.

Next steps / improvements
- Add a Jenkins artifact repository (e.g., local Nexus or S3 upload) if you want long-term storage.
- Harden Postgres, use system users, and configure a firewall to open port 5000 only via load balancer / security groups.
