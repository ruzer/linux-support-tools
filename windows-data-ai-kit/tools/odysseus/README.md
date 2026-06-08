# Odysseus Helper

Repo:

https://github.com/pewdiepie-archdaemon/odysseus

Odysseus is a self-hosted AI workspace. It has privileged local capabilities
such as shell, file access, agent tools, model serving, email and MCP. Keep it
private and localhost-only unless you intentionally put it behind VPN/Tailscale
or a trusted reverse proxy.

Commands:

```powershell
odysseus-lab setup
odysseus-lab start
odysseus-lab password
odysseus-lab status
odysseus-lab logs
odysseus-lab stop
```

Default URL:

```text
http://localhost:7000
```

The helper uses branch `main` by default because the repo README says `dev` may
be unstable. Use `odysseus-lab setup -DevBranch` only if you explicitly want
latest development changes.

